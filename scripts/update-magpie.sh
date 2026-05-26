#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CURRENT_REV=$(grep 'rev = "' "$REPO_DIR/default.nix" | head -1 | sed 's/.*rev = "\(.*\)";/\1/')
echo "Current upstream rev: $CURRENT_REV"

COMMIT_JSON=$(curl -sfL "https://api.github.com/repos/liliu-z/magpie/commits/main")
LATEST_REV=$(jq -r '.sha' <<<"$COMMIT_JSON")
COMMIT_DATE=$(jq -r '.commit.committer.date' <<<"$COMMIT_JSON" | cut -dT -f1)

if [ -z "$LATEST_REV" ] || [ "$LATEST_REV" = "null" ] || [ -z "$COMMIT_DATE" ] || [ "$COMMIT_DATE" = "null" ]; then
  echo "Could not determine latest upstream commit." >&2
  exit 1
fi

echo "Latest upstream rev: $LATEST_REV"

if [ "$CURRENT_REV" = "$LATEST_REV" ]; then
  echo "Already up to date."
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "UPDATED=false" >> "$GITHUB_OUTPUT"
  fi
  exit 0
fi

LATEST_VERSION="unstable-$COMMIT_DATE"
SOURCE_URL="https://github.com/liliu-z/magpie/archive/${LATEST_REV}.tar.gz"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Prefetching source..."
SRC_HASH=$(nix store prefetch-file --json --unpack "$SOURCE_URL" | jq -r .hash)

echo "Prefetching npm dependencies..."
curl -sfL "$SOURCE_URL" -o "$WORK_DIR/source.tar.gz"
mkdir "$WORK_DIR/source"
tar -xzf "$WORK_DIR/source.tar.gz" -C "$WORK_DIR/source" --strip-components=1
NPM_DEPS_HASH=$(prefetch-npm-deps "$WORK_DIR/source/package-lock.json")

export LATEST_VERSION LATEST_REV SRC_HASH NPM_DEPS_HASH
perl -0pi -e '
  s/version = "[^"]+";/version = "$ENV{LATEST_VERSION}";/;
  s/rev = "[^"]+";/rev = "$ENV{LATEST_REV}";/;
  s/hash = "[^"]+";/hash = "$ENV{SRC_HASH}";/;
  s/npmDepsHash = "[^"]+";/npmDepsHash = "$ENV{NPM_DEPS_HASH}";/;
' "$REPO_DIR/default.nix"

echo "Updated magpie to $LATEST_VERSION ($LATEST_REV)"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "VERSION=$LATEST_VERSION" >> "$GITHUB_OUTPUT"
  echo "REV=$LATEST_REV" >> "$GITHUB_OUTPUT"
  echo "UPDATED=true" >> "$GITHUB_OUTPUT"
fi
