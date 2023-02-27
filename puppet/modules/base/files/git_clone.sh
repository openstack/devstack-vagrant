#!/bin/bash
#
# Functions taken liberally from devstack project, though trimmed down
# for local use.

# git update using reference as a branch.
# git_update_branch ref
function git_update_branch {

    local GIT_BRANCH=$1

    git checkout -f origin/$GIT_BRANCH
    # a local branch might not exist
    git branch -D $GIT_BRANCH || true
    git checkout -b $GIT_BRANCH
}

# git update using reference as a branch.
# git_update_remote_branch ref
function git_update_remote_branch {

    local GIT_BRANCH=$1

    git checkout -b $GIT_BRANCH -t origin/$GIT_BRANCH
}

# git update using reference as a tag. Be careful editing source at that repo
# as working copy will be in a detached mode
# git_update_tag ref
function git_update_tag {

    local GIT_TAG=$1

    git tag -d $GIT_TAG
    # fetching given tag only
    git_timed fetch origin tag $GIT_TAG
    git checkout -f $GIT_TAG
}

# git clone only if directory doesn't exist already.  Since ``DEST`` might not
# be owned by the installation user, we create the directory and change the
# ownership to the proper user.
# git_clone remote dest-dir branch
function git_clone {
    local GIT_REMOTE=$1
    local GIT_DEST=$2
    local GIT_REF=$3

    # Avoid git exiting when in some other dir than the typical /home/stack
    cd $(dirname $GIT_DEST)

    # do a full clone only if the directory doesn't exist
    if [[ ! -d $GIT_DEST ]]; then
        git_timed clone $GIT_REMOTE $GIT_DEST
        cd $GIT_DEST
        # This checkout syntax works for both branches and tags
        git checkout $GIT_REF
    else
        # if it does exist then simulate what clone does if asked to RECLONE
        cd $GIT_DEST
        # set the url to pull from and fetch
        git remote set-url origin $GIT_REMOTE
        git_timed fetch origin
        # remove the existing ignored files (like pyc) as they cause breakage
        # (due to the py files having older timestamps than our pyc, so python
        # thinks the pyc files are correct using them)
        find $GIT_DEST -name '*.pyc' -delete

        # handle GIT_REF accordingly to type (tag, branch)
        if [[ -n "`git show-ref refs/tags/$GIT_REF`" ]]; then
            git_update_tag $GIT_REF
        elif [[ -n "`git show-ref refs/heads/$GIT_REF`" ]]; then
            git_update_branch $GIT_REF
        elif [[ -n "`git show-ref refs/remotes/origin/$GIT_REF`" ]]; then
            git_update_remote_branch $GIT_REF
        else
            die $LINENO "$GIT_REF is neither branch nor tag"
        fi
    fi

    # print out the results so we know what change was used in the logs
    cd $GIT_DEST
    git show --oneline | head -1
}

# git can sometimes get itself infinitely stuck with transient network
# errors or other issues with the remote end.  This wraps git in a
# timeout/retry loop and is intended to watch over non-local git
# processes that might hang.  GIT_TIMEOUT, if set, is passed directly
# to timeout(1); otherwise the default value of 0 maintains the status
# quo of waiting forever.
# usage: git_timed <git-command>
function git_timed {
    local count=0
    local timeout=0

    if [[ -n "${GIT_TIMEOUT}" ]]; then
        timeout=${GIT_TIMEOUT}
    fi

    until timeout -s SIGINT ${timeout} git "$@"; do
        # 124 is timeout(1)'s special return code when it reached the
        # timeout; otherwise assume fatal failure
        if [[ $? -ne 124 ]]; then
            die $LINENO "git call failed: [git $@]"
        fi

        count=$(($count + 1))
        warn "timeout ${count} for git call: [git $@]"
        if [ $count -eq 3 ]; then
            die $LINENO "Maximum of 3 git retries reached"
        fi
        sleep 5
    done
}

URL=${1:-https://opendev.org/openstack/devstack}
BRANCH=${2:-master}
LOCAL=${3:-/home/stack/devstack}

set -o xtrace
set -o errexit

git_clone $URL $LOCAL $BRANCH
