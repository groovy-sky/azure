#!/usr/bin/env bash
set -euo pipefail

cd /opt/actions-runner

fetch_registration_token() {
  local trimmed endpoint response code body token
  local -a candidates=()

  trimmed="${GITHUB_URL%/}"
  if [[ "${trimmed}" =~ ^https://github\.com/([^/]+)/([^/]+)$ ]]; then
    candidates+=("repos/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}")
  elif [[ "${trimmed}" =~ ^https://github\.com/([^/]+)$ ]]; then
    candidates+=("orgs/${BASH_REMATCH[1]}")
  else
    echo "Unsupported GITHUB_URL format: ${GITHUB_URL}" >&2
    echo "Expected https://github.com/ORG or https://github.com/OWNER/REPO" >&2
    return 1
  fi

  for candidate in "${candidates[@]}"; do
    endpoint="https://api.github.com/${candidate}/actions/runners/registration-token"
    response="$(curl -sS \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -H "Authorization: Bearer ${GITHUB_PAT}" \
      -w $'\n%{http_code}' \
      "${endpoint}")"

    code="${response##*$'\n'}"
    body="${response%$'\n'*}"

    if [[ "${code}" == "404" ]]; then
      continue
    fi

    if [[ "${code}" != "200" && "${code}" != "201" ]]; then
      echo "GitHub API call failed (${code}) at ${endpoint}" >&2
      [[ -n "${body}" ]] && echo "${body}" >&2
      return 1
    fi

    token="$(jq -r '.token // empty' <<< "${body}")"
    if [[ -n "${token}" ]]; then
      printf '%s\n' "${token}"
      return 0
    fi
  done

  if [[ "${trimmed}" =~ ^https://github\.com/([^/]+)$ ]]; then
    echo "Failed to fetch registration token from GitHub API for organization '${BASH_REMATCH[1]}'." >&2
    echo "If this is a personal account, use a repository URL instead: https://github.com/OWNER/REPO" >&2
    return 1
  fi

  echo "Failed to fetch registration token from GitHub API." >&2
  return 1
}

# Required runtime env:
#   GITHUB_URL   -> https://github.com/<org-or-user>/<repo> OR https://github.com/<org>
#   RUNNER_TOKEN -> registration token
#
# Optional:
#   GITHUB_PAT (used to dynamically mint registration token)
#   RUNNER_NAME (default: hostname)
#   RUNNER_LABELS (comma-separated)
#   RUNNER_GROUP
#   RUNNER_WORKDIR (default: _work)
#   EPHEMERAL (default: true)
#   DISABLE_AUTO_UPDATE (default: true)

: "${GITHUB_URL:?GITHUB_URL is required}"

if [[ -z "${RUNNER_TOKEN:-}" && -z "${GITHUB_PAT:-}" ]]; then
  echo "Either RUNNER_TOKEN or GITHUB_PAT must be provided." >&2
  exit 1
fi

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-_work}"
EPHEMERAL="${EPHEMERAL:-true}"
DISABLE_AUTO_UPDATE="${DISABLE_AUTO_UPDATE:-true}"

if [[ -n "${GITHUB_PAT:-}" ]]; then
  echo "Fetching short-lived registration token using GITHUB_PAT..."
  RUNNER_TOKEN="$(fetch_registration_token)"
elif [[ "${RUNNER_TOKEN:-}" == github_pat_* ]]; then
  echo "RUNNER_TOKEN appears to be a PAT, but this field requires a runner registration token." >&2
  echo "Set GITHUB_PAT instead, or provide a short-lived registration token in RUNNER_TOKEN." >&2
  exit 1
fi

CONFIG_ARGS=(
  --url "${GITHUB_URL}"
  --token "${RUNNER_TOKEN}"
  --name "${RUNNER_NAME}"
  --work "${RUNNER_WORKDIR}"
  --unattended
  --replace
)

if [[ -n "${RUNNER_LABELS:-}" ]]; then
  CONFIG_ARGS+=(--labels "${RUNNER_LABELS}")
fi

if [[ -n "${RUNNER_GROUP:-}" ]]; then
  CONFIG_ARGS+=(--runnergroup "${RUNNER_GROUP}")
fi

if [[ "${EPHEMERAL}" == "true" ]]; then
  CONFIG_ARGS+=(--ephemeral)
fi

if [[ "${DISABLE_AUTO_UPDATE}" == "true" ]]; then
  CONFIG_ARGS+=(--disableupdate)
fi

echo "Configuring runner ${RUNNER_NAME}..."
./config.sh "${CONFIG_ARGS[@]}"
