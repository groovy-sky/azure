# Running a Self-hosted GitHub Actions Runner in Docker

## Introduction

Containers are one of the simplest ways to package repeatable runtime environments for CI/CD workloads. For GitHub Actions, this approach allows you to run your own self-hosted runners with full control over tools, lifecycle, and security boundaries.

This folder demonstrates how to run a self-hosted GitHub Actions runner inside Docker, using a custom image based on Ubuntu 24.04. The runner binary is prepared during image build, and startup/shutdown automation is handled by [entrypoint.sh](entrypoint.sh).

The goal of this tutorial is to walk through the full process in a practical, step-by-step format.

## Theoretical Part

### GitHub Actions runners

To execute a GitHub Actions job, you need a runner. GitHub provides hosted runners by default, but you can also register and manage your own self-hosted runners.

Self-hosted runners are useful when:

- You need custom software that is not present in hosted images.
- You need private network access to internal resources.
- You want persistent local caches to improve build speed.
- You need specific compliance or security controls.

### GitHub-hosted runners vs self-hosted runners

#### GitHub-hosted runners

GitHub-hosted runners are fully managed. Each workflow job runs on a fresh environment and the runtime is recycled after execution. This is usually the fastest way to start.

#### Self-hosted runners

Self-hosted runners are managed by you. You control image content, runtime options, labels, scaling strategy, and patching cadence.

In exchange, you also own:

- System hardening
- Capacity planning
- Upgrades and break/fix operations

### Ephemeral and persistent runner modes

This image defaults to ephemeral mode (`EPHEMERAL=true`). In ephemeral mode, a runner processes one job and then exits registration lifecycle, which improves isolation.

Persistent mode (`EPHEMERAL=false`) keeps the same runner registered across multiple jobs. This can be useful for stable long-running environments, but requires stronger hygiene and monitoring.

### Authentication and token model

Runner registration requires a short-lived registration token.

You can provide this in two ways:

- Direct token flow: pass `RUNNER_TOKEN`.
- PAT flow: pass `GITHUB_PAT` and let the container request short-lived registration/remove tokens at runtime.

Important considerations:

- `RUNNER_TOKEN` must be a short-lived runner registration token.
- `RUNNER_TOKEN` is not a PAT and should never contain a PAT value.
- PAT permissions depend on scope (repository or organization runner).

### Runner scope

Runner scope is determined by `GITHUB_URL`:

- Repository runner: `https://github.com/OWNER/REPO`
- Organization runner: `https://github.com/ORG`

For personal account scenarios, use repository scope.

## Prerequisites

Before starting the practical section, make sure you have:

- Docker installed on the host machine.
- Outbound HTTPS connectivity to GitHub endpoints.
- A GitHub repository or organization where runners can be registered.
- A short-lived runner registration token or a PAT with appropriate runner-management permissions.

## Practical Part

To run this demo, complete the following:

1. Build the Docker image.
2. Obtain authentication material (registration token or PAT).
3. Start the containerized runner.
4. Verify runner connectivity and execute a test workflow.

### 1. Build Docker image

Run from this folder:

```sh
docker build -t gh-self-hosted-runner:latest .
```

Optional platform-specific builds:

```sh
# amd64
docker build --platform linux/amd64 -t gh-self-hosted-runner:amd64 .

# arm64
docker build --platform linux/arm64 -t gh-self-hosted-runner:arm64 .
```

### 2. Generate credentials for runner registration

You can create a short-lived token from GitHub UI:

- Repository: `Settings -> Actions -> Runners -> New self-hosted runner`
- Organization: `Settings -> Actions -> Runners -> New runner`

Alternatively, request a registration token via API:

```sh
export GITHUB_PAT="YOUR_PAT"
export OWNER="your-org"
export REPO="your-repo"

curl -sSL \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_PAT}" \
  "https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token"
```

Use the returned `token` value as `RUNNER_TOKEN`.

If you prefer PAT-based automation, provide `GITHUB_PAT` when starting the container and let the startup script mint short-lived registration/remove tokens automatically.

