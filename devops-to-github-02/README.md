# Migrate an Azure DevOps Git repository to GitHub

This article shows two ways to copy an Azure DevOps Git repository to GitHub:

- **Use Git** to push a local copy into an empty GitHub repository.
- **Use GitHub CLI (`gh`)** to create the GitHub repository and push a local copy.

Both methods copy source code, commit history, branches, and tags. They do not migrate Azure DevOps pull requests, work items, pipelines, or repository settings.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/migrate-public-project?view=azure-devops))


## Theory

https://learn.github.com/well-architected/scenarios/migrations/repository-checklist

# Key differences between Azure DevOps and GitHub

Core workflows like repository access, authentication, and pull requests differ after moving from Azure DevOps to GitHub.

If you're a member of an organization that has migrated from Azure DevOps to GitHub, this guide will explain the changes in your workflows to make the migration as smooth as possible.

## Structure

In Azure DevOps, repositories are nested inside **team projects**, so the structure of your environment looks like this:

* Organization
  * Team project
    * Repositories
  * Team project
    * Repositories

Permissions and visibility flow from the team project.

GitHub is structured differently. Repositories are nested directly inside **organizations**, which also contain teams:

* Enterprise account
  * Organization
    * Teams
    * Repositories
  * Organization
    * Teams
    * Repositories

Permissions and visibility are determined by a combination of organization membership, team membership, and individual permissions.

The concept of a team project, which is used to group repositories in Azure DevOps, does not exist in GitHub and treating organizations in GitHub as the equivalent of team projects is not recommended.

While you may initially find each migrated organization on GitHub has a long unorganized list of repositories, you can grant access and permissions via teams of organization members, which makes navigating the organization's repositories a lot easier.

## Authentication, permissions, and teams

There are two methods for authenticating to GitHub. Which method you use will depend on how the enterprise account is configured.

If your enterprise account uses Enterprise Managed Users, you'll sign in to GitHub via your identity provider (for example, Entra ID) and use a **provisioned** account tied to the enterprise account.

Otherwise, you'll use a **personal** GitHub account. That account will be invited to the enterprise account and any organizations you'll work in. If the enterprise account is configured with additional SAML access restrictions, your personal account will be **linked** to your IdP. You'll be prompted to authenticate with the IdP when you need to access resources within the enterprise account.

In an enterprise on GitHub, repositories can be public, private, or internal. Private repositories are only visible to people and teams with explicit access, and internal repositories are visible to all members of your enterprise but not to people outside the enterprise. Internal repositories are useful when multiple organizations in the same enterprise need to discover and reuse code. If your enterprise uses Enterprise Managed Users, user accounts cannot create public repositories or other public content.

## Using Git

To continue working on your repositories using Git, you'll need to make some changes.

1. Update the remote URLs to point at GitHub. See [Managing remote repositories](/en/get-started/git-basics/managing-remote-repositories).
2. Update how you authenticate.
   * To use HTTPS authentication, you'll need to create a personal access token. See [Managing your personal access tokens](/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).
   * To use SSH authentication, you'll need to either create or add an existing SSH key to GitHub. See [Connecting to GitHub with SSH](/en/authentication/connecting-to-github-with-ssh).
3. If your enterprise or organization uses SAML single sign-on (SSO), you must authorize your personal access token or SSH key before it can access resources.

## Pull request flow

With your codebase now hosted on GitHub, you'll propose changes using pull requests created in your GitHub repositories.

If your enterprise has integrated Azure Boards and Pipelines, these will both function with GitHub. You can continue to reference work items in your commit messages and pull requests. For example: `Fix login bug (AB#1234)`.

