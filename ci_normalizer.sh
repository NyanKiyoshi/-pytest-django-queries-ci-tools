#!/usr/bin/env bash

set -e

get_provider_name() {
	[ -z "$TRAVIS_COMMIT" ] || ci_provider=travis
	[ -z "$GITHUB_EVENT_PATH" ] || ci_provider=github
	echo $ci_provider
}

normalize_travis() {
	base_sha=$(echo "$TRAVIS_COMMIT_RANGE" | sed -E 's/[.]+.+//')
	echo "JOB_COMMIT_SHA=${TRAVIS_COMMIT}"
	echo "JOB_PR_BASE_SHA=${base_sha}"
	echo "JOB_IS_PR=$([ -n "$TRAVIS_PULL_REQUEST_SHA" ] && echo yes)"
}

normalize_github() {
	base_sha=$(jq .pull_request.base.sha < "$GITHUB_EVENT_PATH" | sed 's|"||g')
	head_sha=$(jq .pull_request.head.sha < "$GITHUB_EVENT_PATH" | sed 's|"||g')
	echo "JOB_COMMIT_SHA=${head_sha}"
	echo "JOB_PR_BASE_SHA=${base_sha}"
	echo "JOB_IS_PR=$([ "$GITHUB_EVENT_NAME" = pull_request ] && echo yes)"
}

# Outputs:
#   JOB_COMMIT_SHA=job_pr_or_push_commit_hash
#		JOB_PR_BASE_SHA=job_base_commit_hash
#		JOB_EVENT_TYPE=push|pull_request|api|cron
main() {
	provider=$(get_provider_name)

	case $provider in
		github)
			normalize_github;;
		travis)
			normalize_travis;;
		*)
			echo "No valid provider found" >&2
			exit 1;;
	esac
}

main
