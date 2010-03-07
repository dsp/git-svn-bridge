#!/bin/sh
#
# (c) 2010 David Soria Parra
# (c) 2010 Nils Adermann
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <dsp@php.net> and <naderman@naderman.de wrote this file.
# As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. 
# ----------------------------------------------------------------------------


# Make sure there are two arguments
if [ $# -ne 2 ]
then
    echo "Usage: git-export-svn REMOTE BRANCH"
    echo "    REMOTE The git remote to pull from"
    echo "    BRANCH The git branch to pull from"
    echo "This script has to be run from within a checked out svn branch."

    exit 1
fi

remote=$1
branch=$2
svn revert -R .

git pull $remote

lc=0
cont=0
if test -f "git-revision"
then
    lc=`cat git-revision`
    cont=1
else
    echo "no git-revision found"
    continue
fi

for hash in `git log --reverse --first-parent --pretty='format:%H' $lc..$branch`
    do
        echo "update to $hash"
        git checkout -f $hash

        if ! git log -n 1 --pretty=fuller $hash > COMMIT_MSG
            then
                echo "Canno get log" >&2
                exit 127;
            fi
        cat COMMIT_MSG
        for file in `git diff-tree -r --name-only --diff-filter=A HEAD~1..HEAD`
            do
                echo "add $file"
                svn add --parents $file
            done
        for file in `git diff-tree -r --name-only --diff-filter=D HEAD~1..HEAD`
            do
                echo "del $file"
                svn rm $file
            done
        echo $hash > git-revision
        svn add git-revision
        svn commit -F COMMIT_MSG
        svn up
    done
git checkout $branch
