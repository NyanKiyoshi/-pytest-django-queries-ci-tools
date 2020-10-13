#!/bin/bash
set -e

HERE=$(dirname "$0")
cd $HERE
HERE=$(pwd)

export \
 GITHUB_EVENT_PATH="$HERE/payloads/github_pullrequest_synchronize.json" \
 GITHUB_EVENT_NAME=pull_request

expected="\
JOB_COMMIT_SHA=6db0fab78656207b1040cc6eae4b41cc1ab4b736
JOB_PR_BASE_SHA=f6d1e2b4b06b7ac7a40783b6879f66840cf9e75d
JOB_IS_PR=yes
"
actual=$(../ci_normalizer.sh)

diff -B <(echo "$expected") <(echo "$actual") || {
	echo "Assertion Failed: contents differ" >&2
	exit 1
} && {
	echo "Assertion Passed" >&2
}
