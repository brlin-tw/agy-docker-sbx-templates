#!/usr/bin/env bash
# Build and export the Antigravity CLI Docker Sandbox templates
#
# Copyright 2026 林博仁(Buo-ren Lin) <buo.ren.lin@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

set_opts=(
    errexit
    errtrace
    nounset
)
for opt in "${set_opts[@]}"; do
    if ! set -o "${opt}"; then
        printf \
            'Error: Failed to set defensive interpreter behavior "%s".\n' \
            "${opt}" \
            1>&2
        exit 1
    fi
done

init(){
    local variant="${1:-base}"
    local tag="${2:-antigravity:latest}"
    local output_archive="${3:-agy-template.tar}"
    local dockerfile="Dockerfile"

    if test "${variant}" = "dind"; then
        dockerfile="Dockerfile.dind"
    elif test "${variant}" != "base"; then
        printf \
            'Error: Unknown variant "%s". Supported variants: base, dind.\n' \
            "${variant}" \
            1>&2
        return 1
    fi

    local required_commands=(
        docker
        realpath
    )
    for command in "${required_commands[@]}"; do
        if ! command -v "${command}" >/dev/null; then
            printf \
                'Error: This program requires the "%s" command to be available in your command search PATHs.\n' \
                "${command}" \
                1>&2
            return 1
        fi
    done

    local script="${BASH_SOURCE[0]}"
    if ! script="$(
        realpath \
            --strip \
            "${script}"
        )"; then
        printf \
            'Error: Unable to determine the absolute path of the program.\n' \
            1>&2
        return 1
    fi

    local project_dir="${script%/*}"

    printf \
        'Info: Building template image "%s" using "%s"...\n' \
        "${tag}" \
        "${dockerfile}"

    local docker_build_opts=(
        --file "${project_dir}/${dockerfile}"
        --tag "${tag}"
        "${project_dir}"
    )
    if ! docker build "${docker_build_opts[@]}"; then
        printf \
            'Error: Failed to build Docker image "%s".\n' \
            "${tag}" \
            1>&2
        return 2
    fi

    printf \
        'Info: Saving image to archive "%s"...\n' \
        "${output_archive}"
    local docker_save_opts=(
        --output "${output_archive}"
        "${tag}"
    )
    if ! docker image save "${docker_save_opts[@]}"; then
        printf \
            'Error: Failed to save Docker image archive.\n' \
            1>&2
        return 2
    fi

    printf \
        'Info: Template archive created successfully at "%s".\n' \
        "${output_archive}"
    printf \
        'Info: To load into Docker Sandboxes, run:\n    sbx template load %s\n' \
        "${output_archive}"

    return 0
}

if ! init "${@}"; then
    exit 1
fi
