#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Pre-command downloads artifacts" {
  stub buildkite-agent \
    "artifact download *.log . : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
}

@test "Pre-command downloads artifacts with relocation" {
  stub buildkite-agent \
    "artifact download foo.log foo2.log : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="foo2.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Pre-command downloads artifacts with step" {
  stub buildkite-agent \
    "artifact download --step 54321 *.log . : echo Downloading artifacts with args: --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --step 54321"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with step and relocation" {
  stub buildkite-agent \
    "artifact download --step 54321 foo.log foo2.log : echo Downloading artifacts with args: --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --step 54321"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 *.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple artifacts" {
  stub buildkite-agent \
    "artifact download foo.log . : echo Downloading artifacts" \
    "artifact download bar.log . : echo Downloading artifacts" \
    "artifact download baz.log . : echo Downloading artifacts"

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
    "artifact download foo.log foo2.log : echo Downloading artifacts" \
    "artifact download bar.log . : echo Downloading artifacts" \
    "artifact download baz.log . : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
}

@test "Pre-command downloads multiple artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 foo.log . : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 bar.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple artifacts with build and relocation" {
  stub buildkite-agent \
    "artifact download --build 12345 foo.log foo2.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 bar.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Post-command uploads artifacts with a single value for upload" {
  stub buildkite-agent \
    "artifact upload *.log : echo Uploading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
}

@test "Post-command uploads artifacts with a single value for upload with relocation" {
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts"
  touch /tmp/foo.log

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Post-command uploads artifacts with a single value for upload and a job" {
  stub buildkite-agent \
    "artifact upload --job 12345 *.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads artifacts with a single value for upload and a job and relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload --job 12345 /tmp/foo2.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads multiple artifacts" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts" \
    "artifact upload bar.log : echo Uploading artifacts" \
    "artifact upload baz.log : echo Uploading artifacts" \

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple artifacts with some relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts" \
    "artifact upload bar.log : echo Uploading artifacts" \
    "artifact upload baz.log : echo Uploading artifacts" \

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple artifacts with a job" {
  stub buildkite-agent \
    "artifact upload --job 12345 foo.log : echo Uploading artifacts with args: --job 12345" \
    "artifact upload --job 12345 bar.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}