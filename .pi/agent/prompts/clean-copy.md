---
name: clean-copy
description: Reimplement the current git branch with a clean, narrative-quality commit history
---

Reimplement the current git branch in a new branch with a clean, narrative-quality commit history. The end state of the new branch must be byte-identical to the source branch; only the commit history differs.

## Phase 1 — Preflight checks

Before doing any real work, confirm the repo is in a state where this skill can run. Abort if any check fails.

- **Clean working tree** — `git status --porcelain --untracked-files=no` must be empty, and `.git/MERGE_HEAD` must not exist. Abort if there are uncommitted changes or a merge in progress.
- **On a named branch** — `git branch --show-current` must return a branch name. Abort on detached HEAD — there's no branch to clean up. Keep track of this as `<source_branch>` for use in later steps.
- **No prior attempt exists** — `git rev-parse --verify <source_branch>-clean` must fail. If it succeeds, abort and ask the user to delete or rename the existing branch; silently overwriting would discard prior work.

## Phase 2 — Gather context

With preflight passed, gather the context needed to plan the commit sequence.

- **Base branch** (`<base_branch>`) — detect using, in order:
  1. `git symbolic-ref --short refs/remotes/origin/HEAD` — if it succeeds, use that (stripping the `origin/` prefix).
  2. Otherwise, for each of `develop`, `main`, `master` that exists locally (`git rev-parse --verify <name>` succeeds), run `git rev-list --count <candidate>..HEAD` and pick the smallest — that's the nearest divergence point.
  3. If still ambiguous or none exist, ask the user which branch to target.
- **Branch point** (`<branch_point>`) — `git merge-base <source_branch> <base_branch>`. All later work starts here, *not* at the tip of `<base_branch>` — this guarantees the clean branch can end up byte-identical to the source regardless of whether the base has advanced.
- **Commits being replaced** — `git log <branch_point>..<source_branch> --oneline`.
- **Scope of changes** — `git diff <branch_point>..<source_branch> --stat`.

## Phase 3 — Plan the commit storyline

You now need to plan out the commit storyline by decomposing the changes made in the source branch into self-contained logical steps — imagine writing a tutorial that arrives at the same end state.

Read the full diff using `git --no-pager diff --no-ext-diff <branch_point>..<source_branch>` along with any files that seem relevant to understanding the changes. Before creating the storyline, make sure you have a crystal-clear understanding of the work done on this branch and the final intended state.

### What makes a good commit storyline

- **One coherent idea per commit.** Each subject line is a single imperative sentence ("Add retry logic to HTTP client"), not a mechanics description ("Update client.ts"). No "WIP," "fix typo," or "address review" messages — those are artifacts of the original history this skill is replacing.
- **Foundation before use.** New types, interfaces, constants, and utilities land before the code that depends on them.
- **Refactors separate from behavior changes.** If a diff both moves code and changes what it does, split it.
- **No obvious half-states.** A commit may reference something introduced in the very next commit when unavoidable, but shouldn't leave the codebase visibly broken across multiple commits.
- **Tests travel with their behavior.** Land each test in the same commit as the code it covers, or the commit  immediate after — not batched at the end.
- **Commit bodies explain *why*.** The diff shows what changed; the body says why it's needed or what alternative was rejected.

Write out the planned commit sequence before touching anything.

## Phase 4 — Confirm the plan with the user

Present the proposed sequence: for each commit, a one-line subject plus a sentence naming the files or logical area it covers. Ask the user for feedback and wait for approval before reimplementing.

If the user tells you to reorder, split, merge, or rename commits, incorporate the changes and re-present. The user knows the code's logical seams better than you do; this checkpoint is cheap and catches structural disagreements before any reimplementation cost is spent.

## Phase 5 — Create the clean branch and reimplement

With the plan approved, create the clean branch at the shared divergence point — not at the tip of `<base_branch>`. Branching from `<branch_point>` is what makes byte-identical verification possible in Phase 6.

```
git checkout -b <source_branch>-clean <branch_point>
```

Then build each planned commit in order. For each commit:

1. **Reimplement the changes planned for this commit.** Get the working tree into the state this commit should land. For small, localized edits, typing the change directly is fine. For larger or more mechanical changes, prefer lifting content from the source branch rather than retyping it.

   - `git checkout <source_branch> -- path/to/file` pulls a file in its final state. If later planned commits also touch the file, edit it down to the intermediate state this commit should land before staging.
   - `git show <source_branch>:path/to/file` prints the final version for reference without modifying the working tree.

   For example, if planned commit 3 adds a function `foo()` and planned commit 5 adds logging inside `foo()`, then when building commit 3 you'd `git checkout <source_branch> -- path/to/file` and remove the logging lines before staging.

2. **Write the commit message.** Aim for a concise, imperative-mood subject line. When the subject doesn't fully capture the reasoning, add a body (separated from the subject by a blank line) explaining *why* — what alternative was rejected, what's subtle about the approach, what a future reader needs to know.

3. **Stage and commit.** Use `--no-verify` for all commits *except the last*:
   ```
   git commit --no-verify    # for intermediate commits
   git commit                # for the final commit only
   ```
   Intermediate commits represent stages of development — hooks that check types, imports, or run tests may fail on those stages even though the finished work passes. The final commit runs hooks because the final state is what ships; if they fail there, there's a real problem to fix before Phase 6.

## Phase 6 — Verify byte-identity

Run:

```
git diff <source_branch> <source_branch>-clean
```

The output **must** be empty. This is a symmetric comparison that doesn't depend on which branch is checked out.

If empty, verification has passed and the skill is complete.
If it's not empty:

- `git diff --stat <source_branch> <source_branch>-clean` shows the scale.
- `git diff <source_branch> <source_branch>-clean -- <path>` scopes to a single file.
- Common causes: a file missed in some commit, an exploration artifact accidentally included, file-mode changes (`chmod +x`), line-ending drift, or content committed onto the wrong branch.
- Fix the discrepancy on the clean branch (new commit or amend, whichever keeps the narrative clean) and re-run the diff. Do not declare success until it is empty.

The clean branch stays local. The user decides when to push it or force-push it over the original — don't push on their behalf.
