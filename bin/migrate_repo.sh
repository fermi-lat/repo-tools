#!/bin/bash
#
# migrate_repo.sh is a tool to facilitate the creation of git repos
# from cvs repos. This particular tools attempts to remove extraneous
# files (ChangeLog) and git tags ("HEAD" or "LATEST") from the resulting
# repository after migration.
#
# It assumes cvs2git is in your path. You may need to set that up.
#

if [ "$#" -ne 2 ]; then
    echo "Usage: migrate_repo.sh CVSDIR REPONAME"
    exit 1;
fi

cvsdir=$1
reponame=$2

# Sanity checks
cvs -d $cvsdir status -l $reponame &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then
    printf "CVS repo/module not configured correctly, check arguments\n"
    exit $rc;
fi

cvs2git --help &> /dev/null
rc=$?
if [[ $rc != 0 ]]; then
    printf "Error: cvs2git not in your path\n"
    exit $rc;
fi

# Perform migration
cvs2git --blobfile=$reponame-blob.dat --dumpfile=$reponame-dump.dat --username=cvs2git $cvsdir/$reponame

git init --bare $reponame.git
cd $reponame.git
cat ../$reponame-blob.dat ../$reponame-dump.dat | git fast-import

# Cleanup tags first
git tag -l | grep "HEAD\|LATEST" | sed 's/.*/git tag -d &/' | sh
cd ..

# Clone bare git repo, clean up resultant repository
git clone $reponame.git
cd $reponame
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch ChangeLog **/ChangeLog' --prune-empty --tag-name-filter cat -- --all
cd ..

# Cleanup
rm $reponame-blob.dat $reponame-dump.dat
rm -rf $reponame.git
