# Main-Notify GitHub Workflow — Design

## Goal

On every push to `main`, run a GitHub Actions workflow that SSHs to a server and touches a timestamped file under `/home/wuxianyu/` so the server records that `main` was updated. Timestamp in the filename uses **server local time**.

## Decisions

- **Trigger:** Push to `main`.
- **Auth:** SSH with password via appleboy/ssh-action; password stored in repo secret `SSH_PASSWORD`.
- **Host:** `data-infact.com`, user `test-guide`.
- **Remote command:** `touch /home/wuxianyu/main_update_$(date +%Y-%m-%dT%H-%M-%S)` (run on server so time is server local).
- **Filename format:** `main_update_<YYYY-MM-DD>T<HH-MM-SS>` (e.g. `main_update_2025-03-03T15-30-45`).

## Architecture

- Single workflow file under `.github/workflows/`.
- One job: checkout (optional), then appleboy/ssh-action with host, user, password secret, and the touch command.
- No application build or deploy; workflow is independent of the React app beyond living in the same repo.

## Security

- Password only in GitHub Actions secrets; not in workflow YAML.
- Restrict repo and secret access as needed for your environment.

## Out of Scope

- Retries, Slack/email notifications, or other side effects.
- SSH key–based auth (can be added later if desired).
