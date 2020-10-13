#!/usr/bin/env bash
set -e

HERE=$(dirname "$0")
cd $HERE
HERE=$(pwd)

if [[ "$JOB_IS_PR" = "yes" ]]; then
    echo "Uploading diff results from pull request..." >&2
    ./_handle-pull-request.sh
else
    echo "Uploading raw results from push..." >&2
    ./_handle-branch-push.sh
fi