You can continue to view and manage your work items on Azure Boards. You can also link branches, commits, and pull requests to work items from within Azure. See [Link GitHub commits, pull requests, branches, and issues to work items in Azure Boards](https://learn.microsoft.com/en-us/azure/devops/boards/github/link-to-from-github) on Microsoft Learn.

## Branch protections

People with admin access to a repository can configure **branch protection rules** on GitHub. These are similar to **branch policies** on Azure DevOps and set rules such as a minimum number of approving reviewers, successful status checks, and requiring signed commits.

GitHub also supports automatically assigning reviewers based on the file, folder, and glob patterns in a repository's CODEOWNERS file. See [About code owners](/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).

## Packages and artifacts

In Azure DevOps, you may have used Azure Artifacts to publish and consume packages (for example, NuGet packages, npm packages, or Maven packages) and to store build artifacts produced by Azure Pipelines.

On GitHub, packages are typically published to GitHub Packages and associated with a repository or organization. Depending on how your enterprise completed the migration, you may continue to publish packages to Azure Artifacts, move packages to GitHub Packages, or use a combination of both.

If you can no longer restore dependencies after the migration, check your package source configuration. For example, you may need to update a registry URL or credentials in files like `nuget.config`, `.npmrc`, `settings.xml`, or in your pipeline configuration.

For more information, see [Introduction to GitHub Packages](/en/packages/learn-github-packages/introduction-to-github-packages).

## GitHub Copilot

Hosting your repositories on GitHub unlocks the full power of Copilot. Your codebase provides Copilot with all the context it needs to answer questions in Copilot Chat, review and make suggestions in your pull requests, and even make changes on your behalf with Copilot cloud agent.

See [Quickstart for using GitHub Copilot on GitHub.com](/en/copilot/get-started/quickstart-for-using-github-copilot-on-github-com).

## Prerequisites

| Requirement | Details |
| --- | --- |
| **Azure DevOps access** | Permission to read and clone the source Git repository |
| **GitHub access** | Permission to create a repository or write to an existing empty repository |
| **Git** | Installed locally |
| **GitHub CLI** | Required only for the `gh` method |
| **Git LFS** | Required if the source repository uses Git Large File Storage |
| **Local storage** | Enough space for the repository history and any LFS files |

Before migrating, push any local changes you want included and ask collaborators to pause pushes during the final copy.

> **Important**
>
> These instructions apply to **Azure Repos Git**, not Team Foundation Version Control (TFVC). Keep the Azure repository until the GitHub copy has been verified.

## Choose a copying method

| Method | Advantages | Limitations |
| --- | --- | --- |
| **Git** | Explicit control over the destination; supports a dry-run preview; works with an existing empty GitHub repository | Create the GitHub repository and configure authentication separately |
| **GitHub CLI (`gh`)** | Creates the repository from the terminal; simplifies GitHub sign-in; convenient for scripting | Requires Git and `gh`; the creation command requires a new repository name; Azure authentication remains separate |

GitHub CLI still uses Git for the repository transfer. With a bare source repository, `gh repo create --push` mirrors all references. It does not bypass GitHub limits or provide a full Azure DevOps project migration.  ([cli.github.com](https://cli.github.com/manual/gh_repo_create))

## Copy using Git

Create an empty GitHub repository, clone Azure DevOps locally, and push the copy.

1. In GitHub, create a repository under the appropriate account or organization.

   Choose the required visibility. **Do not initialize the repository with a README, license, or `.gitignore`.**

2. In Azure DevOps, open **Repos → Files → Clone** and copy the HTTPS clone URL.

3. Create a bare clone:

   ```bash
   git clone --bare \
     "https://dev.azure.com/{organization}/{project}/_git/{repo}" \
     migration.git

   cd migration.git
   ```

4. Add GitHub as a separate remote:

   ```bash
   git remote add github \
     "https://github.com/{owner}/{new-repo}.git"

   git remote -v
   ```

   Confirm that `origin` points to Azure DevOps and `github` points to GitHub.

5. If the repository uses Git LFS, transfer its large-file contents:

   ```bash
   git lfs fetch --all origin
   git lfs push --all github
   ```

   Skip this step if the repository does not use LFS.

6. Preview the push, then copy the repository:

   ```bash
   git push --dry-run --mirror github
   git push --mirror github
   ```

This follows the bare-clone and mirror-push approach used for command-line repository imports. LFS contents require a separate transfer.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/migrate-public-project?view=azure-devops))

> **Important**
>
> A mirror push can overwrite destination references and delete references absent from the local copy. Use it only against an empty destination or one you intentionally want to replace.  ([git-scm.com](https://git-scm.com/docs/git-push))

> **Note**
>
> Git Credential Manager can handle HTTPS authentication to Azure DevOps and GitHub, including multifactor authentication. Complete the sign-in prompts rather than placing credentials in repository URLs.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/repos/git/set-up-credential-managers?view=azure-devops))

## Copy using GitHub CLI (`gh`)

Use Git to clone Azure DevOps, then use GitHub CLI to create and populate the destination.

1. Authenticate with GitHub:

   ```bash
   gh auth login --hostname github.com --git-protocol https --web
   gh auth setup-git
   gh auth status
   ```

   Complete the browser sign-in and confirm the correct GitHub account. `gh auth setup-git` configures Git to use GitHub CLI for GitHub authentication.  ([docs.github.com](https://docs.github.com/github-cli/github-cli/authenticating-with-github-cli))

2. In Azure DevOps, open **Repos → Files → Clone** and copy the HTTPS clone URL.

3. Create a bare clone:

   ```bash
   git clone --bare \
     "https://dev.azure.com/{organization}/{project}/_git/{repo}" \
     migration.git

   cd migration.git
   ```

4. Create and populate the GitHub repository:

   ```bash
   gh repo create {owner}/{new-repo} \
     --private \
     --source=. \
     --remote=github \
     --push
   ```

   Replace `--private` with `--public` only if public access is intentional.

   Because the source is a **bare repository**, `--push` mirrors all references. The command also adds a remote named `github`.  ([cli.github.com](https://cli.github.com/manual/gh_repo_create))

5. **If the repository uses LFS**, use the following sequence instead of step 4. Create the repository without an immediate push, then transfer LFS contents and Git history:

   ```bash
   gh repo create {owner}/{new-repo} \
     --private \
     --source=. \
     --remote=github

   git lfs fetch --all origin
   git lfs push --all github

   git push --dry-run --mirror github
   git push --mirror github
   ```

   This separates repository creation from the LFS and Git transfers, making failures easier to diagnose.  ([cli.github.com](https://cli.github.com/manual/gh_repo_create))

> **Note**
>
> GitHub CLI authentication does not authenticate you to Azure DevOps. Complete the Azure sign-in separately when cloning.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/repos/git/set-up-credential-managers?view=azure-devops))

> **Important**
>
> If repository creation succeeds but the push fails, do not rerun `gh repo create`. Resolve the reported error and retry the transfer:
>
> ```bash
> git remote -v
> git push --mirror github
> ```

## Verify the repository

After either method, compare the branches and tags, then test a fresh clone.

1. From `migration.git`, run the following in Bash or Git Bash:

   ```bash
   git ls-remote origin 'refs/heads/*' 'refs/tags/*' \
     | sort > ../azure-refs.txt

   git ls-remote github 'refs/heads/*' 'refs/tags/*' \
     | sort > ../github-refs.txt

   diff -u ../azure-refs.txt ../github-refs.txt
   ```

   No output from `diff` means the generated reference lists match. This compares branch and tag names and object IDs—not LFS contents or hosting settings.  ([git-scm.com](https://git-scm.com/docs/git-ls-remote.html))

2. Clone GitHub into a new working folder:

   ```bash
   cd ..

   git clone \
     "https://github.com/{owner}/{new-repo}.git" \
     github-project

   cd github-project
   ```

3. Check important branches and tags, run your build and tests, and confirm LFS files are available.

4. Review the default branch and test access with a normal developer account.

> **Note**
>
> If you intentionally rewrote history, the Azure and GitHub commit IDs will differ. Compare GitHub against your rewritten migration copy instead.

## Limitations and common issues

The following issues apply to both copying methods.

### Large files

GitHub applies these limits to individual files stored in ordinary Git:

| File size | Result |
| --- | --- |
| Up to 50 MiB | No file-size warning |
| Over 50 MiB, up to 100 MiB | Warning |
| Over 100 MiB | Push rejected |

These are per-file limits, not a total-project limit.  ([docs.github.com](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github))

**Deleted files still count.** An oversized file committed years ago remains in earlier commits even if it was later deleted. Deleting it now or adding it to `.gitignore` does not remove it from history.  ([docs.github.com](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github))

To resolve a rejection:

- Convert the affected files and history to Git LFS if they must be retained.
- Remove unnecessary files from the affected history.

The `git lfs fetch` and `git lfs push` commands only transfer files already stored in LFS. Conversion requires a separate operation, such as `git lfs migrate`, which rewrites commits and changes commit IDs. Back up the migration copy before doing this.  ([github.com](https://github.com/git-lfs/git-lfs/blob/main/docs/man/git-lfs-migrate.adoc))

### Large initial push

GitHub limits a single push to **2 GiB**. A large migration may fail with:

```text
pack exceeds maximum allowed size
```

Split the transfer into smaller pushes. Separate branches may be sufficient; a very large branch may require pushing intermediate commits in batches. This is not a 2 GiB total-repository limit.  ([docs.github.com](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit))

### Git LFS capacity

LFS has plan-dependent maximum file sizes and separate storage and bandwidth usage. Review the destination account’s allowances before migrating large binaries or datasets.  ([docs.github.com](https://docs.github.com/en/repositories/working-with-files/managing-large-files))

### Authentication and permissions

If cloning, creation, or pushing fails, check the source access, destination write access, account selection, and organization requirements.

For the CLI method, `gh auth status` checks GitHub authentication only. Creating an organization repository also requires the appropriate creation permission.  ([cli.github.com](https://cli.github.com/manual/gh_repo_create))

### Secrets and destination protections

GitHub push protection can block secrets found in the commits being migrated. Review the reported secret, rotate real exposed credentials, and remove them from the affected history rather than bypassing protection simply to finish the migration.  ([docs.github.com](https://docs.github.com/en/code-security/concepts/secret-security/command-line-push-protection))

Server-side rules can also reject reference updates. Review the exact rejection with the repository administrator before retrying.  ([git-scm.com](https://git-scm.com/docs/git-push))

### Azure DevOps data outside Git

Neither method automatically migrates pull requests, work items, permissions, branch policies, pipeline secrets, service connections, package feeds, or separately stored wiki repositories. Plan these separately.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/migrate-public-project?view=azure-devops))

An `azure-pipelines.yml` file is copied as source code, but does not automatically become a GitHub Actions workflow. Reconnect Azure Pipelines to GitHub or plan a separate pipeline migration.  ([learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/migrate-public-project?view=azure-devops))

> **Tip**
>
> If you need to preserve pull-request data, evaluate **GitHub Enterprise Importer** rather than a Git-only copy. Its Azure DevOps workflow uses the **ADO2GH GitHub CLI extension**, which is different from `gh repo create`:
>
> ```bash
> gh extension install github/gh-ado2gh
> ```
>
> Review its eligibility, permissions, and data limitations before proceeding.  ([docs.github.com](https://docs.github.com/en/migrations/ado/install-and-configure-github-enterprise-importer))

## Post-migration checklist

- [ ] Branches and tags match the intended migration copy.
- [ ] LFS transfers completed successfully.
- [ ] A fresh clone builds and passes tests.
- [ ] Default branch, permissions, and protections are configured.
- [ ] CI/CD and deployments work.
- [ ] Submodule URLs, scripts, integrations, and documentation were reviewed.
- [ ] Collaboration data has a migration or retention plan.
- [ ] Collaborators know GitHub is the new source of truth.
- [ ] Azure remains available until the migration is accepted.

To update an existing developer checkout:

```bash
git remote set-url origin \
  "https://github.com/{owner}/{new-repo}.git"

git remote -v
git fetch origin
```

Prefer fresh clones if history was rewritten. Make the Azure repository read-only during the transition where practical.