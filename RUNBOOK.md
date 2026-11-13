# Runbook: Configure GitHub Access on macOS Using Fine-grained PAT

**Document type:** Technical Runbook  
**Platform:** macOS  
**Authentication:** GitHub Fine-grained Personal Access Token (PAT)  
**Credential storage:** macOS Keychain  
**Access scope:** One selected GitHub repository

---

## 1. Objective

Configure Git authentication on a Mac machine using a GitHub Fine-grained Personal Access Token.

The token must:
- Access only explicitly selected repositories.
- Support cloning, pulling and pushing code.
- Avoid granting access to other private repositories.
- Store credentials securely in macOS Keychain.
- Have a limited expiration period.

## 2. Prerequisites

- A GitHub account with access to the target repository.
- Git installed on the Mac.
- Access to GitHub account settings.
- Repository name and GitHub username.

Check Git installation:

```bash
git --version
```

If Git is not installed, install Apple's Command Line Tools:

```bash
xcode-select --install
```

## 3. Generate a Fine-grained Personal Access Token

1. Open the GitHub token creation page:

   https://github.com/settings/personal-access-tokens/new

2. Configure the following:

| Setting | Configuration |
|---|---|
| Token name | mac-repo-access |
| Description | Git access for Mac machine |
| Expiration | 90 days |
| Resource owner | Your GitHub account |
| Repository access | Only select repositories |
| Selected repositories | Choose the required repository |

3. Configure repository permissions:

| Permission | Access |
|---|---|
| Contents | Read and write |
| Metadata | Read-only (automatic) |
| Pull requests | No access (optional) |
| Issues | No access |
| Workflows | No access |

**Note:** Contents: Read and write is sufficient for normal Git clone, pull and push operations. Additional permissions should only be granted when required.

4. Click **Generate token**.
5. Copy the generated token and store it temporarily in a secure location.

**Security:** Never share the token or commit it to a Git repository.

## 4. Configure Git Credential Storage on macOS

Open Terminal.

Configure Git to use macOS Keychain:

```bash
git config --global credential.helper osxkeychain
```

Enable repository-specific credential storage:

```bash
git config --global credential.useHttpPath true
```

Verify the configuration:

```bash
git config --global --get credential.helper
git config --global --get credential.useHttpPath
```

Expected output:

```text
osxkeychain
true
```

## 5. Clone the Repository

Use the HTTPS repository URL:

```bash
git clone https://github.com/USERNAME/REPOSITORY.git
```

Replace `USERNAME` and `REPOSITORY` with the actual GitHub username and repository name.

When prompted for credentials:

```text
Username: YOUR_GITHUB_USERNAME
Password: YOUR_FINE_GRAINED_PAT
```

Paste the generated PAT as the password.

macOS Keychain should securely store the credentials for future Git operations.

## 6. Verify Repository Access

Navigate into the cloned repository:

```bash
cd REPOSITORY
```

Check the remote URL:

```bash
git remote -v
```

Test repository access:

```bash
git ls-remote origin
```

If repository references are displayed, authentication and read access are working.

To verify write access, create a test branch and push it:

```bash
git switch -c test-pat-access
git push -u origin test-pat-access
```

Delete the test branch afterward if it is no longer needed:

```bash
git push origin --delete test-pat-access
git switch -
git branch -D test-pat-access
```

## 7. Daily Git Operations

Once authentication is configured, use Git normally.

Pull latest changes:

```bash
git pull
```

Stage changes:

```bash
git add .
```

Commit changes:

```bash
git commit -m "Update project"
```

Push changes:

```bash
git push
```

No need to manually enter the PAT for every operation when the credential is correctly stored in Keychain.

## 8. Credential Revocation and Rotation

If the Mac is lost, compromised or no longer requires repository access:

1. Open GitHub Settings.
2. Navigate to Developer settings.
3. Open Fine-grained personal access tokens.
4. Locate `mac-repo-access`.
5. Revoke the token.

Token management:

https://github.com/settings/personal-access-tokens

To rotate a token:

1. Generate a new Fine-grained PAT.
2. Apply the same repository restrictions and permissions.
3. Remove the old GitHub credential from macOS Keychain using Keychain Access.
4. Run a Git operation to authenticate using the new token.
5. Verify access.
6. Revoke the old token.

## 9. Security Checklist

- [ ] Token restricted to the required repository.
- [ ] Contents permission set to Read and write.
- [ ] No unnecessary repository permissions.
- [ ] Token has a 90-day expiration.
- [ ] Git uses macOS Keychain.
- [ ] Repository-specific credential storage enabled.
- [ ] Token is not stored in shell commands or scripts.
- [ ] Token is not committed to source control.
- [ ] Token revocation procedure is understood.

---

## 10. Expected Result

The Mac machine can securely perform Git operations against the selected GitHub repository using HTTPS authentication.

The Fine-grained PAT does not grant access to other private repositories outside its configured scope.

**End of Runbook**
