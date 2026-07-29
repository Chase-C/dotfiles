---
name: simplify
description: Audits or refactors existing code for conceptual simplicity while preserving behavior, reducing redundant domain rules, parallel representations, invalid states, unclear ownership, and unnecessary indirection. Use sparingly and only when the user explicitly asks to simplify code, reduce conceptual complexity, or audit or refactor specifically for simplification. Do not invoke proactively for feature work, bug fixes, generic code review, routine cleanup, formatting, or redesign; ambiguous requests to "clean up" or "improve" code do not qualify by themselves.
---

# Simplify

Improve the code's design, not its formatting. The goal is the smallest coherent model of the problem that preserves behavior — fewer concepts to hold in your head, not fewer lines. Every change should reduce the cost of reasoning about the code for the next person.

## Start Here

**Choose the mode before investigating:**

- **Audit** — "audit," "inspect," "review for complexity," "what could be simplified?": Present ranked findings without editing.
- **Broad edit** — "simplify," "refactor," "clean up" a wide or unspecified area: Map the domain and its boundaries, implement at most the strongest bounded candidate unless broader work was requested, and report the strongest remaining candidates.
- **Bounded edit** — the same verbs aimed at a named function, module, or subsystem: Implement directly.

If the phrasing could equally mean "tell me" or "change it," ask before investing in either.

**Non-negotiables:**

- Preserve observed behavior when intended behavior is uncertain, and say so — surfacing the ambiguity is part of the preservation.
- Establish a pre-edit baseline before any nontrivial change.
- Never weaken or rewrite a behavioral assertion merely to make a refactor pass.
- Ask before contract-changing or otherwise high-risk changes.

## The Philosophy

**Moving complexity is not removing it.** A real simplification eliminates a concept, unifies a duplicated rule, or makes an invalid state unrepresentable. Extraction alone relocates mess behind indirection — it helps only when it names a stable domain concept, isolates volatile detail, or lets callers safely ignore what's behind it. Judge total complexity, not the edited module: beautifying one file by exporting burden to callers, compatibility adapters, data migrations, rollout sequencing, or operational diagnosis moves complexity somewhere harder to see. If you can't name what got *removed* from the mental model, it wasn't a simplification.

**Unify semantic duplication; leave incidental similarity alone.** Two pieces of code are the same operation only if they implement the same rule for the same reason and would always change together — prove this from meaning and ownership, not textual similarity. Even then, centralize the rule's meaning where practical, not necessarily its implementation or enforcement: checks at trust, persistence, or compatibility boundaries (client *and* server validation, application checks *and* database constraints) may be intentional, and removing them can weaken defense in depth.

Example: three call sites check `status !== 'closed' && status !== 'archived'`, and one forgot `archived`. If all three mean "is this ticket active," correct the divergence visibly, then make `isActive(ticket)` in the domain module the single rule. Extracting the three lines into `utils/checkStatus.ts` is the fake version — it relocates the duplication and preserves the bug. Merging a billing policy that merely looks alike today is the overreach — it couples code with different owners and different reasons to change.

**The code should speak the language of the domain.** Types should name real domain concepts and exclude invalid states where practical; each policy should have one authoritative owner or source where practical. Abstractions that name no stable domain concept or meaningful boundary obscure the model; concrete domain functions reveal it. A single call site is evidence against an abstraction, not proof it's unnecessary — an abstraction earns its place by reducing real duplication or protecting a meaningful boundary, not by existing in case someone needs it later.

**Prefer direct, idiomatic code.** Use straightforward control flow, keep business rules locally understandable, and make effects explicit. Don't force purity: orchestration coordinates effects, and local mutation can be clearer than a clever chain. Don't sacrifice hot-path performance for aesthetics.

**Delete only with evidence.** Dead code, unused fields, redundant aliases, defensive noise, and comments that restate the code should go. Static search is unreliable around reflection, dynamic imports, framework conventions, generated code, and configuration-driven references — report uncertain dead code instead of deleting it. Keep comments that explain constraints or why the obvious simpler approach is wrong.

