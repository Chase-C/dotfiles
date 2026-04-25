---
name: init
description: Initialize or update AGENTS.md and reference files
---

Your objective is to produce (or refresh) an `AGENTS.md` at the repo root plus a set of focused reference docs under `docs/agents/`. `AGENTS.md` is an index — minimal, scannable, the first 30 seconds of context any agent needs. The reference docs are where detail lives, pulled in on demand via progressive disclosure.

Work through the four phases below in order. Use judgment at each step; the phases are a spine, not a script. When the instructions conflict with obvious repo reality, prefer repo reality and note the deviation.

## Phase 1: Inventory

Do this yourself — no subagent. The goal is cheap, deterministic ground truth before any interpretive work.

**Scope boundary: do not read source code in this phase.** Phase 1 is strictly about project-level metadata — manifests, configs, docs, and the shape of the tree. Reading source files is Phase 2's job, and it's scout's job, not yours. If you find yourself wanting to open a `.ts`, `.rs`, `.py`, or similar file to understand what something does, stop — note it as something for scout to investigate and move on. The only files you should open in this phase are manifests, lockfiles, config files, CI files, containerization files, build scripts, and human-facing docs (READMEs, existing agent-context files).

**Source authority.** Not all project-level files deserve equal weight. Treat manifests, lockfiles, config files, and CI files as **authoritative** for stack, commands, and tooling — they're executable ground truth. Treat `README`, `.github/copilot-instructions.md`, existing `AGENTS.md`, `.cursorrules`, and similar human-authored guidance as **advisory** — useful context, but subject to drift. When advisory sources claim something, hold it as a hypothesis to confirm in Phase 2 rather than a fact to propagate.

**Detect mode.** Check whether `AGENTS.md` exists at the repo root and whether `docs/agents/` contains any `.md` files. If either is present, you're in **refresh mode**; otherwise **fresh mode**. The difference only affects what context you pass to later phases — the phase structure is the same.

