# Fork Notes

This repository tracks upstream
[`zsh-users/zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)
and keeps this file as the source of truth for fork-specific changes merged on
top of upstream. Keep this document focused on the fork delta rather than on
general upstream project documentation.

Current Baseline
----------------

- Upstream repository: `zsh-users/zsh-syntax-highlighting`
- Upstream branch: `master`
- Upstream base SHA for this fork delta: `1d85c692615a25fe2293bdd44b34c217d5d2bf04`
- Fork repository: `rogerhamonassistant-ai/zsh-syntax-highlighting`
- Fork branch: `master`
- Fork current SHA: `d06c2d250c1dc8d0863aa59849bfc82df1b4d995`
- Current fork delta: 4 fork-only commits ahead of upstream `master`

Landed Fork Changes
-------------------

### PR #1: build: support optional local leak-check hook

- PR: <https://github.com/rogerhamonassistant-ai/zsh-syntax-highlighting/pull/1>
- Branch: `codex/optional-local-leak-check-hook`
- Merge commit: `45a6f99f6ef1c53f1e49608e58c274abb669e4c3`
- Scope: `Makefile`
- Summary:
  - adds an optional local leak-check build hook
  - resolves the hook path relative to the local git checkout
  - resolves the active gitdir dynamically
  - keeps the local hook off TAP stdout

### PR #2: main: support advanced parameter syntax and command classification

- PR: <https://github.com/rogerhamonassistant-ai/zsh-syntax-highlighting/pull/2>
- Branch: `codex/main-advanced-syntax-and-command-position`
- Merge commit: `a76abdff01e918369f44634ef73286177d42f432`
- Scope: `highlighters/main/main-highlighter.zsh` and `highlighters/main/test-data/`
- Summary:
  - extends `main` highlighter coverage for advanced parameter expansion forms
  - refines command and precommand classification, including lookup-target handling
  - tightens function-header and function-body parsing across newline and comment boundaries
  - broadens and validates glob-qualifier handling, including delimited bodies and invalid tails
  - fixes command-position history-expansion continuation highlighting
  - adds broad regression coverage for the new parsing and validation paths
- Notes:
  - this was a long review-driven patch train and was intentionally consolidated by squash merge
  - the merge commit message is the durable high-level summary of the full review series

### PR #3: brackets: ignore quoted bracket regions

- PR: <https://github.com/rogerhamonassistant-ai/zsh-syntax-highlighting/pull/3>
- Branch: `codex/brackets-ignore-quoted-regions`
- Merge commit: `e5976e87cc41eaa219f7f59fd03d167a8d108a7c`
- Scope: `highlighters/brackets/brackets-highlighter.zsh` and `highlighters/brackets/test-data/`
- Summary:
  - refines quoted-bracket handling in nested command substitution, process substitution, and backticks
  - isolates literal bracket scopes across nested shell-code and arithmetic contexts
  - improves `$((` fallback handling for quoted regions and backticks
  - fixes backtick quote-state and reparsed escape-parity behavior
  - adds broad regression coverage for quoted-region and backtick edge cases
- Notes:
  - this was also a long review-driven patch train and was intentionally consolidated by squash merge
  - the merge commit message is the durable high-level summary of the full review series

### Docs: record fork-specific changes

- Commit: `d06c2d250c1dc8d0863aa59849bfc82df1b4d995`
- Scope: `README.md`, `FORK.md`
- Summary:
  - adds the root `FORK.md` document for fork-specific maintenance notes
  - adds the thin `Fork` pointer section in `README.md`
  - records the initial merged fork delta in one place
- Notes:
  - this change landed directly on `master`
  - follow-up documentation changes should use PR flow instead of direct pushes

Files Touched In The Fork
-------------------------

The current fork delta is concentrated in three areas:

- `Makefile`
  - optional local leak-check build support
- `highlighters/main/`
  - parser and validator changes in the `main` highlighter
  - a large body of focused `main` highlighter regression fixtures
- `highlighters/brackets/`
  - parser and quoted-region changes in the `brackets` highlighter
  - a large body of focused `brackets` highlighter regression fixtures

Maintenance
-----------

When fork-only changes land on `master`, update this file immediately:

1. Refresh the upstream base SHA and current fork `master` SHA.
2. Update the reported fork delta count if the fork moves closer to or further from upstream.
3. Add a new merged-change entry with:
   - PR link
   - branch name
   - merge commit SHA
   - concise scope and behavior summary
4. Update the touched-areas summary if a new subsystem starts carrying fork-only changes.
5. Keep the `README.md` `Fork` section brief and in sync with the high-level summary here.
6. Prefer a PR-based workflow for future fork-maintenance changes; direct pushes to `master` should be exceptional and documented here if they happen.

Conventions:

- Record merged squash commits, not intermediate review commits.
- Prefer PR-based changes going forward; if something lands directly on `master`, record it explicitly as a direct-landing exception.
- Prefer behavior-level summaries over raw commit inventories.
- If the fork returns to upstream parity, keep `FORK.md` and replace the merged-change list with a short note that the fork currently carries no fork-only delta.
