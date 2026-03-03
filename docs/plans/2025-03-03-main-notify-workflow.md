# Main-Notify GitHub Workflow — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a GitHub Actions workflow that on every push to `main` SSHs to `test-guide@data-infact.com` and touches `/home/wuxianyu/main_update_<datetime>` (server local time).

**Architecture:** Single workflow file using appleboy/ssh-action with password from repo secret; remote command runs `date` on the server so the filename uses server local time.

**Tech Stack:** GitHub Actions, appleboy/ssh-action, SSH password auth.

---

### Task 1: Add workflow file

**Files:**
- Create: `react-app/.github/workflows/main-notify.yml`

**Step 1: Create the workflow**

Create `.github/workflows/main-notify.yml` with:

- `name: Notify on main update`
- Trigger: `push` to branch `main`
- One job (e.g. `notify-server`) on `ubuntu-latest`
- One step using `appleboy/ssh-action@v1.0.3` (or latest v1) with:
  - `host: data-infact.com`
  - `username: test-guide`
  - `password: ${{ secrets.SSH_PASSWORD }}`
  - `script: touch /home/wuxianyu/main_update_$(date +%Y-%m-%dT%H-%M-%S)`

**Step 2: Commit**

```bash
git add react-app/.github/workflows/main-notify.yml
git commit -m "ci: add main-notify workflow (SSH touch on main push)"
```

---

### Task 2: Document secret setup

**Files:**
- Modify: `react-app/README.md` or add `react-app/.github/workflows/README.md` (optional)

**Step 1: Document required secret**

Ensure maintainers know to add in GitHub repo **Settings → Secrets and variables → Actions**:

- **Name:** `SSH_PASSWORD`
- **Value:** (the SSH password for test-guide@data-infact.com)

If no README in workflows, add a short comment in the workflow YAML or a one-line in the main README under “CI” that the main-notify job requires `SSH_PASSWORD` secret.

**Step 2: Commit (if any file was added/edited)**

```bash
git add <path>
git commit -m "docs: document SSH_PASSWORD secret for main-notify workflow"
```

---

### Verification

- Push to `main` and open **Actions** tab; run should succeed.
- SSH to the server and run: `ls -la /home/wuxianyu/main_update_*` — a new file with the current (server local) timestamp should exist.