**Read project-level files.** Manifests and lockfiles (`package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.), `README*`, `Dockerfile`, `docker-compose*`, `Makefile`, `justfile`, `.github/workflows/*`, and any other top-level config that reveals stack or workflow. Also note the presence of sibling agent-context files: `.cursorrules`, `CLAUDE.md`, `.windsurfrules`, etc. **No source files.**

**Map the tree.** Produce a pruned recursive listing of the repo. Exclude `node_modules`, `.git`, `target`, `dist`, `build`, `gen`, `.next`, `.venv`, `coverage`, and anything in `.gitignore` that's clearly generated. Prefer `rg --files` or `fd` if available; fall back to `find` with explicit prunes. Cap initial depth at ~4 and drill deeper only where something looks structurally interesting (workspace roots, `src/`, `packages/`, etc.). Listing directories is fine; opening the files inside them is not.

**Extract commands.** From `package.json` scripts, `Makefile` targets, `justfile` recipes, `Cargo.toml` aliases, `pyproject.toml` tool configs, and similar, pull the concrete commands for install, test, build, lint, and run. Don't guess — if you can't find a command, leave it out rather than inventing one.

**If refresh mode:** additionally read the existing `AGENTS.md` and every file in `docs/agents/`. Hold their contents in working memory. You'll use them as a prior belief state that Phase 2 will confirm or correct.

## Phase 2: Map

Launch a `scout` subagent with its model *explicitly* set to `gpt-5.4` and its thinking level set to `xhigh`. Give it a briefing that includes the full Phase 1 inventory — stack, commands, pruned tree, notable files — and ask it to *quickly* explore the codebase with the following aims:

- **Confirm or correct the stack inference** from Phase 1 by sampling real source files.
- **Identify source roots and their responsibilities.** For each significant directory, a sentence on what lives there and why.
- **Infer conventions.** Coding style/conventions, formatting rules (from `.prettierrc`, `.eslintrc`, `ruff.toml`, `rustfmt.toml`, etc. plus observed patterns in source), architectural patterns ("repository pattern", "functional components with hooks", "actor model", etc.), testing conventions.
- **Flag deep-dive candidates.** Suggest reference docs to generate, split into two kinds:
    - *Vertical traces* — specific flows worth following end-to-end (request lifecycle, auth flow, a write path, how migrations run).
    - *Horizontal slices* — self-contained subsystems worth documenting as a unit (the auth module, the event store, the api-gateway layer).
    Each suggestion should include a proposed filename under `docs/agents/` (e.g., `docs/agents/auth-flow.md`), a one-sentence scope, and a concise justification for why an agent working in this area would benefit from the doc existing *and* the information not being included main `AGENTS.md` file.
- **Spot universal gotchas** — things that would bite *any* agent working in this repo, not things specific to one subsystem.

**Dependency source is allowed as secondary evidence.** If repo code clearly delegates core behavior to an installed package (e.g., a thin wrapper over an internal `@org/foo-core`) and understanding that package materially improves accuracy, scout may read under `node_modules/` or equivalent. Instruct scout to treat such reads as secondary evidence and label them clearly in its report (e.g., "from `node_modules/@org/foo-core/src/registry.ts`"). First-party code remains the primary source of truth.

**If refresh mode:** also give scout the existing `AGENTS.md` and `docs/agents/*.md` contents, and ask it to additionally flag which existing docs are stale, which are still accurate, which have drifted enough to warrant regeneration, and which are obsolete or no longer justified at all. Scout's deep-dive suggestions in refresh mode should include net-new topics and existing docs that need refreshing, should explicitly omit existing docs that are still accurate, and should explicitly flag existing docs that should be deleted.

## Phase 3: Reference Docs

Reference docs come in two kinds; you will generate both:

- **Deep-dives** — locational docs about a specific flow or subsystem. Candidates come from scout's Phase 2 suggestions.
- **Cross-cutting docs** — docs about patterns, conventions, or practices that repeat across the whole codebase and are worth documenting once centrally rather than rediscovering per-subsystem. Candidates come from your own judgment after reading scout's Phase 2 map. Common examples:
    - `docs/agents/conventions.md` — coding style, formatting, naming, language-specific idioms the project leans on.
    - `docs/agents/testing.md` — how tests are structured, what frameworks, fixtures or factories, what's mocked vs real, how to run a single test.
    - `docs/agents/patterns.md` — repeated architectural patterns (error handling, result types, dependency injection, repository shape, etc.) that show up in many places.
    - Others as the project warrants — e.g., `docs/agents/migrations.md`, `docs/agents/logging.md`, `docs/agents/config.md` — but only if the pattern is genuinely repetitive and non-obvious.

A pattern only belongs in a cross-cutting doc if it actually cuts across multiple subsystems. If scout's research surfaces a pattern that's really only used in one area of the codebase, it belongs in that area's deep-dive, not in `conventions.md` or `patterns.md`. The test: can you name at least three unrelated locations where the pattern shows up? If not, it's not cross-cutting.

The bar for any reference doc — deep-dive or cross-cutting — is: *would an agent working in this area benefit from this doc existing, vs rediscovering it from scratch each time?* Prefer the smallest useful set; for most repos this lands around 3–10 docs total. If your candidate list is at 15, that's a signal to merge or cut, not a sign the repo is exceptional. Ten mediocre docs nobody reads is worse than three good ones.

**Watch for overloaded scope.** A reference doc should answer one reusable question. If a proposed doc's scope statement names more than ~3 distinct owned concepts, or if its draft starts sounding like "how the whole repo works," it's a subsystem overview, not a reference doc — split it or cut it. Agents pull reference docs in for a single concern, and a doc covering seven concepts forces them to skim past six of them every time. Canonical ownership of shared primitives is fine and expected, but one doc owning a long list of independent primitives is a smell.

**Filenames.** Use stable, conventional nouns over local jargon, gerunds, or invented terms — `authorization-and-tokens.md`, not `tasky.md` or `doing-auth.md`. Filenames are part of how agents discover docs by intuition.

**Deduplicate and assign ownership before dispatching.** Scout's suggestions may overlap — a "request lifecycle" vertical trace and an "api-gateway" horizontal slice might cover much of the same ground; a cross-cutting `testing.md` will inevitably touch specific subsystems. Before launching any researchers:

- Merge overlapping targets or sharpen their scopes so they don't collide. Every dispatched target should have a scope that's clearly distinct from the others.
- Identify any **shared primitives** likely to appear across multiple docs — core types, resolvers, validators, event propagation mechanisms, etc. Assign one doc as the canonical owner for each. The owner explains it in depth; other docs reference it by path rather than re-explaining.
- As a general rule, cross-cutting docs own the *general* shape and deep-dives own the *specific* instance. Each should reference the other rather than duplicate.

**In refresh mode:** only dispatch research for net-new topics and for existing docs scout flagged as stale or drifted. Leave accurate existing docs untouched. If scout flagged existing docs as obsolete or no longer justified, delete them from `docs/agents/` rather than preserving them — don't let the doc set accumulate dead weight.

Scout is read-only, so this phase is two steps: **dispatch researchers in parallel, then write the docs yourself from their reports.**

### 3a. Dispatch research

Launch one `scout` subagent per selected target (**in parallel** if possible), with each subagent's model set to `gpt-5.4` and thinking level set to `xhigh`. The briefing differs slightly by kind:

- **For deep-dives:** a tight scope statement naming one flow or one subsystem, and relevant parts of the Phase 2 map that touch it. Scout should trace dependencies and follow references.
- **For cross-cutting docs:** a pattern or practice to survey across the whole codebase, with instructions to sample broadly rather than drill deeply — enough instances to identify the canonical shape and note meaningful variations.

Both kinds get:

- The intended final doc path under `docs/agents/` so scout understands the framing, even though it won't write the file.
- Phase 1 inventory context (stack, commands).
- The shared-primitive ownership assignments from the deduplication pass, so scout knows which concepts it owns in depth vs which it should reference as handled by another doc.
- Permission to read dependency source as secondary evidence when repo code delegates core behavior to an installed package, with instructions to label such reads clearly.
- Thoroughness: **thorough**.
- Instructions to **prefer tight file selection** — return only files that materially support the analysis, not exhaustive listings. Scout should resist the urge to include every file it touched if half of them won't shape the final doc.
- Instructions to return the standard structured report (`Code Context` / `Files Retrieved` / `Key Code` / `Architecture` / `Start Here`), with real file paths, real function names, and exact line ranges in `Files Retrieved`.

### 3b. Reconcile and write

Once all scouts return, do a quick pass across all the reports **before** writing any docs. You're the only place where cross-doc consistency can happen — the parallel scouts can't see each other's work. Look for:

- *Overlap that slipped through* — two reports covering much of the same ground despite distinct scopes. Fold one into the other, or draw a sharper boundary and note it in each doc.
- *Content in the wrong doc* — a gotcha, type, or flow that surfaced in one report but belongs in another.
- *Shared primitives the pre-dispatch pass missed.* Assign a canonical owner and reference from the others.
- *Contradictions.* Resolve — don't let both versions ship.

Then write each reference doc yourself to its target path under `docs/agents/`. Synthesize the scout's report into a focused document — you're not just pasting the report through, you're shaping it into a reference an agent will pull on demand.

Each reference doc should:

- **Open with a one-paragraph scope statement** so an agent pulling it in knows immediately whether it's the right doc.
- **Explain the flow or structure concretely**, using real names from the codebase. If it's a vertical trace, walk the path in order. If it's a horizontal slice, describe the pieces and how they compose.
- **Include key code snippets only when they clarify something prose can't.** A snippet earns its place when it shows a non-obvious shape, a pattern that's hard to describe in words, or a concrete example of a claim that would otherwise be abstract. A snippet does *not* earn its place just because it's the file scout pointed at for a claim — in that case, cite the file and line range and state the claim in prose. If removing the snippet wouldn't weaken the reader's understanding, remove it.
- **Stay tight.** Short is fine; padding is not. If scout's report was thin, the doc should be thin — don't invent filler.
- **Close with a Boundaries section** when the doc has meaningful relationships to other reference docs — things it explicitly doesn't own, upstream docs whose output it consumes, downstream docs that consume its output. One bullet per related doc with a path link and a one-line note on the relationship. This is how agents navigate between related docs without having to re-read the index.
- **End with a Source Map section** preserving the file-and-line-range pointers from scout's `Files Retrieved`. Include only files the doc body actually references or that an agent would need to open to act on the doc's content; don't carry through scout's full reading list if half the entries never appear in the prose. Be concise here - these are signposts for an agent to find the relevant code, not a full audit log of scout's exploration.
- **Omit suggested next steps, TODOs, or speculation.** These are reference docs, not design notes.

Create `docs/agents/` if it doesn't exist.

## Phase 4: Synthesize

Write `AGENTS.md` at the repo root. Keep it minimal. The test for whether something belongs in `AGENTS.md` vs. a reference doc: *will an agent need this in the first 30 seconds of working in this repo, regardless of task?* If no, it belongs in a reference doc.

### Target structure

```markdown
# {PROJECT_NAME}

{One paragraph: what this project is and what it does. No fluff.}

**Stack:** {languages, frameworks, versions — one line}

## Commands

| Action  | Command |
|---------|---------|
| Install | `{cmd}` |
| Test    | `{cmd}` |
| Build   | `{cmd}` |
| Lint    | `{cmd}` |
| Run     | `{cmd}` |

{Use the top-level user-facing invocation an agent should actually run (`npm test`, `make build`, `cargo run`), not the expanded script body. If the underlying expanded command matters for some reason, document it in a reference doc, not here. Omit rows with no known command. Add rows for project-specific workflows if universally relevant.}

## Layout

{5–20 lines. Top-level directories primarily, one line each. Not a full tree. You may include important directories under src/}

- `{dir}/` — {one-line purpose}
- ...

## Gotchas

{Only include things that meet all three tests:
1. **Universal** — would bite an agent working anywhere in the repo, not just in one subsystem.
2. **Actionable** — there's a specific thing to do or not do, not just a property of the system to be aware of.
3. **Non-obvious** — wouldn't be caught by reading one or two relevant files.

Architecture facts ("the system is event-driven", "depends on Redis") fail test 2 and belong in an architecture doc. Subsystem-specific pitfalls fail test 1 and belong in the relevant reference doc. If nothing clears all three bars, omit this section entirely.}

- {gotcha}

## Reference Docs

Pull these in when working in the relevant area:

- [`docs/agents/{name}.md`](docs/agents/{name}.md) — {one line, specific enough that an agent knows when to pull it}
- ...

{If sibling agent-context files exist — `.cursorrules`, `CLAUDE.md`, etc. — list them here too with a one-line note.}
```

### Rules

- Reference doc descriptions in the index must be **specific**, not generic. Not "auth.md — authentication notes" but "auth.md — how requests get authenticated, from middleware through token validation to the session store."
- Don't include a "Coding Standards" section in `AGENTS.md`. Conventions belong in a reference doc (`docs/agents/conventions.md` or similar) if scout found enough to say, and listed in the index like any other.
- Don't include a full directory tree. The layout section is a map, not a listing.
- If you found fewer than three things worth putting under a heading, consider cutting the heading.

**In refresh mode:** rewrite `AGENTS.md` from scratch based on current findings. Don't try to preserve prior content — Phase 1 already gave you the old version as a prior, and Phase 2 already decided what's still accurate. The reference doc set on disk will be the union of untouched accurate docs and freshly regenerated ones, minus any obsolete docs you deleted.

### Final validation

Before finishing, validate that every reference doc linked from `AGENTS.md` exists at its linked path, that filenames in the index match the actual files on disk, and that cross-doc links between reference docs (boundaries sections especially) all resolve. Catching link drift here is cheap; catching it after the fact is not.
