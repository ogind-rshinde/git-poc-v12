#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

branchType=${BRANCH:0:4}
if [[ "$branchType" == "qabg" ]]
then
    parentBranch='release/next'
else 
    echo "$(tput setaf 1) ********** git cherry-pick is not applicable for this branch. ********* "
    exit;
fi

if [[ "$BRANCH" != "$parentBranch" ]]
then
    git pull origin $BRANCH
    git checkout main
    git pull origin main
    git checkout $parentBranch
    git pull origin $parentBranch    
fi

cherryPickCommitIdList=$(git log $BRANCH --not main release/next --oneline --no-merges --pretty=format:"%h|" --reverse)
cherryPickArr=($(echo "$cherryPickCommitIdList" | tr '|' '\n'))
isCherryPick=0
for element in "${cherryPickArr[@]}"
do
    if [[ "$element" != "" ]]
    then
        git cherry-pick $element
        isCherryPick=1
        echo "$(tput setaf 2) ******************* Cherry-pick is initiated for $element ****************************"
    else
        echo "$(tput setaf 1) *******************
             Commit ID is not valid, Please contact with administrator!   ****************************"
    fi
done

if [[ "$isCherryPick" == 1 ]]
then
    git push origin $parentBranch
    echo "$(tput setaf 2) ******************* Cherry-pick is initiated successfully ****************************"
fi
