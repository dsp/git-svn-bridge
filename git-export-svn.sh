#!/bin/sh
#
# (c) 2010 David Soria Parra
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <dsp@php.net> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return. 
# ----------------------------------------------------------------------------


# change this to denote the main branch that is tracked
# and the remote
remote='github'
branch='master'
svn revert -R .

git fetch $remote
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
