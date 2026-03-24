# Fork Notes

This repository tracks upstream
[`zsh-users/zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)
and keeps this file as a durable summary of the fork-specific content carried
on top of upstream. Keep it focused on the actual fork delta rather than on
general upstream documentation or volatile repository bookkeeping.

Current Fork Content
--------------------

The current fork carries three substantive changes beyond upstream:

- an optional local leak-check build hook in `Makefile`
- advanced syntax and command-classification refinements in the `main`
  highlighter and its regression corpus
- quoted-region and backtick-handling refinements in the `brackets`
  highlighter and its regression corpus

Substantive Fork Changes
------------------------

This section summarizes the durable fork-specific changes currently carried
beyond upstream. It is intentionally content-focused and does not attempt to
enumerate every direct documentation-only maintenance commit.

### PR #1: build: support optional local leak-check hook

- PR: <https://github.com/rogerhamonassistant-ai/zsh-syntax-highlighting/pull/1>
- Scope: `Makefile`
- Summary:
  - adds an optional local leak-check build hook
  - resolves the hook path relative to the local git checkout
  - resolves the active gitdir dynamically
  - keeps the local hook off TAP stdout

### PR #2: main: support advanced parameter syntax and command classification

- PR: <https://github.com/rogerhamonassistant-ai/zsh-syntax-highlighting/pull/2>
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
- Scope: `highlighters/brackets/brackets-highlighter.zsh` and `highlighters/brackets/test-data/`
- Summary:
  - refines quoted-bracket handling in nested command substitution, process substitution, and backticks
  - isolates literal bracket scopes across nested shell-code and arithmetic contexts
  - improves `$((` fallback handling for quoted regions and backticks
  - fixes backtick quote-state and reparsed escape-parity behavior
  - adds broad regression coverage for quoted-region and backtick edge cases
- Notes:
  - this was also a long review-driven patch train and was intentionally consolidated by squash merge

Current Fork Surface
--------------------

The current fork delta is concentrated in three areas:

- `Makefile`
  - optional local leak-check build support
- `highlighters/main/`
  - parser and validator changes in the `main` highlighter
  - a large body of focused `main` highlighter regression fixtures
- `highlighters/brackets/`
  - parser and quoted-region changes in the `brackets` highlighter
  - a large body of focused `brackets` highlighter regression fixtures
