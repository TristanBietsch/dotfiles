# Solana layer: installed skills and MCP

Pinned sources: `~/.claude/skills.d/solana.tsv`. Base review notes and the update procedure: `~/.claude/skills/INSTALLED.md`.

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
