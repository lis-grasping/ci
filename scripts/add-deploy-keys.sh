#!/usr/bin/env bash
set -euo pipefail

readonly ORG="lis-grasping"
readonly KEY_REPO="$ORG/graspkit"
readonly KEY_TITLE="CI of the repositories that install graspkit"
readonly SECRET_NAME="GRASPKIT_DEPLOY_KEY"
readonly REPOS=(
  graspdata
  graspsim
  graspdiff
  graspview
  graspbot
  egf
  se3dif
  vsigd
  dsdf
)

key_dir="$(mktemp -d)"
trap 'rm -rf "$key_dir"' EXIT
key_file="$key_dir/graspkit_deploy_key"

gh api --method PATCH "orgs/$ORG" -F deploy_keys_enabled_for_repositories=true --silent

ssh-keygen -q -t ed25519 -N "" -C "$KEY_TITLE" -f "$key_file"
old_key_ids="$(gh repo deploy-key list -R "$KEY_REPO" --json id,title \
  -q ".[] | select(.title == \"$KEY_TITLE\") | .id")"
for key_id in $old_key_ids; do
  gh repo deploy-key delete "$key_id" -R "$KEY_REPO"
done
gh repo deploy-key add "$key_file.pub" -R "$KEY_REPO" --title "$KEY_TITLE"

for repo in "${REPOS[@]}"; do
  gh secret set "$SECRET_NAME" -R "$ORG/$repo" < "$key_file"
done

for repo in "${REPOS[@]}"; do
  failed_runs="$(gh run list -R "$ORG/$repo" --branch develop --status failure \
    --json databaseId -q '.[].databaseId')"
  for run in $failed_runs; do
    gh run rerun "$run" --failed -R "$ORG/$repo"
  done
done

gh repo deploy-key list -R "$KEY_REPO"
