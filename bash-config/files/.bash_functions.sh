#!/bin/bash
function gh() {
    # Provides a GitHub URL for the current repo, for the origin remote,
    # a different provided remote, or a PR URL between either origin and
    # upstream or two different provided remotes

    if [ $# -eq 0 ]
    then
        # Assume we just want the origin's remote URL
        gh origin
    elif [ $1 == "--pr" ]
    then
        # Produce a PR generation URL
        # PR URLs look like this: https://github.com/organisation/repo/compare/master...origin_user:master
        if [ $# -eq 1 ]
        then
            # Get the PR for origin merging into upstream
            gh --pr upstream origin
        elif [ $# -eq 2 ]
        then
            # Get the PR for the origin merging into the provided remote
            gh --pr $2 origin
        else
            # Get the PR URL for the two provided remotes
            upstream=$2
            origin=$3
            upstream_url=$(gh $upstream)
            origin_url=$(git remote get-url $origin)
            origin_user=${origin_url#*\:}
            origin_user=${origin_user%%\/*}
            origin_branch=$(git rev-parse --abbrev-ref HEAD)
            echo PR: $upstream_url/compare/master...$origin_user:$origin_branch
        fi
    else
        # Get the URL for the provided remote
        remote=$1
        giturl=$(git remote get-url $remote)
        giturl=${giturl/\:/\/}
        giturl=https://${giturl:4:-4}
        echo $giturl
    fi
}

alias git=git-wrapper
function git-wrapper() {
    # Wraps the standard `git` command to give me a PR URL after every `git push`

    case "$1" in
        push ) \git $@; gh --pr ;;
        * ) \git $@ ;;
    esac
}