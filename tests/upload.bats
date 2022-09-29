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
  stub_calls=()
  for i in $(seq 0 10); do
    touch "/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    stub_calls+=( "artifact upload /tmp/foo-r-$i.log : echo Uploading artifact" )
  done
  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  for i in $(seq 0 10); do
    assert [ -e /tmp/foo-r-"${i}".log ]
    assert [ ! -e /tmp/foo-"${i}".log ]
    unset "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_FROM"
    unset "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_TO"
  done
  unstub buildkite-agent
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
