# Objective

Design a simple, cost-efficient setup that lets developers push and deploy backend code directly to Backend.im using the Claude Code CLI and other open-source tools — with minimal manual configuration.

## Architecture Overview

Developer → Claude Code CLI → Git/Container Registry → Backend.im
                             ↘ (optional) CI (GitHub Actions)


## Local developer flow

Developer runs claude code run -- ./deploy.sh

Script builds the image (or uses Buildpacks), pushes to registry, and calls Backend.im’s deploy API.

Claude Code orchestrates the steps and prompts for any missing variables.

## CI/CD flow

On every git push, GitHub Actions repeats the same steps automatically for consistency.

## Backend.im

Receives the deploy request, provisions or updates the service container, and exposes the live endpoint.

## Chosen Tools & Reasons
| Tool                                 | Purpose                           | Why Chosen                                   |
| ------------------------------------ | --------------------------------- | -------------------------------------------- |
| **Claude Code CLI**                  | Command-oriented deployment flow  | Natural-language + automation; minimal setup |
| **Docker / Buildpacks**              | Build lightweight container image | Open source, reproducible, portable          |
| **GitHub Actions**                   | CI/CD automation                  | Free, easy to integrate                      |
| **Backend.im API / CLI**             | Final deployment target           | Enables remote service creation              |
| **cURL / Shell script**              | Simple deploy implementation      | Zero dependency, transparent                 |
| **GitHub Container Registry (GHCR)** | Image storage                     | Secure, free tier, integrates with Actions   |

## Minimal Custom Code

deploy.sh — tiny (~40 lines) script that:

1. Runs tests

2. Builds & pushes container image

3. Calls Backend.im deploy API

4. Runs post-deploy smoke tests

Everything else uses off-the-shelf open-source tooling.

## High-Level Deployment Sequence

1.  Developer commits code
2️. Claude Code runs deploy.sh
3️.  Image built & pushed to registry
4️.  Backend.im API triggered → new revision deployed
5️. Smoke tests confirm success
6️. (CI mirrors same pipeline on push)

## Reasoning & Trade-offs

1. Simplicity: prefer lightweight scripts over heavy IaC for this use case.

2. Cost-Efficiency: relies only on free/open-source tools (Docker, GH Actions, Claude CLI).

3. Reproducibility: both local and CI paths use the same deployment logic.

4. Extensibility: easy to extend later with Terraform modules, canary rollouts, or monitoring hooks.

## Outcome

This design delivers a one-command deployment flow:

claude code run -- ./deploy.sh

→ Application built, tested, pushed, and deployed live on Backend.im
— with zero manual infrastructure steps.
