#!/usr/bin/env bash

HERE=`readlink -f "$(dirname $0)"`
has_error=0

function ensureenv() {
    local key=$1
    local value=${!key}

    [[ -z "${value}" ]] && {
        echo "Missing environment variable: '${key}'" >&2
        has_error=1
    }
}

ensureenv TRAVIS_COMMIT_RANGE
ensureenv TRAVIS_REPO_SLUG
ensureenv TRAVIS_BRANCH
ensureenv DIFF_RESULTS_BASE_URL
ensureenv QUERIES_RESULTS_PATH

[[ ${has_error} -eq 1 ]] && {
    echo "Found errors. Exiting..." >&2
    exit 1
}

user=`echo ${TRAVIS_PULL_REQUEST_SLUG} | cut -d/ -f1`
repo=`echo ${TRAVIS_PULL_REQUEST_SLUG} | cut -d/ -f2`
ref_name=$(echo ${TRAVIS_PULL_REQUEST_BRANCH} | sed -E 's/\.\.\..+//')

base_ref_hash=$(echo $TRAVIS_COMMIT_RANGE | cut -d... -f1)
head_results_path="/tmp/base-results.json"

curl --fail -X GET "${DIFF_RESULTS_BASE_URL}/${base_ref_hash}" -L -o "${head_results_path}" || {
    echo "[Warning] Did not find a HEAD base results for ${base_ref_hash}" >&2
    cp -v "${QUERIES_RESULTS_PATH}" "${head_results_path}"
}

django-queries diff "${head_results_path}" "${QUERIES_RESULTS_PATH}"
