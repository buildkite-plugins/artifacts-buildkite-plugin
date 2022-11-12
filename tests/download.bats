#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Pre-command downloads artifacts" {
  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
}

@test "Pre-command downloads artifacts with relocation" {
  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4; touch /tmp/foo.log"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Pre-command downloads artifacts with step" {
  stub buildkite-agent \
    "artifact download --step 54321 \* \* : echo downloaded artifact \$5 to \$6 with --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--step 54321')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with step and relocation" {
  stub buildkite-agent \
    "artifact download --step 54321 \* \* : touch /tmp/foo.log; echo downloaded artifact \$5 to \$6 with --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--step 54321')"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 \* \* : echo downloaded artifact \$5 to \$6 with --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple artifacts" {
  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
}

@test "Pre-command downloads multiple artifacts with some relocation" {
  stub buildkite-agent \
    "artifact download \* \* : touch /tmp/foo.log; echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4" \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
}

@test "Pre-command downloads multiple artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 \* \* : echo downloaded artifact \$5 to \$6 with --build 12345" \
    "artifact download --build 12345 \* \* : echo downloaded artifact \$5 to \$6 with --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple artifacts with build and relocation" {
  stub buildkite-agent \
    "artifact download --build 12345 \* \* : touch /tmp/foo.log; echo downloaded artifact \$5 to $6 with --build 12345" \
    "artifact download --build 12345 \* \* : echo downloaded artifact \$5 to \$6 with --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple > 10 artifacts with build and relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  stub_calls=()
  for i in $(seq 0 10); do
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    stub_calls+=( "artifact download --build 12345 \* \* : touch /tmp/foo-$i.log; echo downloaded artifact \$5 to \$6 with --build 12345" )
  done
  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"
  for i in $(seq 0 10); do
    assert [ -e /tmp/foo-r-"${i}".log ]
    assert [ ! -e /tmp/foo-"${i}".log ]
    unset "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_FROM"
    unset "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_TO"
  done
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
  unstub buildkite-agent
}

@test "Pre-command downloads multiple > 10 artifacts with different steps or builds" {
  stub_calls=()
  for i in $(seq 0 10); do
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_STEP=STEP-UUID-${i}"
    export "BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_${i}_BUILD=UUID-${i}"
    stub_calls+=( "artifact download --step \* --build \* \* \* : touch /tmp/foo-$i.log; echo downloaded artifact \$7 to \$8 with step \$4 and build \$6" )
  done
  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  for i in $(seq 0 10); do
    assert [ -e /tmp/foo-r-"${i}".log ]
    rm /tmp/foo-r-"${i}".log
    assert [ ! -e /tmp/foo-"${i}".log ]
  done

  unstub buildkite-agent
}

@test "Pre-command does nothing if there is no download-specific vars setup" {
  run "$PWD/hooks/pre-command"
  
  assert_success
  refute_output --partial "Downloading artifacts"
}

@test "Pre-command does nothing if there is upload-specific vars setup" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="test.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="test2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="test3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="test4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="test5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="test6.log"

  run "$PWD/hooks/pre-command"

  assert_success
  refute_output --partial "Downloading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
}