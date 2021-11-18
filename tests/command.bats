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
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download /tmp/foo.log : echo Downloading artifacts"

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
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download --step 54321 /tmp/foo.log : echo Downloading artifacts with args: --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --step 54321"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

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
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download /tmp/foo.log . : echo Downloading artifacts" \
    "artifact download bar.log . : echo Downloading artifacts" \
    "artifact download baz.log . : echo Downloading artifacts"

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
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download --build 12345 /tmp/foo.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 bar.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple > 10 artifacts with build and relocation" {
  touch /tmp/foo-0.log
  touch /tmp/foo-1.log
  touch /tmp/foo-2.log
  touch /tmp/foo-3.log
  touch /tmp/foo-4.log
  touch /tmp/foo-5.log
  touch /tmp/foo-6.log
  touch /tmp/foo-7.log
  touch /tmp/foo-8.log
  touch /tmp/foo-9.log
  touch /tmp/foo-10.log

  stub buildkite-agent \
    "artifact download --build 12345 /tmp/foo-0.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-1.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-2.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-3.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-4.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-5.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-6.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-7.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-8.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-9.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/foo-10.log : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo-0.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo-r-0.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM="/tmp/foo-1.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO="/tmp/foo-r-1.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2_FROM="/tmp/foo-2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2_TO="/tmp/foo-r-2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_3_FROM="/tmp/foo-3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_3_TO="/tmp/foo-r-3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_4_FROM="/tmp/foo-4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_4_TO="/tmp/foo-r-4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_5_FROM="/tmp/foo-5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_5_TO="/tmp/foo-r-5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_6_FROM="/tmp/foo-6.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_6_TO="/tmp/foo-r-6.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_7_FROM="/tmp/foo-7.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_7_TO="/tmp/foo-r-7.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_8_FROM="/tmp/foo-8.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_8_TO="/tmp/foo-r-8.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_9_FROM="/tmp/foo-9.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_9_TO="/tmp/foo-r-9.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_10_FROM="/tmp/foo-10.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_10_TO="/tmp/foo-r-10.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"
  assert [ -e /tmp/foo-r-0.log ]
  assert [ ! -e /tmp/foo-0.log ]
  assert [ -e /tmp/foo-r-1.log ]
  assert [ ! -e /tmp/foo-1.log ]
  assert [ -e /tmp/foo-r-2.log ]
  assert [ ! -e /tmp/foo-2.log ]
  assert [ -e /tmp/foo-r-3.log ]
  assert [ ! -e /tmp/foo-3.log ]
  assert [ -e /tmp/foo-r-4.log ]
  assert [ ! -e /tmp/foo-4.log ]
  assert [ -e /tmp/foo-r-5.log ]
  assert [ ! -e /tmp/foo-5.log ]
  assert [ -e /tmp/foo-r-6.log ]
  assert [ ! -e /tmp/foo-6.log ]
  assert [ -e /tmp/foo-r-7.log ]
  assert [ ! -e /tmp/foo-7.log ]
  assert [ -e /tmp/foo-r-8.log ]
  assert [ ! -e /tmp/foo-8.log ]
  assert [ -e /tmp/foo-r-9.log ]
  assert [ ! -e /tmp/foo-9.log ]
  assert [ -e /tmp/foo-r-10.log ]
  assert [ ! -e /tmp/foo-10.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_3_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_3_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_4_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_4_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_5_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_5_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_6_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_6_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_7_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_7_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_8_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_8_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_9_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_9_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_10_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_10_TO
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

@test "Post-command uploads multiple > 10 artifacts with relocation" {
  touch /tmp/foo-0.log
  touch /tmp/foo-1.log
  touch /tmp/foo-2.log
  touch /tmp/foo-3.log
  touch /tmp/foo-4.log
  touch /tmp/foo-5.log
  touch /tmp/foo-6.log
  touch /tmp/foo-7.log
  touch /tmp/foo-8.log
  touch /tmp/foo-9.log
  touch /tmp/foo-10.log

  stub buildkite-agent \
    "artifact upload /tmp/foo-r-0.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-1.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-2.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-3.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-4.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-5.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-6.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-7.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-8.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-9.log : echo Uploading artifact" \
    "artifact upload /tmp/foo-r-10.log : echo Uploading artifact"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo-0.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo-r-0.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_FROM="/tmp/foo-1.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_TO="/tmp/foo-r-1.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_FROM="/tmp/foo-2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_TO="/tmp/foo-r-2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_3_FROM="/tmp/foo-3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_3_TO="/tmp/foo-r-3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_4_FROM="/tmp/foo-4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_4_TO="/tmp/foo-r-4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_5_FROM="/tmp/foo-5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_5_TO="/tmp/foo-r-5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_6_FROM="/tmp/foo-6.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_6_TO="/tmp/foo-r-6.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_7_FROM="/tmp/foo-7.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_7_TO="/tmp/foo-r-7.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_8_FROM="/tmp/foo-8.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_8_TO="/tmp/foo-r-8.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_9_FROM="/tmp/foo-9.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_9_TO="/tmp/foo-r-9.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_10_FROM="/tmp/foo-10.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_10_TO="/tmp/foo-r-10.log"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert [ -e /tmp/foo-r-0.log ]
  assert [ ! -e /tmp/foo-0.log ]
  assert [ -e /tmp/foo-r-1.log ]
  assert [ ! -e /tmp/foo-1.log ]
  assert [ -e /tmp/foo-r-2.log ]
  assert [ ! -e /tmp/foo-2.log ]
  assert [ -e /tmp/foo-r-3.log ]
  assert [ ! -e /tmp/foo-3.log ]
  assert [ -e /tmp/foo-r-4.log ]
  assert [ ! -e /tmp/foo-4.log ]
  assert [ -e /tmp/foo-r-5.log ]
  assert [ ! -e /tmp/foo-5.log ]
  assert [ -e /tmp/foo-r-6.log ]
  assert [ ! -e /tmp/foo-6.log ]
  assert [ -e /tmp/foo-r-7.log ]
  assert [ ! -e /tmp/foo-7.log ]
  assert [ -e /tmp/foo-r-8.log ]
  assert [ ! -e /tmp/foo-8.log ]
  assert [ -e /tmp/foo-r-9.log ]
  assert [ ! -e /tmp/foo-9.log ]
  assert [ -e /tmp/foo-r-10.log ]
  assert [ ! -e /tmp/foo-10.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_3_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_3_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_4_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_4_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_5_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_5_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_6_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_6_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_7_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_7_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_8_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_8_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_9_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_9_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_10_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_10_TO
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

@test "Post-command upload with user-provided S3 object ACL" {
  stub buildkite-agent \
    "artifact upload *.log : echo Uploading artifacts"

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
    "artifact upload *.log : echo Uploading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_GS_UPLOAD_ACL="bucketOwnerRead"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Setting GS object upload ACL: bucketOwnerRead"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_GS_UPLOAD_ACL
}
