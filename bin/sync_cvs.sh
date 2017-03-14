#!/bin/bash
git_repo=$1
cvs_repo=$2

# sync_cvs.sh
# Use this when a CVS repo has a .gitsha and the git repo has
# been updated.

if [ "$#" -ne 2 ]; then
    echo "Usage: sync_cvs.sh GIT_REPO CVS_REPO"
    exit 1;
fi

# Fix directories
cd $git_repo
git_repo=$(pwd)
cd - &> /dev/null
cd $cvs_repo
cvs_repo=$(pwd)
cd - &> /dev/null

export GIT_DIR=$git_repo/.git

# Sanity check
git rev-parse HEAD &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then 
    printf "Git repo not configured correctly, check your first argument\n"
    exit $rc; 
fi
head=$(git rev-parse HEAD)

cd $cvs_repo
cvs status &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then 
    printf "CVS repo likely not configured correctly, check second argument\n"
    exit $rc; 
fi

cvs_last_commit=$(cat .gitsha)
parent_commit=$cvs_last_commit

for commit in $(git rev-list --reverse $cvs_last_commit..$head); do
    git cvsexportcommit -p -c $parent_commit $commit
    #git rev-list --reverse $cvs_last_commit..$head | xargs -l1 git cvsexportcommit  -p -c
    rc=$?
    if [[ $rc != 0 ]]; then 
        printf "Error committing changes: Commit $commit from parent $parent_commit\n"
        exit $rc; 
    fi
    echo $commit > .gitsha
    cvs commit -m "Bump .gitsha"
    parent_commit=$commit
done
printf "Done."
