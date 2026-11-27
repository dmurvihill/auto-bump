# auto-bump

Prevent stale bots from wasting your time and de-automate closure of your issues.

Runs daily, finds issues your care about that have been marked as stale, and
comments on them to reset the stale timer. 

## Setup

1. Create a personal access token so comments come from your account.
   `GITHUB_TOKEN` cannot comment on other people's repos.
   - GitHub → Settings → Developer settings → Personal access tokens →
     Tokens (classic) → Generate new token.
   - Scope: `public_repo` (use `repo` if any tracked issue is in a private repo).
   - Fine-grained tokens usually can't comment on repos you don't own, so
     classic is the practical choice here.
   - Set an expiry and add a calendar reminder to rotate it.

2. Store it as a secret:

   ```sh
   gh secret set BUMP_TOKEN --repo YOUR_USER/auto-bump
   ```

   (Paste the token when prompted.)

3. Push:

   ```sh
   git push -u origin main
   ```

4. Test with a dry run, then check the logs:

   ```sh
   gh workflow run bump.yml --repo YOUR_USER/auto-bump -f dry_run=true
   gh run watch --repo YOUR_USER/auto-bump
   ```

## Adding issues

Add a `url` entry to `issues.yml` and push. Per-issue `stale_labels` and
`message` are optional overrides. Check what label each project's bot uses.

## Notes

- GitHub disables scheduled workflows after 60 days without repo activity on
  public repos. Pushing any commit re-enables it. (Private repos are not
  affected by this.)
- Run locally: `GH_TOKEN=... DRY_RUN=1 ./scripts/bump.sh`
