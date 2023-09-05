#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Invalid compressed format" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="file.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.rar"

  touch file.rar

  run "$PWD/hooks/post-command"

  assert_failure
  assert_output --partial "The inferred compression file format for the artifact is not currently supported"
  refute_output --partial "Uploading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.rar
}

@test "Single value zip" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  touch file.zip

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub zip \
    "-r \* \* : echo zipped \$3 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Compressing *.log to file.zip"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "uploaded file.zip"

  unstub buildkite-agent
  unstub zip

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.zip
}

@test "Single value tgz" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  touch file.tgz

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub tar \
    "czf \* \* : echo targzd \$3 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Compressing *.log to file.tgz"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "uploaded file.tgz"

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.tgz
}

@test "Single file zip with relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  touch file.zip

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub zip \
    "-r \* \* : echo zipped \$3 into \$2"

  touch /tmp/foo.log

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Compressing /tmp/foo2.log to file.zip"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "uploaded file.zip"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"

  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub zip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single file tgz with relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  touch file.tgz

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub tar \
    "czf \* \* : echo targzd \$3 into \$2"

  touch /tmp/foo.log

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Compressing /tmp/foo2.log to file.tgz"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "uploaded file.tgz"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"

  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub tar
  
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.tgz
}

@test "Single value zip with job" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  touch file.zip

  stub buildkite-agent \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4"

  stub zip \
    "-r \* \* : echo zipped \$3 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts (extra args: '--job 12345')"
  assert_output --partial "Compressing *.log to file.zip"
  assert_output --partial "uploaded file.zip"
  refute_output --partial "uploaded *.log"
  
  unstub buildkite-agent
  unstub zip

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.zip
}

@test "Single value tgz with job" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  touch file.tgz

  stub buildkite-agent \
    "artifact upload --job \* \* : echo uploaded \$5 with --job \$4"

  stub tar \
    "czf \* \* : echo targzd \$3 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts (extra args: '--job 12345')"
  assert_output --partial "Compressing *.log to file.tgz"
  assert_output --partial "uploaded file.tgz"
  refute_output --partial "uploaded *.log"
  
  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Multiple artifacts zip" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  touch file.zip

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub zip \
    "-r \* \* \* \* : echo zipped \$3, \$4 and \$5 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Compressing /tmp/foo.log bar.log baz.log to file.zip"
  assert_output --partial "uploaded file.zip"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded baar.log"
  refute_output --partial "uploaded baz.log"

  unstub buildkite-agent
  unstub zip

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.zip
}

@test "Multiple artifacts tgz" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  touch file.tgz

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub tar \
    "czf \* \* \* \* : echo zipped \$3, \$4 and \$5 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Compressing /tmp/foo.log bar.log baz.log to file.tgz"
  assert_output --partial "uploaded file.tgz"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded baar.log"
  refute_output --partial "uploaded baz.log"

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.tgz
}

@test "Multiple artifacs zip some relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  touch /tmp/foo.log
  touch file.zip

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub zip \
    "-r \* \* \* \* : echo zipped \$3, \$4 and \$5 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Compressing /tmp/foo2.log bar.log baz.log to file.zip"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"
  refute_output --partial "uploaded bar.log"
  refute_output --partial "uploaded baz.log"

  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub zip
  
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.zip
}

@test "Multiple artifacs tgz some relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  touch /tmp/foo.log
  touch file.tgz

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3"

  stub tar \
    "czf \* \* \* \* : echo targzd \$3, \$4 and \$5 into \$2"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Compressing /tmp/foo2.log bar.log baz.log to file.tgz"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"
  refute_output --partial "uploaded bar.log"
  refute_output --partial "uploaded baz.log"

  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED

  rm file.tgz
}

@test "Post-command does nothing if no vars are set" {
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="whatever"

  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Post-command does nothing if there is download-specific vars setup" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="test.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="test2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="test3.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="test4.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="test5.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="test6.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="whatever"

  run "$PWD/hooks/post-command"

  assert_success
  refute_output --partial "Uploading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}
