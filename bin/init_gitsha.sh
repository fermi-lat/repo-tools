#!/bin/bash
git_repo=$1
cvs_repo=$2

# init_gitsha.sh
# Use this when a git repo is known to be
# roughly equivalent with the state of the 
# CVS repository. If that's the case, then
# using sync_repo.sh should always succeed.


if [ "$#" -ne 2 ]; then
    echo "Usage: init_gitsha.sh GIT_REPO CVS_REPO"
    exit 1;
fi

export GIT_DIR=$git_repo/.git

# Sanity check
git rev-parse HEAD &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then
    printf "Git repo not configured correctly, check your first argument\n"
    exit $rc;
fi

cvs diff &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then
    printf "CVS repo likely not configured correctly, check second argument\n"
    exit $rc;
fi

head=$(git rev-parse HEAD)
echo $head > .gitsha
cvs commit -m "Initialize .gitsha"
