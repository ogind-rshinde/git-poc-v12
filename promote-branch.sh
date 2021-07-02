#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

branchType=${BRANCH:0:4}
if [[ "$branchType" == "qabg" ]]
then
    parentBranch='release/next'
else 
    echo "$(tput setaf 1) ***** This script is applicable only for qabg branches! **** "
    exit;
fi

git pull origin $BRANCH
git checkout main
git pull origin main
git checkout $parentBranch
git pull origin $parentBranch
git checkout $BRANCH 

mergeIds=$(git log $BRANCH --not main release/next --oneline --merges --pretty=format:"%h" -1)

if [[ "$mergeIds" != "" ]]
then
    lastCommitId=$(git log $BRANCH --not main release/next --oneline --no-merges --pretty=format:"%h" -1)
    newBranchName="${BRANCH/qabg/qarn}"
    git checkout -b $newBranchName
    git reset --hard $lastCommitId
    git push origin $newBranchName
    gh pr create -t "Merge qarn branch for $BRANCH to release/next branch" -b "PR merging" -B "$parentBranch"
else   
    # create PR on that branch and merge into release/next branch
    gh pr create -t "Merge qarn branch for $BRANCH to release/next branch" -b "PR merging" -B "$parentBranch"
fi

echo "$(tput setaf 2) ********************** PR is created successfully, Please assign reviewer to this PR ****************************"