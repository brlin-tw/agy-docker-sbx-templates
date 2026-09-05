#!/usr/bin/env bash
# Prepare the Antigravity authentication kit with host credentials
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
    local host_config_dir="${1:-"${HOME}/.gemini/antigravity-cli"}"

    local required_commands=(
        chmod
        cp
        mkdir
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

    if ! test -d "${host_config_dir}"; then
        printf \
            'Error: Host Antigravity configuration directory "%s" does not exist.\n' \
            "${host_config_dir}" \
            1>&2
        return 1
    fi

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
    local kit_dir="${project_dir}/kits/antigravity-auth"
    local kit_target_dir="${kit_dir}/files/home/agent/.gemini/antigravity-cli"

    printf \
        'Info: Preparing kit target directory at "%s"...\n' \
        "${kit_target_dir}"
    if ! mkdir -p "${kit_target_dir}"; then
        printf \
            'Error: Failed to create kit target directory.\n' \
            1>&2
        return 2
    fi

    if ! chmod 0700 "${kit_target_dir}"; then
        printf \
            'Error: Failed to set secure permissions on kit target directory.\n' \
            1>&2
        return 2
    fi

    printf \
        'Info: Copying host credentials from "%s" to kit...\n' \
        "${host_config_dir}"
    if ! cp -a "${host_config_dir}/." "${kit_target_dir}/"; then
        printf \
            'Error: Failed to copy host configuration files.\n' \
            1>&2
        return 2
    fi

    printf \
        'Info: Antigravity authentication kit is ready at "%s".\n' \
        "${kit_dir}"
    printf \
        'Info: Launch a sandbox with injected credentials using:\n    sbx run --kit ./kits/antigravity-auth/ --template agy-docker-sbx-template:latest shell\n'

    return 0
}

if ! init "${@}"; then
    exit 1
fi
