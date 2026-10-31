# Migrate from Azure DevOps to GitHub (part 3)

## Introduction

This document explains how to move a Git repository from Azure DevOps to GitHub. It covers the migration scope, preparation, transfer options, and basic verification.

For migrations to **GitHub Enterprise Cloud**, you can also use [GitHub Enterprise Importer](https://github.com/github/gh-gei), a dedicated migration tool. For Azure DevOps migrations, use its `gh ado2gh` GitHub CLI extension rather than `gh gei`, which is intended for migrations between GitHub products. See the linked project's Azure DevOps instructions for setup and usage.

## Prerequisites

You need access to clone the Azure DevOps repository and create or update the destination repository on GitHub.

The commands below use Git. Depending on your preferred transfer method and repository contents, you may also need:

- **GitHub CLI:** Optional, if you want to create the destination from the terminal instead of using pure Git for the transfer.
- **Git LFS:** Required if the repository already uses LFS. Large files stored in ordinary Git may need conversion before migration.

Before the final copy, push any changes that must be included and ask collaborators to pause pushes to Azure DevOps.

### Command conventions

Run the examples in Bash or Git Bash and replace the placeholders with your repository details.

Copy the source URL from **Azure DevOps → Repos → Files → Clone**. The destination URL follows this format:

```text
https://github.com/{owner}/{new-repo}.git
```

Choose one transfer option and use a fresh local directory.

## Option 1: Use Git

### 1. Create an empty GitHub repository

Create the repository under the intended user or organization.

Do **not** add a README, license, or `.gitignore`.

### 2. Clone Azure DevOps and add GitHub

```bash
git clone --bare \
  "https://dev.azure.com/{organization}/{project}/_git/{repo}" \
  migration.git

cd migration.git

git remote add github \
  "https://github.com/{owner}/{new-repo}.git"
```

Check that the remote URLs are correct:

```bash
git remote -v
```

`origin` should point to Azure DevOps, and `github` should point to GitHub.

### 3. Transfer LFS objects, if applicable

Skip this step if the repository does not use Git LFS.

```bash
git lfs fetch --all origin &&
git lfs push --all github
```

Resolve any errors before continuing.

### 4. Push to GitHub

```bash
git push --dry-run --mirror github &&
git push --mirror github
```

## Option 2: Use GitHub CLI

### 1. Authenticate with GitHub

```bash
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
gh auth status
```

Confirm that the intended GitHub account is signed in.

GitHub CLI does not authenticate you to Azure DevOps. Complete the Azure sign-in separately when cloning.

### 2. Clone Azure DevOps

```bash
git clone --bare \
  "https://dev.azure.com/{organization}/{project}/_git/{repo}" \
  migration.git

cd migration.git
```

### 3. Create and populate GitHub

**If the repository does not use LFS:**

```bash
gh repo create {owner}/{new-repo} \
  --private \
  --source=. \
  --remote=github \
  --push
```

Because the source is a bare repository, `--push` mirrors its references.

**If the repository uses LFS:**

Create the destination without pushing immediately:

```bash
gh repo create {owner}/{new-repo} \
  --private \
  --source=. \
  --remote=github
```

Then transfer LFS objects and Git history:

```bash
git lfs fetch --all origin &&
git lfs push --all github &&
git push --dry-run --mirror github &&
git push --mirror github
```


## Verify the migration

Open the destination repository in your web browser:

```text
https://github.com/{owner}/{new-repo}
```

Check that the expected files, branches, tags, and commit history are visible and that the default branch is correct.

This is a basic visual check; it does not verify LFS downloads or integrations.

## Complete the transition

- [ ] Configure repository access and branch protections.
- [ ] Reconnect pipelines, package feeds, and other integrations.
- [ ] Update repository links in scripts and documentation.
- [ ] Tell collaborators that GitHub is the new source of truth.
- [ ] Keep Azure available until the migration is accepted.

Developers can update an existing checkout:

```bash
git remote set-url origin \
  "https://github.com/{owner}/{new-repo}.git"

git remote -v
git fetch origin
```

Prefer fresh clones if history was rewritten. Make Azure read-only during the transition where practical.
