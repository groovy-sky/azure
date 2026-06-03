# Dockerized GitHub Actions Self-hosted Runner

This folder provides a Docker image for running a GitHub Actions self-hosted runner.

The image is based on Ubuntu 24.04, downloads the latest `actions/runner` release at build time, and starts the runner via [entrypoint.sh](entrypoint.sh).

## What this image does

- Builds the runner binary during image build.
- Runs as non-root user `runner` (UID 1001).
- Configures the runner at container startup using environment variables.
- Runs in unattended mode and replaces an existing runner with the same name.
- Defaults to ephemeral runner mode.
- Attempts runner deregistration on container stop.

## Prerequisites

- Docker installed on the host.
- Outbound HTTPS access to GitHub endpoints.
- A short-lived runner registration token from GitHub UI or REST API.

## 1. Build the image

From this folder:

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

## 2. Create a registration token

You can get a runner token from:

- Repository: `Settings -> Actions -> Runners -> New self-hosted runner`
- Organization: `Settings -> Actions -> Runners -> New runner`

Or use the API.

Repository token API example:

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

Use the `token` value from the response as `RUNNER_TOKEN`.

## 3. Run the container

### Repository runner

```sh
docker run -d --name gh-runner-01 \
  --restart unless-stopped \
  -e GITHUB_URL="https://github.com/OWNER/REPO" \
  -e RUNNER_TOKEN="REGISTRATION_TOKEN" \
  -e RUNNER_NAME="runner-01" \
  -e RUNNER_LABELS="self-hosted,linux,x64,docker" \
  -e RUNNER_WORKDIR="_work" \
  gh-self-hosted-runner:latest
```

### Organization runner

```sh
docker run -it --name gh-org-runner-01 \
  --restart unless-stopped \
  -e GITHUB_URL="https://github.com/ORG" \
  -e GITHUB_PAT="GITHUB_PAT_WITH_ADMIN_ORG_SCOPE" \
  -e RUNNER_NAME="org-runner-01" \
  -e RUNNER_GROUP="default" \
  -e RUNNER_LABELS="self-hosted,linux,x64,docker" \
  gh-self-hosted-runner:latest
```

You can also pass `RUNNER_TOKEN` directly, but it must be a short-lived runner registration token (not a PAT).

## 4. Runtime environment variables

Required:

- `GITHUB_URL`: `https://github.com/OWNER/REPO` or `https://github.com/ORG`

One of:

- `RUNNER_TOKEN`: short-lived registration token
- `GITHUB_PAT`: PAT used to mint short-lived registration/remove tokens at runtime

Optional:

- `RUNNER_NAME`: default is container hostname
- `RUNNER_LABELS`: comma-separated labels
- `RUNNER_GROUP`: organization runner group
- `RUNNER_WORKDIR`: default `_work`
- `EPHEMERAL`: default `true`
- `DISABLE_AUTO_UPDATE`: default `true`

For a persistent (non-ephemeral) runner, add this env var:

```sh
-e EPHEMERAL="false"
```

To enable runner auto-update, add this env var:

```sh
-e DISABLE_AUTO_UPDATE="false"
```

## 5. Verify

Check container logs:

```sh
docker logs -f gh-runner-01
```

Then confirm the runner status in GitHub:

- Repository: `Settings -> Actions -> Runners`
- Organization: `Settings -> Actions -> Runners`

You should see the runner online.

## 6. Stop and remove

```sh
docker stop gh-runner-01
docker rm gh-runner-01
```

On stop, [entrypoint.sh](entrypoint.sh) attempts `config.sh remove` using a valid remove token.
If `GITHUB_PAT` is set, it requests a short-lived remove token from the GitHub API first.

## 7. Workflow example

Use labels that match your container runner labels:

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

## Security notes

- Treat this runner as trusted infrastructure; workflow code runs on your host.
- Avoid exposing long-lived secrets on the runner host.
- Prefer ephemeral runners for better isolation.
- Use separate runner groups and labels for different trust levels.