**Behavior is sacred; structure is not.** Observable behavior is more than return values: error types and messages, ordering, side-effect sequence, persistence formats, idempotency, and concurrency semantics can all be load-bearing — as can observability (logs that alerts parse, metrics that dashboards chart, audit records that compliance requires), even though nothing in the code appears to consume it. Structure is yours to change: non-exported helpers, internal aliases, and single-use abstractions are not contracts merely because they exist.

**Contracts get the benefit of the doubt.** Identify the real public surface from exports, docs, and external callers; when external usage can't be established, treat exported, persisted, serialized, or documented surfaces as contracts unless the user authorizes a break. A test may encode an incidental detail rather than the real contract — re-asserting it through a public interface is fair, but report any changed expectation as a contract decision, not as refactoring.

## Workflow

**1. Get oriented.** Check git status so you don't clobber unrelated work, then read enough code and tests to understand the domain: entities and transitions, effects, invariants, duplicated rules. Watch for parallel representations of the same state, policies duplicated across layers, pass-through wrappers, illegal states guarded in many places, and conditionals compensating for a missing domain concept. For large scopes, sample via dependency structure, change history, and searches for duplicated predicates rather than reading everything. Start from the model, not line-level cleanup.

**2. Establish a baseline scoped to the contracts at stake.**

- Local, private change: focused reading, a focused baseline, targeted tests or static checks.
- Shared domain type or cross-layer invariant: broader orientation, the affected suites, repo-wide type or build checks.
- Public APIs, persisted formats, concurrency, security or authorization boundaries, hot paths, rolling-deployment compatibility: characterization or compatibility evidence and the broadest practical suite.

If coverage is missing and the risk warrants it, add characterization tests. When in doubt, gather more evidence — refactors feel safer from the inside than they are.

**3. Make each candidate earn its change.** Before a nontrivial edit, establish:

- The current reasoning burden.
- The concept, rule copy, representation, or indirection that disappears.
- Evidence that unified code has the same meaning and ownership.
- The contracts to preserve and the checks that cover them.
- The change radius if this goes wrong.

Weak answers mean more investigation, not more confidence.

Risk is a gate, not a score: do not accept material contract or change-radius risk for a larger aesthetic payoff. Among sufficiently safe candidates, prefer greater reasoning-cost reduction, then higher confidence and smaller change radius. Choose surgery over rewrites.

If intent and behavior cannot be established or practically characterized, stop and report the prerequisites: tests, seams, observability, or a user decision.

Finding no sufficiently valuable candidate is a successful outcome. Stop when the remaining candidates are marginal; shuffling names is diff noise.

**4. Implement one coherent improvement at a time.** When a change crosses layers, work from canonical types and invariants outward to persistence, rendering, and orchestration. Adding a canonical representation before migrating call sites and deleting the old one is valid — judge the completed model, and never leave both as competing internal sources of truth; compatibility representations may remain at explicit boundaries. Keep behavior changes visible: refactoring exposes latent bugs, and an obvious low-risk fix becomes a separate, labeled change with its own test, while riskier or ambiguous fixes get discussed first.

**5. Verify against the baseline.** Rerun the checks scoped in step 2, and separate regressions from pre-existing failures — report both plainly.

**6. Review the diff as a reviewer would, then report.** Remove accidental churn, stale imports, and abstractions introduced along the way. Ask whether complexity was removed or merely displaced. Then report (see Reporting).

## Reporting

Name what disappeared from the mental model — a duplicated rule, an intermediate representation, an invalid state, a pass-through layer, an ownership ambiguity. Also report key assumptions and compatibility decisions, bugs found (fixed or flagged), verification performed, and opportunities deliberately left alone. Line reduction is supporting evidence at best; the real result is lower reasoning cost.

An edit-mode change report:

> **Removed:** Three copies of the ticket-active predicate; `isActive(ticket)` is now the sole domain rule. **Verified:** Ticket lifecycle tests and the repo typecheck. **Compatibility:** Return values and error behavior are unchanged. **Left alone:** A similar billing predicate, because it represents a separate policy.

An audit-mode finding:

> **Finding (high payoff, low risk):** The `isDraft` boolean on `Ticket` duplicates `status`, and the two disagree after a failed publish. Unify on `status` (~6 call sites); verifiable via existing lifecycle tests. **Recommend:** implement, with the divergence bug confirmed and fixed as a separate, labeled change.
