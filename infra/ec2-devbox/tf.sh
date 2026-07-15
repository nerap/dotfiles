#!/usr/bin/env bash
# tf.sh — run terraform against the personal (SSO) account.
#
# Works around a CLI-vs-SDK SSO quirk: the AWS CLI refreshes SSO fine, but
# terraform's provider sometimes can't refresh the cached SSO token. So we export
# the CLI's current session as env credentials and run terraform with an empty
# provider profile (which then falls back to those env vars).
#
# Usage:  ./tf.sh plan | apply | destroy | <any terraform args>
#         PROFILE=personal REGION=eu-west-3 ./tf.sh apply
#
# If it says creds are expired:  aws sso login --profile personal
set -euo pipefail
cd "$(dirname "$0")"

PROFILE="${PROFILE:-personal}"
REGION="${REGION:-eu-west-3}"

if ! aws sts get-caller-identity --profile "$PROFILE" >/dev/null 2>&1; then
  echo "SSO session for '$PROFILE' is expired. Run:  aws sso login --profile $PROFILE" >&2
  exit 1
fi

eval "$(aws configure export-credentials --profile "$PROFILE" --format env)"
unset AWS_PROFILE
export AWS_REGION="$REGION"

# auto-approve apply/destroy unless the caller passed their own flags
extra=()
case "${1:-}" in
  apply|destroy) [[ " $* " == *" -auto-approve "* ]] || extra=(-auto-approve) ;;
esac

exec terraform "$@" -var 'aws_profile=' "${extra[@]}"
