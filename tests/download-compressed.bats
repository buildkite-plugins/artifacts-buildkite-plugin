#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Invalid compressed format" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="file.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.rar"
  
  run "$PWD/hooks/pre-command"

  assert_failure
  assert_output --partial "The inferred compression file format for the artifact is not currently supported"
  refute_output --partial "Downloading artifacts"

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value zip" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"
  
  stub buildkite-agent \
    "artifact download \* \* : echo downloaded \$3 to \$4"

  stub unzip \
    "\* \* : echo extracted \$2 from \$1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing *.log from file.zip"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value tgz" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"
  
  stub buildkite-agent \
    "artifact download \* \* : echo downloaded \$3 to \$4"

  stub tar \
    "xzf \* \* : echo extracted \$3 from \$2"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing *.log from file.tgz"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single zip with relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded \$3 to \$4"

  stub unzip \
    "\* \* : echo extracted \$2 from \$1; touch \$2"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing /tmp/foo.log from file.zip"
  assert_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "downloaded /tmp/foo.log"
  refute_output --partial "downloaded /tmp/foo2.log"

  assert [ ! -e /tmp/foo.log ]
  assert [ -e /tmp/foo2.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single tgz with relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded \$3 to \$4"

  stub tar \
    "xzf \* \* : echo extracted \$3 from \$2; touch \$3"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing /tmp/foo.log from file.tgz"
  assert_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "downloaded /tmp/foo.log"
  refute_output --partial "downloaded /tmp/foo2.log"

  assert [ ! -e /tmp/foo.log ]
  assert [ -e /tmp/foo2.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value zip with step" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  stub buildkite-agent \
    "artifact download --step \* \* \* : echo downloaded \$5 to \$6 with --step \$4"

  stub unzip \
    "\* \* : echo extracted \$2 from \$1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--step 54321')"
  assert_output --partial "Uncompressing *.log from file.zip"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value tgz with step" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  stub buildkite-agent \
    "artifact download --step \* \* \* : echo downloaded \$5 to \$6 with --step \$4"

  stub tar \
    "xzf \* \* : echo extracted \$3 from \$2"


  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--step 54321')"
  assert_output --partial "Uncompressing *.log from file.tgz"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value zip with build" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  stub buildkite-agent \
    "artifact download --build \* \* \* : echo downloaded artifact \$5 to \$6 with --build \$4"

  stub unzip \
    "\* \* : echo extracted \$2 from \$1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"
  assert_output --partial "Uncompressing *.log from file.zip"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Single value tgz with build" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  stub buildkite-agent \
    "artifact download --build \* \* \* : echo downloaded artifact \$5 to \$6 with --build \$4"

  stub tar \
    "xzf \* \* : echo extracted \$3 from \$2"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts (extra args: '--build 12345')"
  assert_output --partial "Uncompressing *.log from file.tgz"
  refute_output --partial "downloaded *.log"

  unstub buildkite-agent
  unstub tar
  
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Multiple files from zip" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  stub unzip \
    "\* \* : echo extracted \$2 from \$1"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing foo.log bar.log baz.log from file.zip"
  refute_output --partial "downloaded foo.log"
  refute_output --partial "downloaded bar.log"
  refute_output --partial "downloaded baz.log"

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Multiple files from tgz" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  stub tar \
    "xzf \* \* : echo extracted \$3 from \$2"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing foo.log bar.log baz.log from file.tgz"
  refute_output --partial "downloaded foo.log"
  refute_output --partial "downloaded bar.log"
  refute_output --partial "downloaded baz.log"

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Multiple files from zip with some relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.zip"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  stub unzip \
    "\* \* \* \* : echo extracted \$2, \$3 and \$4 from \$1; touch \$2"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing /tmp/foo.log bar.log baz.log from file.zip"
  assert_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "downloaded /tmp/foo.log"
  refute_output --partial "downloaded /tmp/foo2.log"
  refute_output --partial "downloaded bar.log"
  refute_output --partial "downloaded baz.log"

  assert [ ! -e /tmp/foo.log ]
  assert [ -e /tmp/foo2.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub unzip

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}

@test "Multiple files from tgz with some relocation" {
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="file.tgz"

  stub buildkite-agent \
    "artifact download \* \* : echo downloaded artifact \$3 to \$4"

  stub tar \
    "xzf \* \* \* \* : echo extracted \$3, \$4 and \$5 from \$2; touch \$3"

  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert_output --partial "Uncompressing /tmp/foo.log bar.log baz.log from file.tgz"
  assert_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "downloaded /tmp/foo.log"
  refute_output --partial "downloaded /tmp/foo2.log"
  refute_output --partial "downloaded bar.log"
  refute_output --partial "downloaded baz.log"

  assert [ ! -e /tmp/foo.log ]
  assert [ -e /tmp/foo2.log ]
  rm /tmp/foo2.log

  unstub buildkite-agent
  unstub tar

  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
  unset BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED
}


@test "Do nothing if there is no download-specific vars setup" {
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="whatever"

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
  export BUILDKITE_PLUGIN_ARTIFACTS_COMPRESSED="whatever"

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