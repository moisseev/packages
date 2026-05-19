#!/bin/sh

# Update repo
pkg repo FreeBSD:15:amd64

if [ $? -ne 0 ]; then
    echo "Failed to create repository"
    exit 1
fi

# Add all files including the new repository metadata
git add -A && git commit -m "Update repo"
[ $? -eq 0 ] || exit 1

#
# Truncate history
#

REPO_NAME='packages'

# Foolproof
REPO=`git rev-parse --show-toplevel`
[ $? -eq 0 ] || exit 1
[ `basename $REPO` = $REPO_NAME ] || {
    echo "This script is intended to run in the $REPO_NAME repository,"
    echo "but the current repository is $REPO ."
    exit 1
}

COMMIT=`git rev-parse @~3` # Get hash of the 3rd commit before head

git checkout --orphan temp $COMMIT
git add -A
# --no-verify - bypass the pre-commit and commit-msg hooks
git commit --no-verify -m "Truncated history"
git rebase --onto temp $COMMIT master
git branch -D temp

git prune --progress # delete all the objects w/o references
git gc --aggressive # aggressively collect garbage; may take a lot of time on large repos

git push -f
