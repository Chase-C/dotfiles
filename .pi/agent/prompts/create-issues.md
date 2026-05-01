---
name: create-issues
description: Break a plan, spec, PRD, or bug report into independent issues, written as local markdown files. Most issues should be thin vertical slices that cut end-to-end through every layer they touch, so integration risk surfaces early and each issue is verifiable on its own. Use when the user wants to convert a plan into issues, create implementation tickets, or break work into independent units.
---

# Create Issues

Decompose a plan, spec, PRD, or bug report into a set of independent issues, written as local markdown files, that collectively produce a good implementation of the plan.

The central technique is **vertical slicing**: most issues should be narrow end-to-end paths through every layer they touch (schema, API, UI, tests, etc.), not horizontal layers of work. A completed vertical slice should be demoable or verifiable on its own.

## Output

Each invocation produces a self-contained directory of markdown files for one task:

```
issues/<task-slug>/
├── 00-context.md      — shared context all issues link back to
├── 01-<slug>.md       — first issue, in implementation order
├── 02-<slug>.md
└── ...
```

The numeric prefix reflects implementation order, sorts issues alongside `00-context.md`, and gives later issues a stable filename to reference in their "Blocked by" sections. Putting each task's issues in their own subdirectory lets multiple decompositions coexist without colliding.

## Process

### 1. Establish context

Identify what you are decomposing. The source may be:

- Content already in the conversation
- A file path the user provides — read it from disk
- Pasted text in the user's message

Make sure you understand the goal and scope, any parent issue, and any user stories or acceptance criteria already in the source. If anything is ambiguous, ask the user before proceeding.

When the decomposition depends on the current state of the code — modifying existing systems, integrating with existing modules, or assuming certain structures — explore the relevant parts of the repository. Aim for "enough to draft sensible issues," not exhaustive coverage. Skip this for greenfield or purely additive work in an isolated area.

Confirm the task subdirectory with the user (default: `issues/<task-slug>/`, where `<task-slug>` is kebab-case, derived from the goal). Write `00-context.md` there capturing:

- Goal and scope of the work
- Link to the parent issue file, if any
- Links to relevant source files in the working tree
- Ephemeral context from the conversation that issues will need — decisions made, constraints discussed, links to external docs

Individual issues link back to this doc rather than restate shared ground. User stories and acceptance criteria stay in the issues themselves.

### 2. Draft the issues

#### Issue shape

For most work — especially feature development that touches multiple layers — vertical slicing surfaces integration problems early and avoids artificial serial dependencies between issues.

**Resist the temptation to decompose horizontally** — by layer, by file, by component, or by phase of work ("first all the schema changes, then all the API changes, then the UI"). Horizontal decomposition feels tidy because it groups similar work together, but it produces issues that:

- Cannot be demoed or verified individually
- Hide integration problems until late, when they are most expensive to fix
- Force later issues to wait on earlier ones for no end-user reason
- Read as a parts list rather than a coherent plan

Some kinds of work genuinely don't fit a vertical-slice shape. In these cases, a horizontal, foundational, or investigative issue is appropriate:

- **Foundational decisions** — picking an auth library, choosing a database, setting up CI, scaffolding a new service. Forcing a fake end-to-end demo onto these obscures the real work.
- **Refactors and migrations** — "move all callers from v1 to v2" is inherently horizontal and is best decomposed by caller, module, or call site.
- **Bug fixes** — many bugs are point fixes; the issue is the slice.
- **Spikes and research** — "determine whether approach X is viable" produces a decision, not a deliverable.
- **Pure infrastructure** — observability, logging, deployment pipelines often decompose by component rather than by user-facing slice.

Deviation should be a deliberate choice tied to one of these (or similar) reasons, not a fallback when vertical slicing feels hard. If you find yourself drafting horizontal issues for ordinary feature work, **stop and try again.**

#### Storyline coherence

In implementation order, the issues should read as a coherent storyline. This helps the drafter notice missing or duplicated chapters, and gives implementers and reviewers a way to see how each issue fits into the surrounding sequence — what it builds on, what it sets up.

Storyline coherence is a check on good slicing, not a substitute: a horizontally-sliced plan can read tidy and still produce a bad implementation.

#### Flagging structural impact

Independent of shape, some issues look additive on the surface but actually require restructuring existing code to fit cleanly. The implementer needs to know this going in, because the choice between "add alongside" and "restructure first" is a real decision that affects scope, sequencing, and review.

By the time an issue is picked up, earlier issues in the batch will have landed — so check structural impact against the codebase as it will exist then, not just as it exists today. Common signals:

- Abstractions or interface contracts don't accommodate the new behavior — the data model needs a dimension it doesn't have, a state machine transition breaks an invariant, an API assumes something no longer true.
- Implementing purely additively would require pervasive conditionals or special cases threaded through existing code paths.
- The current module boundary is wrong for the new shape — the work straddles modules in a way that suggests the boundary should move.

