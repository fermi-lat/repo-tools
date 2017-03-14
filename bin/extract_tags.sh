#!/bin/bash
cvs_sandbox=$1

if [ "$#" -ne 1 ]; then
    echo "Usage: extract_tags.sh CVS_MODULE"
    exit 1;
fi

# Fix directories
cd $cvs_sandbox
cvs_repo=$(pwd)
cd - &> /dev/null

cd $cvs_sandbox

gitsha_f=".gitsha"
gitsha=$(cat $gitsha_f)
OMIT_PATTERN="HEAD\|LATEST"

status=$(cvs status -v $gitsha_f | grep -v $OMIT_PATTERN)

revision=$(echo "$status" | grep "Repository revision:" | awk '{print $3}')
tags=$(echo "$status" | grep "(revision: $revision)" | awk '{print $1}')

printf "cvs_tag\tgit_sha\n"
for tag in $tags; do
    printf "$tag\t$gitsha\n"
done

