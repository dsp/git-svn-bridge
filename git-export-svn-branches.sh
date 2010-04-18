#!/usr/bin/env bash
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

# Configure this part
gitremote="github"
giturl="git://github.com/phpbb/phpbb3.git"

svnurl="http://code.phpbb.com/svn/phpbb/"
svnuser="git-gate"
svnpasscmd="" # either empty or "--password <password>"

svnbranches=(  "trunk"                                    "branches/phpBB-3_0_0"                     "branches/phpBB-3_0_7" )
gitbranches=(  "develop"                                  "develop-olympus"                          "prep-release-3.0.7" )
githashinsvn=( "b68de2323d6444b4b3685a98bbcb9500a38e45cb" "d62068cfadcc1478a2f8dd6e7da81dea6cee71ff" "872ad322ec69a032ec22d9e8ae19b9a8399d7712" )

basedir=`readlink -f \`dirname $0\``

for (( i = 0 ; i < ${#svnbranches[@]} ; i++ ))
    do
        svnbranch=${svnbranches[i]}
        gitbranch=${gitbranches[i]}
        echo "Updating svn $svnbranch from git $gitremote $gitbranch"

        svnbranchname=`basename $svnbranch`
        if [ ! -d "$svnbranchname" ]
            then
                echo "Creating svn checkout and initialising git repo"
                svn co --username $svnuser $svnpasscmd $svnurl/$svnbranch/
                cd $svnbranchname
                echo ${githashinsvn[i]} > git-revision
                git init
                git remote add -t $gitbranch $gitremote $giturl
                git fetch $gitremote
                git checkout -b $gitbranch $gitremote/$gitbranch
                cd ..
            fi

        cd $svnbranchname
        $basedir/git-export-svn.sh $gitremote $gitbranch
        cd ..
    done

