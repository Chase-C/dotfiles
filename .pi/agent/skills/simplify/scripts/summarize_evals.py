#!/usr/bin/env python3
"""Aggregate completed simplify grading files and run metrics."""

from __future__ import annotations

import argparse
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


VARIANTS = ("with_skill", "without_skill")


class SummaryError(Exception):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Aggregate grading.json and timing.json files from a simplify eval workspace.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  scripts/summarize_evals.py /tmp/simplify-evals/iteration-1
  scripts/summarize_evals.py --require-complete /tmp/simplify-evals/iteration-1
""",
    )
    parser.add_argument("workspace", type=Path)
    parser.add_argument(
        "--output",
        type=Path,
        help="Benchmark path (default: WORKSPACE/benchmark.json)",
    )
    parser.add_argument(
        "--require-complete",
        action="store_true",
        help="Fail if any assertion remains ungraded",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text())
    except FileNotFoundError as error:
        raise SummaryError(f"missing file: {path}") from error
    except json.JSONDecodeError as error:
        raise SummaryError(f"invalid JSON in {path}: {error}") from error


def collect_records(workspace: Path) -> list[dict[str, Any]]:
    grading_paths = sorted(workspace.glob("eval-*/run-*/*/grading.json"))
    if not grading_paths:
        raise SummaryError(f"no grading files found under {workspace}")

    records = []
    for grading_path in grading_paths:
        grading = load_json(grading_path)
        timing = load_json(grading_path.with_name("timing.json"))
        variant = grading.get("variant")
        if variant not in VARIANTS:
            raise SummaryError(f"invalid variant in {grading_path}: {variant!r}")

        results = grading.get("assertion_results")
        if not isinstance(results, list) or not results:
            raise SummaryError(f"no assertion results in {grading_path}")
        for result in results:
            if result.get("passed") not in (True, False, None):
                raise SummaryError(
                    f"passed must be true, false, or null in {grading_path}: {result.get('passed')!r}"
                )
            if result.get("passed") is True and not str(result.get("evidence", "")).strip():
                raise SummaryError(f"passing assertion lacks evidence in {grading_path}")

        records.append(
            {
                "eval_id": grading.get("eval_id"),
                "variant": variant,
                "run": grading.get("run"),
                "results": results,
                "timing": timing,
                "path": str(grading_path),
            }
        )
    return records


def metric(values: list[float]) -> dict[str, float | None]:
    if not values:
        return {"mean": None, "stddev": None}
    return {
        "mean": round(statistics.mean(values), 4),
        "stddev": round(statistics.pstdev(values), 4) if len(values) > 1 else None,
    }


def summarize_records(records: list[dict[str, Any]]) -> dict[str, Any]:
    passed = failed = ungraded = 0
    run_pass_rates = []
    durations = []
    tokens = []
    costs = []
    successful_runs = 0

    for record in records:
        run_passed = run_failed = 0
        for result in record["results"]:
            value = result.get("passed")
            if value is True:
                passed += 1
                run_passed += 1
            elif value is False:
                failed += 1
                run_failed += 1
            else:
                ungraded += 1
        graded_in_run = run_passed + run_failed
        if graded_in_run:
            run_pass_rates.append(run_passed / graded_in_run)

        timing = record["timing"]
        if timing.get("exit_code") == 0:
            successful_runs += 1
        if isinstance(timing.get("duration_ms"), (int, float)):
            durations.append(float(timing["duration_ms"]))
        usage = timing.get("usage") or {}
        if isinstance(usage.get("totalTokens"), (int, float)):
            tokens.append(float(usage["totalTokens"]))
        cost = usage.get("cost") or {}
        if isinstance(cost.get("total"), (int, float)):
            costs.append(float(cost["total"]))

    graded = passed + failed
    return {
        "runs": len(records),
        "successful_runs": successful_runs,
        "assertions": {
            "passed": passed,
            "failed": failed,
            "ungraded": ungraded,
            "total": graded + ungraded,
            "pass_rate": round(passed / graded, 4) if graded else None,
        },
        "run_pass_rate": metric(run_pass_rates),
        "duration_ms": metric(durations),
        "total_tokens": metric(tokens),
        "cost_usd": {
            **metric(costs),
            "sum": round(sum(costs), 6) if costs else None,
        },
    }


def difference(left: float | None, right: float | None) -> float | None:
    if left is None or right is None:
        return None
    return round(left - right, 4)


def delta(with_skill: dict[str, Any], without_skill: dict[str, Any]) -> dict[str, Any]:
    return {
        "assertion_pass_rate": difference(
            with_skill["assertions"]["pass_rate"],
            without_skill["assertions"]["pass_rate"],
        ),
        "run_pass_rate_mean": difference(
            with_skill["run_pass_rate"]["mean"],
            without_skill["run_pass_rate"]["mean"],
        ),
        "duration_ms_mean": difference(
            with_skill["duration_ms"]["mean"],
            without_skill["duration_ms"]["mean"],
        ),
        "total_tokens_mean": difference(
            with_skill["total_tokens"]["mean"],
            without_skill["total_tokens"]["mean"],
        ),
        "cost_usd_mean": difference(
            with_skill["cost_usd"]["mean"],
            without_skill["cost_usd"]["mean"],
        ),
    }


def grouped_summary(records: list[dict[str, Any]]) -> dict[str, Any]:
    variants = {
        variant: summarize_records([record for record in records if record["variant"] == variant])
        for variant in VARIANTS
    }
    return {
        **variants,
        "delta": delta(variants["with_skill"], variants["without_skill"]),
    }


def build_benchmark(workspace: Path, records: list[dict[str, Any]]) -> dict[str, Any]:
    eval_ids = sorted({record["eval_id"] for record in records})
    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "workspace": str(workspace),
        "overall": grouped_summary(records),
        "by_eval": {
            str(eval_id): grouped_summary(
                [record for record in records if record["eval_id"] == eval_id]
            )
            for eval_id in eval_ids
        },
    }


def update_grading_summaries(records: list[dict[str, Any]]) -> None:
    for record in records:
        path = Path(record["path"])
        grading = load_json(path)
        results = grading["assertion_results"]
        passed = sum(result.get("passed") is True for result in results)
        failed = sum(result.get("passed") is False for result in results)
        ungraded = len(results) - passed - failed
        grading["summary"] = {
            "passed": passed,
            "failed": failed,
            "ungraded": ungraded,
            "total": len(results),
            "pass_rate": round(passed / (passed + failed), 4) if passed + failed else None,
        }
        path.write_text(json.dumps(grading, indent=2) + "\n")


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    if not workspace.is_dir():
        raise SummaryError(f"workspace not found: {workspace}")

    records = collect_records(workspace)
    update_grading_summaries(records)
    benchmark = build_benchmark(workspace, records)
    output = (args.output or workspace / "benchmark.json").expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(benchmark, indent=2) + "\n")

    ungraded = benchmark["overall"]["with_skill"]["assertions"]["ungraded"]
    ungraded += benchmark["overall"]["without_skill"]["assertions"]["ungraded"]
    print(
        json.dumps(
            {
                "benchmark": str(output),
                "records": len(records),
                "ungraded_assertions": ungraded,
            },
            indent=2,
        )
    )
    if args.require_complete and ungraded:
        print(f"Error: {ungraded} assertions remain ungraded", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SummaryError as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(2)
