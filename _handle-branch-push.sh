#!/usr/bin/env bash

HERE=`readlink -f "$(dirname $0)"`
has_error=0

. "${HERE}/_utils.sh"

ensureenv JOB_COMMIT_SHA

[[ -z "${JOB_COMMIT_SHA}" ]] && {
    echo 'Did not find a commit hash. Please set $JOB_COMMIT_SHA' >&2
    exit 1
}

[[ -f ${QUERIES_RESULTS_PATH} ]] || {
    echo 'Did not find any results file' >&2
    exit 1
}

ensureenv SECRET_UPLOAD_KEY

[[ ${has_error} -eq 1 ]] && {
    echo "Found errors. Exiting..." >&2
    exit 1
}

cat "${QUERIES_RESULTS_PATH}" | ${HERE}/tools/queries-upload --rev "${JOB_COMMIT_SHA}"
