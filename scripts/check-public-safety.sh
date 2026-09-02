#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_dir"

failed=false

check_pattern() {
  description=$1
  pattern=$2

  if git grep -nEI "$pattern" -- . \
    ':(exclude)LICENSE' \
    ':(exclude)scripts/check-public-safety.sh'; then
    printf '\nPotential %s found.\n' "$description" >&2
    failed=true
  fi
}

check_pattern 'absolute home-directory path' '(/Users/[^/[:space:]]+|/home/[^/[:space:]]+)'
check_pattern 'email address' '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}'
check_pattern 'private key' 'BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY'
check_pattern 'common API token' '(gh[opusr]_[[:alnum:]_]{20,}|github_pat_[[:alnum:]_]{20,}|sk-[[:alnum:]_-]{20,}|xox[baprs]-[[:alnum:]-]{10,}|AKIA[[:alnum:]]{16}|cfut_[[:alnum:]_-]{20,})'
check_pattern 'sensitive assignment' "(api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*[\"']?[^\$[:space:]<{][^[:space:]]{5,}"

if [ "$failed" = true ]; then
  exit 1
fi

printf 'Public-safety checks passed.\n'
