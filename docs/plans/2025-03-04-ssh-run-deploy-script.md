# SSH Run Deploy Script Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Change the main-notify workflow so the SSH step runs `bash /home/wuxianyu/react-test/deploy.sh` instead of touching a timestamp file; job fails when the script exits non-zero.

**Architecture:** Single YAML edit in `.github/workflows/main-notify.yml`: rename the SSH step and set `script` to the deploy script. appleboy/ssh-action propagates exit code.

**Tech Stack:** GitHub Actions, appleboy/ssh-action.

---

### Task 1: Update workflow SSH step

**Files:**
- Modify: `.github/workflows/main-notify.yml` (steps 19–25)

**Step 1: Rename step and set script to deploy.sh**

In `.github/workflows/main-notify.yml`:
- Change the step name from `SSH and touch timestamp file` to `SSH and run deploy script`.
- Change `script:` from `touch /home/wuxianyu/main_update_$(date +%Y-%m-%dT%H-%M-%S)` to `bash /home/wuxianyu/react-test/deploy.sh`.

Resulting step:

```yaml
      - name: SSH and run deploy script
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: test-guide.data-infact.com
          username: root
          password: ${{ secrets.SSH_PASSWORD }}
          script: bash /home/wuxianyu/react-test/deploy.sh
```

**Step 2: Commit**

```bash
git add .github/workflows/main-notify.yml
git commit -m "ci: run deploy.sh on main push instead of touch timestamp"
```

---

### Verification

- Push to a branch and open a PR, or push to `main` (if allowed): workflow run should trigger, reachability step should pass, SSH step should run `deploy.sh` on the server.
- If `deploy.sh` exits non-zero on the server, the job should be marked failed in the Actions tab.
