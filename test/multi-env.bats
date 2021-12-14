setup_file() {
    load 'test_helper/common-setup'
    _common_setup

    if [ -z "${MICROMAMBA_VERSION}" ]; then
      export MICROMAMBA_VERSION="$(./check_version.py 2> /dev/null | cut -f1 -d,)"
    fi

    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    docker build $MICROMAMBA_FLAGS \
                 --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=multi-env \
		 --file=${PROJECT_ROOT}/test/multi-env.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  -e ENV_NAME=env1 multi-env curl --version" {
    run docker run --rm  -e ENV_NAME=env1 multi-env curl --version
    assert_output  --partial 'curl 7.71.1'
}

@test "docker run --rm -e ENV_NAME=env2 multi-env jq --version" {
    run docker run --rm -e ENV_NAME=env2 multi-env jq --version
    assert_output 'jq-1.6'
}
