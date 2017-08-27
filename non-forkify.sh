# This script converts all forked repos to non-forked ones
# All you need to do is create an empty remote repo, and execute this script with appropriate params

FOLDER=
REMOTE="origin"

TO_UNSHALLOW=0
UNSHALLOW_BRANCH=

# Config
FETCH_REMOTES=1
PUSH=0
VERBOSE=0
DEBUG=0

show_help() {
	echo "non-forkify.sh <options>"
	echo "-f|--folder-name FOLDER_NAME - The folder of your local repo (default - Current folder)"
	echo "-r|--remote REMOTE - The REMOTE whose branches you would want to checkout and also push to that REMOTE itself."
	echo "-u|--unshallow <branch> - Will unshallow the specified branch if its shallow already. Expected branch to be current branch."
	echo "-d|--dont-fetch-remotes - Will not fetch remotes (by default, all remotes are fetched)."
	echo "-p|--push - Will push --all to specified remote."
	echo "-v|--verbose - Enable verbose messages."
	echo "-l|--debug - Enables debug mode, actual operations are not done (checkouts and push), verbose is enabled."
	echo "-h|--help - Shows this help"
}

update_local_repo() {
	if [ $FETCH_REMOTES -eq 1 ]; then
		git fetch --all >> /dev/null
	else
		echo "Not fetching remotes."
	fi
}

checkout_and_push_all_branches() {
	for branch in `git branch -a | grep $REMOTE`; do
		new_branch=`echo ${branch#*"$REMOTE"/}`
		checkout_branch="$REMOTE/$new_branch"

		if [ $VERBOSE -eq 1 ]; then
			echo "This branch will be checked out - $checkout_branch"
			echo "This branch will be newly created - $new_branch"	
		fi

		if [ $DEBUG -eq 0 ]; then
			git checkout "$checkout_branch"
			git checkout -b "$new_branch"
		fi
	done
	if [ $PUSH -eq 1 ]; then
		git push --all "$REMOTE"
	else
		echo "Not pushing."
	fi
}

while [[ $# -ge 1 ]]
do
	key="$1"
	case $key in
		-f|--folder-name)
			FOLDER="$2"
			shift
			;;
		-r|--remote)
			REMOTE="$2"
			shift
			;;
		-u|--unshallow)
			TO_UNSHALLOW=1
			UNSHALLOW_BRANCH="$2"
			shift
			;;
		-d|--dont-fetch-remotes)
			FETCH_REMOTES=0
			shift
			;;
		-p|--push)
			PUSH=1
			shift
			;;
		-v|--verbose)
			VERBOSE=1
			shift
			;;
		-d|--debug)
			VERBOSE=1
			DEBUG=1
			PUSH=0
			TO_UNSHALLOW=0
			FETCH_REMOTES=0
			shift
			;;						
		-h|--help)
			show_help
			shift
			;;
	esac
	shift
done

cd "$FOLDER"
update_local_repo
checkout_and_push_all_branches