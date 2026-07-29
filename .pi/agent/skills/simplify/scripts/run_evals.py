#!/usr/bin/env python3
"""Run isolated with-skill and without-skill simplify evaluations."""

from __future__ import annotations

import argparse
import difflib
import json
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCRIPT_PATH = Path(__file__).resolve()
DEFAULT_SKILL_ROOT = SCRIPT_PATH.parents[1]
DEFAULT_MANIFEST = DEFAULT_SKILL_ROOT / "evals" / "evals.json"
VARIANTS = ("with_skill", "without_skill")


class EvalError(Exception):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run simplify evals in clean workspaces with and without the skill.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  scripts/run_evals.py --output /tmp/simplify-evals/iteration-1
  scripts/run_evals.py --eval 1 --eval 3 --runs 3 --output /tmp/iteration-2
  scripts/run_evals.py --dry-run --output /tmp/preview
""",
    )
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--output", type=Path, required=True, help="New workspace directory")
    parser.add_argument(
        "--eval",
        dest="eval_ids",
        action="append",
        type=int,
        help="Eval ID to run; repeat to select multiple (default: all)",
    )
    parser.add_argument("--runs", type=int, default=1, help="Runs per variant (default: 1)")
    parser.add_argument("--pi", default="pi", help="Pi executable (default: pi)")
    parser.add_argument("--provider", help="Provider passed to pi")
    parser.add_argument("--model", help="Model pattern or ID passed to pi")
    parser.add_argument("--thinking", help="Thinking level passed to pi")
    parser.add_argument(
        "--timeout",
        type=int,
        default=1800,
        help="Seconds allowed per pi invocation (default: 1800)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Delete the output directory first if it exists",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate inputs and print the run plan without invoking pi",
    )
    return parser.parse_args()


def load_manifest(path: Path) -> tuple[Path, dict[str, Any]]:
    path = path.expanduser().resolve()
    try:
        data = json.loads(path.read_text())
    except FileNotFoundError as error:
        raise EvalError(f"manifest not found: {path}") from error
    except json.JSONDecodeError as error:
        raise EvalError(f"invalid JSON in {path}: {error}") from error

    if not isinstance(data.get("evals"), list) or not data["evals"]:
        raise EvalError(f"manifest has no evals: {path}")
    return path.parent.parent, data


def fixture_directory(skill_root: Path, case: dict[str, Any]) -> Path:
    files = case.get("files")
    if not isinstance(files, list) or not files:
        raise EvalError(f"eval {case.get('id')} has no files")

    paths = [(skill_root / item).resolve() for item in files]
    missing = [str(path) for path in paths if not path.is_file()]
    if missing:
        raise EvalError(f"eval {case.get('id')} references missing files: {', '.join(missing)}")

    parents = {path.parent for path in paths}
    if len(parents) != 1:
        raise EvalError(f"eval {case.get('id')} files must share one fixture directory")

    fixture = parents.pop()
    fixtures_root = (skill_root / "evals" / "files").resolve()
    if fixture.parent != fixtures_root:
        raise EvalError(
            f"eval {case.get('id')} fixture must be directly under {fixtures_root}: {fixture}"
        )
    return fixture


def select_cases(manifest: dict[str, Any], eval_ids: list[int] | None) -> list[dict[str, Any]]:
    cases = manifest["evals"]
    ids = [case.get("id") for case in cases]
    if any(not isinstance(case_id, int) for case_id in ids):
        raise EvalError("every eval ID must be an integer")
    if len(ids) != len(set(ids)):
        raise EvalError("eval IDs must be unique")

    if not eval_ids:
        return cases

    requested = set(eval_ids)
    unknown = sorted(requested - set(ids))
    if unknown:
        raise EvalError(f"unknown eval IDs: {', '.join(map(str, unknown))}")
    return [case for case in cases if case["id"] in requested]


def build_command(
    args: argparse.Namespace,
    skill_root: Path,
    prompt: str,
    variant: str,
) -> list[str]:
    command = [
        args.pi,
        "--mode",
        "json",
        "--no-session",
        "--no-skills",
        "--no-extensions",
        "--no-context-files",
    ]
    if variant == "with_skill":
        command.extend(["--skill", str(skill_root)])
    if args.provider:
        command.extend(["--provider", args.provider])
    if args.model:
        command.extend(["--model", args.model])
    if args.thinking:
        command.extend(["--thinking", args.thinking])
    command.append(prompt)
    return command


def remove_generated_python_cache(before: Path, after: Path) -> None:
    for cache_dir in after.rglob("__pycache__"):
        if not (before / cache_dir.relative_to(after)).exists():
            shutil.rmtree(cache_dir)
    for bytecode in after.rglob("*.pyc"):
        if not (before / bytecode.relative_to(after)).exists():
            bytecode.unlink()


def text_diff(before: Path, after: Path) -> str:
    relative_paths = {
        path.relative_to(before) for path in before.rglob("*") if path.is_file()
    } | {path.relative_to(after) for path in after.rglob("*") if path.is_file()}
    chunks: list[str] = []

    for relative in sorted(relative_paths):
        old_path = before / relative
        new_path = after / relative
        old_bytes = old_path.read_bytes() if old_path.is_file() else b""
        new_bytes = new_path.read_bytes() if new_path.is_file() else b""
        if old_bytes == new_bytes:
            continue
        try:
            old_lines = old_bytes.decode().splitlines(keepends=True)
            new_lines = new_bytes.decode().splitlines(keepends=True)
        except UnicodeDecodeError:
            chunks.append(f"Binary files differ: input/{relative} work/{relative}\n")
            continue
        chunks.extend(
            difflib.unified_diff(
                old_lines,
                new_lines,
                fromfile=f"input/{relative}",
                tofile=f"work/{relative}",
            )
        )
    return "".join(chunks)


def analyze_trace(path: Path) -> tuple[str, dict[str, Any]]:
    response = ""
    malformed_lines = 0
    usage = {
        "input": 0,
        "output": 0,
        "cacheRead": 0,
        "cacheWrite": 0,
        "reasoning": 0,
        "totalTokens": 0,
        "cost": {"input": 0.0, "output": 0.0, "cacheRead": 0.0, "cacheWrite": 0.0, "total": 0.0},
    }
    provider = None
    model = None

    for raw_line in path.read_text(errors="replace").splitlines():
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError:
            malformed_lines += 1
            continue
        if event.get("type") != "message_end":
            continue
        message = event.get("message", {})
        if message.get("role") != "assistant":
            continue

        texts = [
            part.get("text", "")
            for part in message.get("content", [])
            if part.get("type") == "text"
        ]
        if texts:
            response = "".join(texts)
        provider = message.get("provider", provider)
        model = message.get("model", model)

        message_usage = message.get("usage") or {}
        for key in ("input", "output", "cacheRead", "cacheWrite", "reasoning", "totalTokens"):
            value = message_usage.get(key)
            if isinstance(value, (int, float)):
                usage[key] += value
        message_cost = message_usage.get("cost") or {}
        for key in usage["cost"]:
            value = message_cost.get(key)
            if isinstance(value, (int, float)):
                usage["cost"][key] += value

    return response, {
        "provider": provider,
        "model": model,
        "usage": usage,
        "malformed_trace_lines": malformed_lines,
    }


def grading_scaffold(case: dict[str, Any], variant: str, run_number: int) -> dict[str, Any]:
    assertions = case.get("assertions")
    if not isinstance(assertions, list) or not assertions:
        raise EvalError(f"eval {case.get('id')} has no assertions")
    return {
        "eval_id": case["id"],
        "variant": variant,
        "run": run_number,
        "assertion_results": [
            {"text": assertion, "passed": None, "evidence": ""} for assertion in assertions
        ],
        "summary": {
            "passed": 0,
            "failed": 0,
            "ungraded": len(assertions),
            "total": len(assertions),
            "pass_rate": None,
        },
        "human_feedback": "",
    }


def run_variant(
    args: argparse.Namespace,
    skill_root: Path,
    case: dict[str, Any],
    fixture: Path,
    variant: str,
    run_number: int,
    destination: Path,
) -> dict[str, Any]:
    input_dir = destination / "input"
    work_dir = destination / "work"
    shutil.copytree(fixture, input_dir)
    shutil.copytree(fixture, work_dir)

    command = build_command(args, skill_root, case["prompt"], variant)
    (destination / "command.json").write_text(json.dumps(command, indent=2) + "\n")
    trace_path = destination / "trace.jsonl"
    stderr_path = destination / "stderr.log"

    started_at = datetime.now(timezone.utc)
    start = time.monotonic()
    timed_out = False
    with trace_path.open("w") as stdout, stderr_path.open("w") as stderr:
        try:
            result = subprocess.run(
                command,
                cwd=work_dir,
                stdout=stdout,
                stderr=stderr,
                text=True,
                timeout=args.timeout,
                check=False,
            )
            exit_code = result.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            exit_code = 124
            stderr.write(f"Timed out after {args.timeout} seconds.\n")
    duration_ms = round((time.monotonic() - start) * 1000)

    response, trace_data = analyze_trace(trace_path)
    (destination / "response.md").write_text(response)
    remove_generated_python_cache(input_dir, work_dir)
    (destination / "changes.patch").write_text(text_diff(input_dir, work_dir))

    timing = {
        "started_at": started_at.isoformat(),
        "duration_ms": duration_ms,
        "exit_code": exit_code,
        "timed_out": timed_out,
        **trace_data,
    }
    (destination / "timing.json").write_text(json.dumps(timing, indent=2) + "\n")
    (destination / "grading.json").write_text(
        json.dumps(grading_scaffold(case, variant, run_number), indent=2) + "\n"
    )
    return timing


def make_plan(
    args: argparse.Namespace,
    skill_root: Path,
    cases: list[dict[str, Any]],
) -> dict[str, Any]:
    return {
        "skill": str(skill_root),
        "manifest": str(args.manifest.expanduser().resolve()),
        "output": str(args.output.expanduser().resolve()),
        "runs_per_variant": args.runs,
        "evals": [
            {
                "id": case["id"],
                "fixture": fixture_directory(skill_root, case).name,
                "variants": list(VARIANTS),
            }
            for case in cases
        ],
        "provider": args.provider,
        "model": args.model,
        "thinking": args.thinking,
    }


def main() -> int:
    args = parse_args()
    if args.runs < 1:
        raise EvalError("--runs must be at least 1")
    if args.timeout < 1:
        raise EvalError("--timeout must be at least 1")

    skill_root, manifest = load_manifest(args.manifest)
    cases = select_cases(manifest, args.eval_ids)
    for case in cases:
        if not isinstance(case.get("prompt"), str) or not case["prompt"].strip():
            raise EvalError(f"eval {case.get('id')} has no prompt")
        fixture_directory(skill_root, case)

    plan = make_plan(args, skill_root, cases)
    if args.dry_run:
        print(json.dumps(plan, indent=2))
        return 0

    if shutil.which(args.pi) is None:
        raise EvalError(f"pi executable not found: {args.pi}")

    requested_output = args.output.expanduser().absolute()
    if requested_output.is_symlink():
        raise EvalError(f"output must not be a symlink: {requested_output}")
    output = requested_output.resolve()
    if output.exists():
        if not args.force:
            raise EvalError(f"output already exists: {output}; use --force to replace it")
        if not (output / "run-plan.json").is_file():
            raise EvalError(f"refusing to replace a directory not created by this runner: {output}")
        shutil.rmtree(output)
    output.mkdir(parents=True)

    (output / "run-plan.json").write_text(json.dumps(plan, indent=2) + "\n")
    failures = 0
    completed = 0

    for case in cases:
        fixture = fixture_directory(skill_root, case)
        case_dir = output / f"eval-{case['id']:02d}-{fixture.name}"
        case_dir.mkdir()
        (case_dir / "case.json").write_text(json.dumps(case, indent=2) + "\n")

        for run_number in range(1, args.runs + 1):
            run_dir = case_dir / f"run-{run_number}"
            for variant in VARIANTS:
                destination = run_dir / variant
                destination.mkdir(parents=True)
                print(
                    f"eval {case['id']} run {run_number} {variant}",
                    file=sys.stderr,
                    flush=True,
                )
                timing = run_variant(
                    args,
                    skill_root,
                    case,
                    fixture,
                    variant,
                    run_number,
                    destination,
                )
                completed += 1
                if timing["exit_code"] != 0:
                    failures += 1

    result = {
        "workspace": str(output),
        "invocations": completed,
        "failed_invocations": failures,
        "next_step": f"Edit grading.json files, then run scripts/summarize_evals.py {output}",
    }
    print(json.dumps(result, indent=2))
    return 1 if failures else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except EvalError as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(2)
