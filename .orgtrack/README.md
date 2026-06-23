# .orgtrack

This folder stores repo-shareable ORGII file/session/commit lineage.

- `metadata/` is designed to be safe to publish. It contains session/file/commit metadata, branch context, agent category labels, content-addressed records, and rebuildable indexes.
- `histories/` is private by default. It can contain richer agent working history, detailed normalized events, trajectories, prompts, tool payloads, file contents, and secrets.
- `metadata/records/` is the canonical merge-safe source of truth. Records are immutable and deduplicated by deterministic IDs.
- `metadata/derived/` contains rebuildable indexes for fast UI reads. If these files conflict, run ORGII orgtrack repair or initialize again.

Commit `metadata/` when you want open-source provenance without publishing full agent workings. Keep `histories/` local unless you intentionally opt in.
