# SSH Run Deploy Script — Design

## Goal

Change the main-notify GitHub Actions job so that, on push to `main`, it SSHs to the server and runs `/home/wuxianyu/react-test/deploy.sh` instead of touching a timestamp file. The job must fail when `deploy.sh` exits non-zero.

## Decisions

- **Trigger:** Unchanged — push to `main`.
- **Steps:** (1) Reachability check unchanged; (2) SSH step runs `bash /home/wuxianyu/react-test/deploy.sh` (step renamed to reflect deploy script).
- **Failure behavior:** Job fails if `deploy.sh` returns non-zero; appleboy/ssh-action propagates the script exit code.
- **Auth and host:** Unchanged — appleboy/ssh-action, host `test-guide.data-infact.com`, user `root`, secret `SSH_PASSWORD`.

## Architecture

- Single workflow file: `.github/workflows/main-notify.yml`.
- One job, two steps: existing reachability check, then SSH action with `script: bash /home/wuxianyu/react-test/deploy.sh`.
- No new secrets or infrastructure.

## Out of Scope

- Changing auth (e.g. to SSH key).
- Modifying `deploy.sh` or server-side behavior.
- Notifications or retries.
