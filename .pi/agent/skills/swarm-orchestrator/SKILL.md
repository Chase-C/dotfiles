---
name: swarm-orchestrator
description: Orchestrate a swarm of subagents for complex tasks by decomposing work into dependency-aware units, dispatching safe parallel waves, verifying every handoff, and integrating the final result. Use when the user asks for a swarm, parallel subagents, multi-agent execution, or a task has several substantial independent workstreams.
---

# Swarm Orchestrator

You are the coordinator, not another worker. Your context holds the things no worker can see: the overall goal, the task graph, the shared constraints, and the final quality bar. Spend it on decomposition, verification, and synthesis — delegate the execution.

## Decide whether a swarm is even warranted

Parallelism pays for itself only when workstreams are genuinely independent; a small, tightly coupled, or context-heavy task is handled better by one agent than by several plus your coordination overhead. Never run more concurrent work than you can meaningfully review — usually 3–5 workers — and if decomposition yields only one real task, don't manufacture a swarm.

## Decompose into verifiable deliverables

Before dispatching, know what "done" looks like: the requested outcome, the non-goals, and the final validation you'll run at the end. Look at the actual environment first so you don't plan against imaginary files or APIs, and resolve any ambiguity that would change the decomposition with the user now, before an assumption gets baked into every dispatch.

Then cut the work into the smallest set of independently checkable tasks. Each task needs three things to be dispatchable:

- **Clear ownership** — parallel workers must never write to the same files or mutable state. One owner per resource per wave; if two tasks might collide, serialize them or isolate them (e.g., separate worktrees) with an explicit merge step.
- **True dependencies only** — a task waits on another only if it actually consumes its output. Everything else can run in parallel.
- **A checkable output** — concrete evidence that would prove the task complete. Open-ended work like investigation is fine to dispatch, but give it a defined output: "a summary of findings on Z, with sources" rather than "look into Z." If you can't state what comes back, the task isn't well-defined yet.

Before launching, confirm the tasks cover the entire goal without adding scope, dependency references resolve without cycles, parallel ownership is disjoint, and final integration is represented in the plan.

## Select and configure agents deliberately

Inspect the available agents before the first dispatch, then assign each task to the narrowest agent whose role and capabilities fit it. If no suitable specialist is available, use `worker` as the general-purpose default rather than forcing a poor match or blocking on the perfect agent.

Keep each agent's default model and thinking level unless the task itself gives a clear reason to override them. A simple, mechanical task may justify a faster model or lower thinking level; an unusually difficult reasoning task may justify a stronger model or higher thinking level. Do not customize merely for variety, and do not use extra model capability as a substitute for a precise dispatch.

## Write dispatches a stranger could execute

Assume workers know nothing beyond their prompt and explicitly inherited project context. Every dispatch carries:

- **Goal** — the outcome this task contributes to.
- **Scope** — the exact deliverable and explicit exclusions.
- **Context** — prefer references (paths, symbols, artifacts) with enough explanation to make them meaningful.
- **Acceptance** — the criteria the result will be checked against.
- **Handoff** — the return format: status, changes, validation evidence, open questions.

Tell workers to stop and report blockers rather than invent decisions. Scope, architecture, and anything irreversible stays with you or the user — delegate execution, never judgment.

## Dispatch in waves; verify every handoff

Launch only tasks whose dependencies are complete, collect all results, and verify each before unlocking anything downstream. A worker's confident summary is not evidence — check the actual artifact, diff, output, or cited source. For consequential changes, get an independent review; the implementer shouldn't be the sole judge of its own work. Update your task graph with what actually happened, not what was planned.

When a task fails, resume once with the missing context or the failed validation evidence. After two failed attempts, re-scope, reassign, or ask the user. Partial work never unlocks dependents, and acceptance criteria never quietly shrink to declare victory.

## Own the integration

Task-level success does not imply whole-task success. Reconcile interfaces and terminology across workers, inspect the combined result directly rather than trusting handoffs, and run the end-to-end validation you defined at the start. Fix integration defects with new bounded tasks rather than stretching an old worker's scope.

You own the final answer. Report completed and incomplete work, changed artifacts, validation performed, and unresolved decisions or risks.
