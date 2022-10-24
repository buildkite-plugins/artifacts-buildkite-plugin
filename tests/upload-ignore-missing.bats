#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {
    export BUILDKITE_PLUGIN_ARTIFACTS_IGNORE_MISSING="true"
}

@test "Post-command does not fail with ignore missing" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"

  stub buildkite-agent \
    "artifact upload \* : exit 1"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Ignoring error in upload of *.log"

  unstub buildkite-agent
}

@test "Post-command with relocation does not fail" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"

  stub buildkite-agent \
    "artifact upload \* : exit 1"

  touch /tmp/foo.log

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Ignoring error in upload of /tmp/foo2.log"
  refute_output --partial "uploaded /tmp/foo2.log"
  refute_output --partial "uploaded /tmp/foo.log"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  rm -f /tmp/foo2.log

  unstub buildkite-agent
}

@test "Post-command with relocation does not fail if file does not exist" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"

  stub buildkite-agent \
    "artifact upload \* : exit 1"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Ignoring missing file /tmp/foo.log"
  assert_output --partial "Ignoring error in upload of /tmp/foo2.log"
  refute_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "uploaded /tmp/foo2.log"
  refute_output --partial "uploaded /tmp/foo.log"
  assert [ ! -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
}

@test "Post-command does not file with multiple artifacts and some failures" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : exit 1" \
    "artifact upload \* : echo uploaded \$3"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Ignoring error in upload of bar.log"
  refute_output --partial "uploaded bar.log"

  unstub buildkite-agent
}

@test "Post-command does not fail with some relocation and failure" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : exit 1" \
    "artifact upload \* : echo uploaded \$3"

  touch /tmp/foo.log

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  refute_output --partial "uploaded /tmp/foo.log"
  assert_output --partial "Ignoring error in upload of bar.log"
  refute_output --partial "uploaded bar.log"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  rm /tmp/foo2.log

  unstub buildkite-agent
}

@test "Post-command does not fail with some relocation that fails" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact upload \* : exit 1" \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3"

  touch /tmp/foo.log

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"
  assert_output --partial "Ignoring error in upload of /tmp/foo2.log"
  
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  
  rm /tmp/foo2.log

  unstub buildkite-agent
}


@test "Post-command does not fail with some relocation and missing file" {
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"

  stub buildkite-agent \
    "artifact upload \* : exit 1" \
    "artifact upload \* : echo uploaded \$3" \
    "artifact upload \* : echo uploaded \$3"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  refute_output --partial "Moving [/tmp/foo.log]"
  refute_output --partial "uploaded /tmp/foo.log"
  refute_output --partial "uploaded /tmp/foo2.log"
  assert_output --partial "Ignoring missing file /tmp/foo.log"
  assert_output --partial "Ignoring error in upload of /tmp/foo2.log"

  assert [ ! -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  
  unstub buildkite-agent
}

@test "Post-command uploads multiple > 10 artifacts with relocation and some failures" {
  stub_calls=()
  for i in $(seq 0 10); do
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_FROM=/tmp/foo-${i}.log"
    export "BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_${i}_TO=/tmp/foo-r-${i}.log"
    touch "/tmp/foo-${i}.log"

    if [ $((i%2)) -eq 0 ]; then
      stub_calls+=( "artifact upload \* : echo uploaded \$3" )
    else
      stub_calls+=( "artifact upload \* : exit 1" )
    fi
  done

  stub buildkite-agent "${stub_calls[@]}"

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  
  for i in $(seq 0 10); do
    assert [ -e /tmp/foo-r-"${i}".log ]
    assert [ ! -e /tmp/foo-"${i}".log ]
    rm /tmp/foo-r-"${i}".log

    if [ $((i%2)) -eq 0 ]; then
      refute_output --partial "uploaded /tmp/foo-${i}.log"
    else
      assert_output --partial "Ignoring error in upload of /tmp/foo-r-${i}.log"
    fi
  done

  unstub buildkite-agent
}