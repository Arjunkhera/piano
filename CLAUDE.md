# piano — Agent Guide

An app for iPad and iPhone that helps one person learn the piano. The repo is
new. It holds no app code yet. The requirements come first.

This repo is public. Never commit a secret, a private name or personal data.

## State

- Stage: requirements. The stack (native or web) is not chosen yet.
- When the stack is chosen, this file gets the build steps, the layout and
  the modules.

## Map

| You want | Read |
|---|---|
| Every document this repo keeps | [docs/index.md](docs/index.md) |
| Repo facts for Atlas | [atlas.yaml](atlas.yaml) |

## Atlas

Atlas sets how this repo is worked on: design, approval, build, proof and
learnings. It is a Claude Code plugin from the Atlas repo.

- Follow the `atlas:lead` skill in every session in this repo, from the first
  reply.
- Atlas areas: every folder of the repo.
- CI runs the Atlas shape check, `.github/atlas/check.mjs`. Atlas writes that
  file and its workflow. Do not edit them by hand.
- Every file under `docs/` is listed in [docs/index.md](docs/index.md).

## Writing standards

Write prose in ASD-STE100: short sentences, active voice, plain words.
