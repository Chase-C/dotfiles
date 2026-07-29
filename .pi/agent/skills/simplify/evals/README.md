# Simplify skill evaluations

These evaluations test whether the skill changes agent behavior in useful ways. They are authoring tools and are not loaded when the skill runs normally.

## Prerequisites

- Python 3.10 or newer
- Pi installed and authenticated
- Provider access for the selected model

Each eval invokes the model twice per run: once with `simplify` and once without it. Runs can incur API usage or subscription limits.

Run commands below from the skill root.

## 1. Preview the plan

Validate the manifest, fixture paths, and selected IDs without invoking Pi:

```bash
python scripts/run_evals.py \
  --dry-run \
  --output /tmp/simplify-evals/iteration-1
```

Select individual evals by repeating `--eval`:

```bash
python scripts/run_evals.py \
  --dry-run \
  --eval 1 \
  --eval 3 \
  --output /tmp/simplify-evals/iteration-1
```

## 2. Run isolated A/B evaluations

Start with one run of one eval:

```bash
python scripts/run_evals.py \
  --eval 1 \
  --output /tmp/simplify-evals/iteration-1
```

Once the workflow looks right, run the full suite three times to measure nondeterminism:

```bash
python scripts/run_evals.py \
  --runs 3 \
  --model MODEL_ID \
  --thinking high \
  --output /tmp/simplify-evals/iteration-2
```

`--provider`, `--model`, and `--thinking` are optional. Without them, Pi uses its configured defaults. Use the same values for every iteration you intend to compare.

The runner disables automatic skills, extensions, and context files for both variants. The `with_skill` variant explicitly loads this skill; `without_skill` does not. Both otherwise use the same Pi configuration.

The output directory must be new. Use `--force` only when intentionally replacing an earlier workspace created by this runner; it refuses to delete other directories.

## Workspace layout

```text
iteration-1/
├── run-plan.json
├── eval-01-semantic-duplication/
│   ├── case.json
│   └── run-1/
│       ├── with_skill/
│       │   ├── input/          # untouched fixture snapshot
│       │   ├── work/           # files after the agent run
│       │   ├── trace.jsonl     # complete Pi event stream
│       │   ├── stderr.log
│       │   ├── response.md     # final assistant response
│       │   ├── changes.patch   # input-to-work diff
│       │   ├── timing.json     # exit status, duration, tokens, cost
│       │   └── grading.json    # assertion grading scaffold
│       └── without_skill/
│           └── ...
└── ...
```

Canonical fixtures under `evals/files/` are never used as working directories.

## 3. Grade each run

Open each `grading.json`. For every assertion, replace `null` with `true` or `false` and add concrete evidence:

```json
{
  "text": "The existing unittest suite is run before editing and passes again after editing.",
  "passed": true,
  "evidence": "trace.jsonl contains two successful python -m unittest executions."
}
```

Use these artifacts when grading:

- `response.md` for claims and reporting quality
- `changes.patch` for the exact edit
- `work/` for final files and runnable tests
- `trace.jsonl` for commands and tool behavior
- `stderr.log` and `timing.json` for failures

Require specific evidence for a pass. Leave `passed` as `null` if the run cannot be graded.

## 4. Build the benchmark

After grading, aggregate results:

```bash
python scripts/summarize_evals.py \
  /tmp/simplify-evals/iteration-1
```

This updates each grading summary and writes:

```text
/tmp/simplify-evals/iteration-1/benchmark.json
```

Require every assertion to be graded in CI or before comparing iterations:

```bash
python scripts/summarize_evals.py \
  --require-complete \
  /tmp/simplify-evals/iteration-1
```

The benchmark reports overall and per-eval pass rates, duration, tokens, cost, and the `with_skill - without_skill` delta.

## Interpreting results

- **Passes with the skill but fails without it:** the skill is adding measurable value.
- **Passes both ways:** the model may not need that instruction; check whether the eval is too easy.
- **Fails both ways:** improve the skill, fixture, assertion, or task framing.
- **Varies between runs:** the instruction may be ambiguous or the assertion may be brittle.
- **Improves quality at excessive cost:** decide whether the added time and tokens are justified.

Read traces, not only scores. They reveal unnecessary investigation, skipped baselines, and instructions that the model interpreted differently than intended.

## Script help

```bash
python scripts/run_evals.py --help
python scripts/summarize_evals.py --help
```
