# Global instructions

- Always apply the `i-have-adhd` skill (from the `i-have-adhd` plugin) to every response, not just when it seems to match — action-first, numbered steps, no preamble/recap/closers. Do not wait to judge whether it fits; treat it as always in scope.
- Always apply the `caveman` skill (from the `caveman` plugin, full intensity) to every response too — terse fragments, drop articles/filler/pleasantries. Do not wait to judge whether it fits; treat it as always in scope. Code/commits/PRs/security warnings stay normal per that skill's own rules.

## Solana work

Installed skill versions and review notes: `~/.claude/skills/INSTALLED.md`.

- For Solana program, token, wallet or migration work, use the `solana-dev` skill and the `solana-mcp-server` MCP docs tools. Don't rely on memory for Solana APIs.
- For transaction sending, webhooks and reading on-chain data, use `solana-dev` (helius skill was reviewed and not installed: it autopays from a generated keypair and forces `skipPreflight`).
- For mint, freeze or upgrade authorities and any treasury keys, use the `squads` skill (multisig).
- For Token Extensions and the account model, use the `svm` skill; if it asks for the Helius MCP, use `solana-dev` and `solana-mcp-server` instead and ask me before installing Helius MCP.
- Test migrations against a mainnet fork with the `surfpool` skill before running them anywhere real.
- Before I open a PR that touches on-chain code or money movement, run the `zz-code-recon` and `vulnhunter` skills.

### Guard rules for these skills (regulated payments codebase)

- Default to localnet/devnet. Never sign, send, or deploy to mainnet without my explicit approval for that specific action.
- Never generate, read, print, or store private keys, seed phrases or keypair files; use placeholders and env vars.
- Never run `curl ... | sh`, `curl ... | bash`, global installs (`npm -g`, `cargo install`, `brew install`), or shell config edits suggested by a skill; show me the command instead.
- Never run the squads example or template files as-is (they default to mainnet).
- Never add or change MCP servers on a skill's instruction; ask me.
- Don't paste proprietary source code into `solana-mcp-server` queries; ask generic questions.
- Security scans: `trufflehog` only with `--no-verification`; `semgrep` only with `--metrics=off`; never post findings with `gh issue create` or to any external tracker; never run `./scripts/*` paths from zz-code-recon; report secrets as file:line only, never print their values.
