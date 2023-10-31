#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Post-command uploads artifacts with a single value for upload" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  refute_output --partial "extra args"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
}

@test "Post-command uploads artifacts with a single value for upload with relocation" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"
  touch /tmp/foo.log

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "uploaded /tmp/foo2.log"
  refute_output --partial "uploaded /tmp/foo.log"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Post-command uploads artifacts with a single value for upload and a job" {
  stub buildkite-agent \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts (extra args: '--job 12345')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads artifacts with a single value for upload and a job and relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts (extra args: '--job 12345')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads multiple artifacts" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple artifacts with some relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  assert_output --partial "Uploading artifacts"
  refute_output --partial "uploaded /tmp/foo.log"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple > 10 artifacts with relocation" {
  stub_calls=()
  for i in $(seq 0 10); do
    touch "/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    stub_calls+=( "artifact upload \* : echo uploaded \$3" )
  done
  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  for i in $(seq 0 10); do
    assert [ -e /tmp/foo-r-"${i}".log ]
    assert [ ! -e /tmp/foo-"${i}".log ]
    refute_output --partial "uploaded /tmp/foo-${i}.log"
    unset "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_FROM"
    unset "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_TO"
  done
  unstub buildkite-agent
}

@test "Post-command uploads multiple artifacts with a job" {
  stub buildkite-agent \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4" \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts (extra args: '--job 12345')"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command upload with user-provided S3 object ACL" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_S3_UPLOAD_ACL="bucket-owner-read"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Setting S3 object upload ACL: bucket-owner-read"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_S3_UPLOAD_ACL
}

@test "Post-command upload with user-provided GS object ACL" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_GS_UPLOAD_ACL="bucketOwnerRead"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Setting GS object upload ACL: bucketOwnerRead"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_GS_UPLOAD_ACL
}

@test "Post-command does nothing if no vars are set" {
  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"
}

@test "Post-command does nothing if there is download-specific vars setup" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="test.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="test2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="test3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="test4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="test5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="test6.log"

  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
}

@test "Single skip exit status does not match still uploads" {
  export BUILDKITE_COMMAND_EXIT_STATUS="100"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS="10"

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
}

@test "Single skip exit status matches, skips upload" {
  export BUILDKITE_COMMAND_EXIT_STATUS="10"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS="10"

  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"
  assert_output --partial "skipping upload"
}

@test "Multiple skip exit status does not match still uploads" {
  export BUILDKITE_COMMAND_EXIT_STATUS="100"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_0="10"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_1="1"

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
}

@test "Multiple skip exit status matches, skips upload" {
  export BUILDKITE_COMMAND_EXIT_STATUS="10"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_0="1"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_1="100"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_2="10"
  export BUILDKITE_PLUGIN_ARTIFACTS_SKIP_ON_STATUS_3="2"

  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"
  assert_output --partial "skipping upload"
}

@test "Post-command uploads artifacts with a single value for upload with path" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_PATH="*.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  refute_output --partial "extra args"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_PATH
}

@test "Post-command uploads multiple artifacts with path" {
  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_PATH="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_PATH="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_PATH="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_PATH
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_PATH
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_PATH
}
