#!/usr/bin/env bash
# For each issue in issues.yml: if it is open and carries a stale label,
# post a comment so the stale bot resets its timer.
# Requires: gh (authenticated via GH_TOKEN), yq (mikefarah v4), jq.
# Set DRY_RUN=1 to print what would be done without commenting.
set -euo pipefail

file="${1:-issues.yml}"
count=$(yq '.issues | length' "$file")
failures=0

for ((i = 0; i < count; i++)); do
  url=$(yq ".issues[$i].url" "$file")
  message=$(yq ".issues[$i].message // .defaults.message" "$file")
  labels=$(yq -o=json -I=0 ".issues[$i].stale_labels // .defaults.stale_labels" "$file")

  if ! info=$(gh issue view "$url" --json state,labels 2>&1); then
    echo "::error::$url: could not read issue: $info"
    failures=$((failures + 1))
    continue
  fi

  state=$(jq -r '.state' <<<"$info")
  if [[ "$state" != "OPEN" ]]; then
    echo "::warning::$url is $state; remove it from $file or reopen it manually."
    continue
  fi

  is_stale=$(jq -r --argjson want "$labels" \
    '[.labels[].name] | any(. as $l | $want | index($l))' <<<"$info")
  if [[ "$is_stale" != "true" ]]; then
    echo "$url: not flagged stale, skipping."
    continue
  fi

  if [[ "${DRY_RUN:-}" == "1" ]]; then
    echo "$url: [dry run] would comment: $message"
  elif gh issue comment "$url" --body "$message"; then
    echo "$url: commented."
  else
    echo "::error::$url: failed to comment"
    failures=$((failures + 1))
  fi
done

exit $((failures > 0 ? 1 : 0))
