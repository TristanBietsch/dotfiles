# Installed third-party skills

Pinned sources live in `~/.claude/skills.tsv` (one row per skill: repo, subpath, commit SHA, excluded paths).
`claude-skills sync` vendors each row unmodified, minus the excluded paths, and writes `<skill>/.source` as a stamp.
Plugins live in `~/.claude/settings.json`. This file holds the review notes.

## MCP servers

| Name | Scope | Endpoint |
|---|---|---|
| solana-mcp-server | user | https://mcp.solana.com/mcp (HTTP, no key) |

Named `solana-mcp-server` because solana-dev's SKILL.md auto-installs under that name if it is missing.

## Not installed

- **helius** (helius-labs/core-ai @ 8deb438, helius-skills/helius): skipped. SKILL.md:33-42 drives agent signup with USDC autopay from a generated keypair stored in plaintext at `~/.helius/keypair.json`; SKILL.md:139-142 forces `skipPreflight: true` and Jito tips into all transaction code.
- **Helius MCP** (`npx helius-mcp`): not installed. It exposes signup/payment/transfer tools. svm needs it and will ask for it when used.

## Replaced

- Previous `solana-dev` was a symlink to `~/.agents/skills/solana-dev` (installed 2026-10-26 via `npx skills add`, SHA not recorded). Symlink removed; `~/.agents/skills/solana-dev` and `~/.agents/.skill-lock.json` left untouched.

## Review notes (risks are documentation-only unless stated)

- solana-dev: SKILL.md:150-165 auto-adds the Solana MCP without asking; `curl | sh` installers for Solana CLI and Surfpool in references; mainnet default for RPC lookups (rpc-quick-lookups.md:19).
- svm: hard dependency on Helius MCP (SKILL.md:28-33).
- squads: examples default to mainnet + `./keypair.json`; `examples/multisig/create-multisig.ts` creates a real 2-of-3 multisig with discarded member keys when run; Grid API reference is unverified and handles bank/KYC data.
- surfpool: `curl -sL https://run.surfpool.run/ | bash` shown as recommended installer.
- zz-code-recon: `trufflehog` without `--no-verification` (docs/advanced-techniques.md:328); `gh issue create` posting findings; references `./scripts/*.sh` that do not ship with the skill.
- vulnhunter: `semgrep --config=p/...` sends metrics by default; secret-search greps print values.


### Added 2026-11-10

- write-a-prd, request-refactor-plan, qa (mattpocock/skills): pinned to the last commit before upstream renamed or removed them. The current replacements (`to-spec`, `to-tickets`, `triage`) set `disable-model-invocation: true`, so they never auto-load. All three file GitHub issues with `gh`. `qa` SKILL.md:49 says "Do NOT ask the user to review first — just file and share URLs."
- openspec-* (Fission-AI/OpenSpec): needs the `openspec` CLI, which is not installed by sync. Install it yourself: `npm i -g @fission-ai/openspec@1.17.0`.
- terminal-title: `scripts/set_title.ps1` (Windows) excluded. Its `UserPromptSubmit` hook is wired in settings.json. It writes `~/.claude/terminal_title` and an OSC title escape to `/dev/tty`. Hook output to stdout is empty, verified.
- postgres (sanjay3290/ai-skills): read-only session (`set_session(readonly=True)`) plus a client-side write-keyword filter. Credentials go in `~/.config/claude/postgres-connections.json` (chmod 600), never in this repo. The skill's own `.gitignore` covers `connections.json`. Needs `pip install psycopg2-binary`.
- software-architecture (NeoLabHQ): pinned to the commit before upstream removed it. Frontmatter name is `ddd:software-architecture`. Its description is broad ("any case that relates to software development"), so expect it to load often.
- prompt-engineering (NeoLabHQ): markdown only.

### Plugins added 2026-11-10

- superpowers@superpowers-marketplace replaces superpowers@claude-plugins-official (same upstream). `root-cause-tracing` is now part of `systematic-debugging`.
- example-skills@anthropic-agent-skills ships `frontend-design` and `skill-creator`, so the claude-plugins-official copies were dropped.
- terrashark, task-observer (one-skill-to-rule-them-all), overkill: installed from their own marketplaces. The experimental `task-observer-flush` hook plugin was not installed.

### Reviewed and not installed (2026-11-10)

- Composio `*-automation` skills: need the third-party Rube MCP (rube.app), which routes Gmail/Slack/Jira/Drive data through Composio. First-party connectors already cover these.
- git-guardrails-claude-code: global hook blocks `git push`. Declined.
- `@c0x12c/ai-toolkit`: writes into the current repo's `.claude/`. It overlaps superpowers and mattpocock.

## Update procedure

1. Change the SHA (or add a row) in `~/.claude/skills.tsv`.
2. Run `claude-skills sync`, then review `git -C ~/dotfiles diff`.
3. Run `claude-skills check && claude-skills test`, then commit.
