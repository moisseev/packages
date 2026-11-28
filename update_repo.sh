#!/bin/sh
set -e

# Foolproof
REPO_NAME='packages'
REPO=$(git rev-parse --show-toplevel) || {
    echo "Not inside a git repository." >&2
    exit 1
}
[ "$(basename "$REPO")" = "$REPO_NAME" ] || {
    echo "This script is intended to run in the $REPO_NAME repository," >&2
    echo "but the current repository is $REPO." >&2
    exit 1
}

# Update repo
pkg repo FreeBSD:15:amd64 || { echo "Failed to create repository" >&2; exit 1; }

git checkout --orphan newrepo

# Add all files including the new repository metadata
git add -A

git commit --no-verify -m "Update repo"

git branch -D master 2>/dev/null || true
git branch -m master

git push -f origin master

git reflog expire --expire=now --all
git gc --prune=now

#curl -s "https://purge.jsdelivr.net/gh/moisseev/packages@master/FreeBSD:15:amd64/meta.conf" >/dev/null
#curl -s "https://purge.jsdelivr.net/gh/moisseev/packages@master/FreeBSD:15:amd64/packagesite.pkg" >/dev/null
#curl -s "https://purge.jsdelivr.net/gh/moisseev/packages@master/FreeBSD:15:amd64/data.pkg" >/dev/null