Flag the tension in the issue's **Notes** section, on the issue that has to live with it (typically the later one when two issues collide). Describe the tension, not the fix — the goal is to prompt the implementer to weigh approaches, not prescribe one. If flagging feels inadequate, the slicing may be wrong; consider redrawing the boundary.

#### Sizing

Prefer many small-to-medium issues over a few large ones. Split when an issue contains multiple independently testable outcomes or requires separate product, design, or architecture decisions. Merge when neither part can be verified alone, or when one only exists to support the other.

#### Issue type: HITL vs AFK

Independently of shape, mark each issue **AFK** if it can be implemented and merged without further human interaction, or **HITL** if it requires a human in the loop (architectural decision, design review, product judgment).

Prefer AFK. Mark HITL only when a real decision needs a human, not because the work is difficult. Shape and type are orthogonal: foundational decisions are often HITL, feature slices are often AFK, but any combination is possible.

### 3. Audit the breakdown

Before showing the breakdown to the user, run it through these checks. Each one is a way the breakdown can be wrong even when individual issues look fine.

**Coverage check.** Every meaningful part of the source material is represented by some issue, and no issue introduces scope that was not in the source.

**Shape check.** Every issue that isn't a vertical slice falls into one of the deviation categories above. Anything else is horizontal drift and should be re-sliced.

**Storyline check.** In implementation order, the issue titles read as a coherent progression. A disconnected pile suggests boundaries are wrong — issues split, merged, or missing connective tissue.

**Dependency check.** Every "blocked by" relationship is real: the blocked issue genuinely cannot start until the blocker is complete. Remove dependencies that are only convenient or tidy.

**Structural fit check.** Issues that require restructuring existing code have the tension called out in **Notes**.

**Verifiability check.** Each issue has acceptance criteria based on observable behavior or a concrete completed outcome.

If any check fails, revise the breakdown before presenting it.

### 4. Review the breakdown with the user

Present the proposed issues as a numbered list, in the order they will be implemented. For each issue, show:

- **Title** — short and descriptive
- **Shape** — vertical slice / foundational / refactor / bug / infra / etc.
- **Type** — HITL or AFK
- **Issue summary** — what the issue delivers in one or two sentences
- **Blocked by** — which earlier issues (by their number in this list), if any, must complete first
- **Notes** (if applicable) — anything the implementer needs to take into account

Then ask the user:

- Does each issue capture the right intent at the right granularity?
- Is the shape right — vertical where it should be vertical, with deviations only where justified?
- Are structural impacts surfaced where they apply?
- Are the dependency relationships correct?
- Are issues correctly marked HITL vs AFK?

Iterate until the user approves the breakdown. Do not create any files without explicit approval.

### 5. Write the issue files

Write one markdown file per issue in dependency order (blockers first) — `01-add-user-schema.md`, `02-wire-signup-form.md`, etc. — so later issues can reference real filenames in the "Blocked by" field.

Three sections do most of the work in each issue and deserve real attention:

- **Context** anchors the issue in the larger plan. Link to `00-context.md` and scope it down — say which parts of the larger plan apply to this issue, and which nearby parts explicitly don't. Add anything specific to this issue's place in the plan that isn't already in the context doc.
- **What to build** is where the issue gets its specificity. Name the concrete contracts being introduced or changed — types, function signatures, API endpoints, schema shapes, UI surfaces — with their shapes where they've been decided. Don't invent specificity that hasn't been decided. For vertical slices, frame around end-to-end behavior; for other shapes, around what completing the issue accomplishes.
- **Acceptance criteria** define "done" in observable terms — behaviors, artifacts, or passing tests that a reviewer can check directly. Avoid criteria that require interpreting intent.

Do not edit or otherwise modify any parent issue file. Linking is sufficient.

The template's **Notes** section is optional — include it only when there's something real to say.

```markdown
# <Issue title>

**Status:** Open
**Shape:** <vertical slice / foundational / refactor / bug / infra / etc.>
**Type:** <HITL | AFK>

## Context
Link to `00-context.md`. Say which parts of the larger plan apply here and which nearby parts explicitly don't.

## What to build
Name the concrete contracts being introduced or changed — types, signatures, APIs, schemas, UI surfaces — with shapes where decided. Frame vertical slices around end-to-end behavior; other shapes around what the issue accomplishes.

## Acceptance criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Notes
<!-- omit if there's nothing here that earns its place -->
Anything the implementer should know that doesn't belong elsewhere — tensions between the planned change and existing architecture (describe the fit problem, not the solution), or non-obvious technical context (e.g. gotchas, library quirks, design decisions already made).

## Blocked by
- [NN-blocker-issue](./NN-blocker-issue.md)
<!-- or "None — can start immediately" if no blockers -->
```

After writing all files, report back to the user with the list of created filenames and titles.

$@
