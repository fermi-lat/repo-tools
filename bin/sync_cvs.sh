#!/bin/bash
git_repo=$1
cvs_repo=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: sync_cvs.sh GIT_REPO CVS_REPO"
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

cd $cvs_repo
cvs_last_commit=$(cat .gitsha)
git rev-list --reverse $cvs_last_commit..$head | xargs -l1 git cvsexportcommit  -p -c
rc=$?
if [[ $rc != 0 ]]; then
    printf "Error committing changes\n"
    exit $rc;
fi

echo $head > .gitsha
cvs commit -m "Bump .gitsha"
