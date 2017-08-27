# This script converts all forked repos to non-forked ones
# All you need to do is create an empty remote repo, and execute this script with appropriate params

FOLDER=
REMOTE="origin"

show_help() {
	echo "non-forkify.sh <options>"
	echo "-f|--folder-name FOLDER_NAME - The folder of your local repo (default - Current folder)"
	echo "-r|--remote REMOTE - The REMOTE whose branches you would want to checkout and also push to that REMOTE itself."
	echo "-h|--help - Shows this help"
}

update_local_repo() {
	git fetch --all
}

checkout_and_push_all_branches() {
	for branch in `git branch -a | grep $REMOTE`; do
		new_branch=`echo ${branch#*"$REMOTE"/}`
		checkout_branch="$REMOTE/$new_branch"
		git checkout "$checkout_branch"
		git checkout -b "$new_branch"
	done
	git push --all "$REMOTE"
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