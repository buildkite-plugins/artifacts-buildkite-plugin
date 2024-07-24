#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {
    export BUILDKITE_PLUGIN_ARTIFACTS_IGNORE_MISSING="true"
}

@test "Pre-command downloads doesn't fail on agent failure" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"

  stub buildkite-agent \
    "artifact download \* \* : exit 1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Ignoring error in download of *.log"

  unstub buildkite-agent
}

@test "Pre-command downloads artifacts with relocation doesn't fail" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"

  stub buildkite-agent \
    "artifact download \* \* : exit 1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Ignoring error in download of /tmp/foo.log"

  unstub buildkite-agent
}

@test "Pre-command downloads multiple artifacts with a failure" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : exit 1" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Ignoring error in download of bar.log"
  refute_output --partial "download artifact bar.log"

  unstub buildkite-agent
}

@test "Pre-command downloads multiple artifacts with some relocation and failure" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact download \* \* : touch /tmp/foo.log; echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : exit 1" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Ignoring error in download of bar.log"
  refute_output --partial "download artifact bar.log"

  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  rm /tmp/foo2.log
  unstub buildkite-agent
}

@test "Pre-command downloads multiple artifacts with some relocation and failure on relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact download \* \* : exit 1" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Ignoring error in download of /tmp/foo.log"
  refute_output --partial "download artifact /tmp/foo.log"

  assert [ ! -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
}

@test "Pre-command downloads multiple > 10 artifacts with build and relocation and some failures" {
  stub_calls=()
  for i in $(seq 0 10); do
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    if [ $((i%2)) -eq 0 ]; then
      stub_calls+=( "artifact download \* \* : touch /tmp/foo-$i.log; echo downloaded artifact \$3 to \$4" )
    else
      stub_calls+=( "artifact download \* \* : exit 1" )
    fi
  done
  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  for i in $(seq 0 10); do
    if [ $((i%2)) -eq 0 ]; then
      assert [ -e /tmp/foo-r-"${i}".log ]
      assert [ ! -e /tmp/foo-"${i}".log ]
      rm /tmp/foo-r-"${i}".log
    else
      assert [ ! -e /tmp/foo-r-"${i}".log ]
      assert [ ! -e /tmp/foo-"${i}".log ]
      assert_output --partial "Ignoring error in download of /tmp/foo-${i}.log"
      refute_output --partial "downloaded artifact /tmp/foo-${i}.log"
    fi
  done

  unstub buildkite-agent
}
