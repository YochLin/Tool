#!/bin/bash

BRANCH="main"
PUSH=0

function help() {
	echo "-h | --help       get more information"
	echo "-b | --branch     check/update the branch, default main"
	echo "-p | --push       push the newest version to repo"
}

# check have upstream remote branch
function remote_repo() {
	local remote_v="`git remote -v`"
	local upstream=0
	
	for repo in $remote_v
	do
		if [ $repo == "upstream" ];
		then
			upstream=1
		fi
	done
	echo $upstream
}

function remove_branch() {
	# only remain the master/main branch
	if [ $BRANCH = "all" ]; then
		git for-each-ref --format '%(refname:short)' refs/heads | grep -v "master\|main" | xargs git branch -D
	fi
}

function main() {
	# check not have any staged files
	if [ "`git diff --name-only`" != "" ];
	then
		echo "You need to stash file, then retry it"
		exit 0
	fi
	
	if [ "`git branch --show-current`" != $BRANCH ]; 
	then
		git checkout $BRANCH
	else
		echo "You are at $BRANCH, not checkout to $BRANCH"
	fi

	if [ $(remote_repo) -gt 0 ];
	then
		git fetch upstream
		git rebase upstream/$BRANCH
	else
		echo "You don't have upstream branch"
	fi
	
	if [ $PUSH -gt 0 ];
	then
		git push -f
	fi
}

# parse argument
while [ $# -gt 0 ];
do
	key=$1
	case $key in
		-b|--branch)
			BRANCH=$2
			shift
			shift
			;;
		-p|--push)
			PUSH=1
			shift
			shift
			;;
		-h|--help)
			help
			shift
			exit 0
			;;
		-rm-branch)
			BRANCH=$2
			shift
			shift
			;;
		*)
			echo "invalid argument"
			help
			shif
			;;
	esac
done

main