### 3. Start the self-hosted runner container

#### Repository runner example

```sh
docker run -d --name gh-runner-01 \
  --restart unless-stopped \
  -e GITHUB_URL="https://github.com/OWNER/REPO" \
  -e GITHUB_PAT="GITHUB_PAT_WITH_REPO_RUNNER_SCOPE" \
  -e RUNNER_NAME="runner-01" \
  -e RUNNER_LABELS="self-hosted,linux,x64,docker" \
  -e RUNNER_WORKDIR="_work" \
  gh-self-hosted-runner:latest
```

#### Organization runner example

```sh
docker run -d --name gh-org-runner-01 \
  --restart unless-stopped \
  -e GITHUB_URL="https://github.com/ORG" \
  -e GITHUB_PAT="GITHUB_PAT_WITH_ADMIN_ORG_SCOPE" \
  -e RUNNER_NAME="org-runner-01" \
  -e RUNNER_GROUP="default" \
  -e RUNNER_LABELS="self-hosted,linux,x64,docker" \
  gh-self-hosted-runner:latest
```

You can replace `GITHUB_PAT` with `RUNNER_TOKEN`, but the token must be short-lived and valid for registration.

### 4. Runtime variables reference

Required:

- `GITHUB_URL`: `https://github.com/OWNER/REPO` or `https://github.com/ORG`

Choose one:

- `RUNNER_TOKEN`: short-lived registration token
- `GITHUB_PAT`: PAT used to request short-lived registration/remove tokens

Optional:

- `RUNNER_NAME`: defaults to container hostname
- `RUNNER_LABELS`: comma-separated runner labels
- `RUNNER_GROUP`: organization runner group (org scope only)
- `RUNNER_WORKDIR`: default `_work`
- `EPHEMERAL`: default `true`
- `DISABLE_AUTO_UPDATE`: default `true`

Examples:

```sh
# Keep runner persistent
-e EPHEMERAL="false"

# Enable auto-update
-e DISABLE_AUTO_UPDATE="false"
```

### 5. Verify runner registration

Follow runner logs:

```sh
docker logs -f gh-runner-01
```

Then verify in GitHub UI:

- Repository scope: `Settings -> Actions -> Runners`
- Organization scope: `Settings -> Actions -> Runners`

If registration succeeded, the runner status should be online.

### 6. Test with a workflow

Create or trigger a workflow that targets the same labels configured in `RUNNER_LABELS`.

```yaml
name: Self-hosted Docker runner test

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: [self-hosted, linux, x64, docker]
    steps:
      - uses: actions/checkout@v4
      - name: Show runner context
        run: |
          hostname
          whoami
          pwd
```

### 7. Stop and remove

```sh
docker stop gh-runner-01
docker rm gh-runner-01
```

On stop, [entrypoint.sh](entrypoint.sh) attempts `config.sh remove` using a valid remove token. When `GITHUB_PAT` is available, it first requests a short-lived remove token from the API.

## Results

If all steps were completed successfully, your runner should:

- Appear in the target repository or organization runner list.
- Accept jobs matching configured labels.
- Execute workflow steps inside the container environment.

In ephemeral mode, each runner instance handles one job lifecycle and then exits cleanly.

## Summary

This tutorial demonstrated how to run a Dockerized GitHub Actions self-hosted runner with a practical registration model, token strategy, and validation workflow.

The same approach can be extended with autoscaling, image hardening, and environment-specific labels for production-grade CI/CD execution.

## Security Notes

- Treat self-hosted runners as trusted infrastructure.
- Avoid storing long-lived secrets on the host.
- Prefer ephemeral execution for better job isolation.
- Separate runners by repository, team, or trust boundary using labels and groups.

## Related Information

- GitHub Actions self-hosted runners: LINK_PLACEHOLDER
- GitHub REST API for runner registration tokens: LINK_PLACEHOLDER
- Docker hardening guidance: LINK_PLACEHOLDER
- GitHub Actions security hardening: LINK_PLACEHOLDER
