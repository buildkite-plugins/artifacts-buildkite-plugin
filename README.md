# Artifacts Buildkite Plugin [![Build status](https://badge.buildkite.com/7b0170b44f960e219a66a4f5f09b3490fc0013f189d60b5d1f.svg?branch=master)](https://buildkite.com/buildkite/plugins-artifacts)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for uploading and downloading artifacts.

## Uploading artifacts

This functionality duplicates the [artifact_paths](https://buildkite.com/docs/pipelines/artifacts#uploading-artifacts-in-build-steps) property in the pipeline yaml files; with the difference that it also allows downloading artifacts and that this plugin is executed before any command hook, so you can create dependencies on artifacts in your steps that are resolved before the actual step is executed. This is ideal for producing an artifact in one job and then downloading it in a different job before execution.

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "log/**/*.log"
```

You can specify multiple files/globs to upload as artifacts:

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: [ "log/**/*.log", "debug/*.error" ]
```

And even rename them before uploading them (can not use globs here though, sorry):

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: 
          - from: log1.log
            to: log2.log
```

### User-defined ACL on uploaded files

When using AWS S3 or Google Cloud Storage as your artifact store, you can optionally define an object-level ACL for your uploaded artifacts. This allows you to have granular control over which artifacts are made public or private.

If not specified it will respect the relevant setting at the agent level.

eg: uploading a public file when using S3
```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "coverage-report/**/*"
        s3-upload-acl: public-read
```

eg: uploading a private file when using GS
```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "coverage-report/**/*"
        gs-upload-acl: private
```

## Downloading artifacts

This downloads artifacts matching globs to the local filesystem. See [downloading artifacts](https://buildkite.com/docs/agent/cli-artifact#downloading-artifacts) for more details.

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.9.1:
          download: "log/**/*.log"
```

You can specify multiple files/patterns:

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.9.1:
          download: [ "log/**/*.log", "debug/*.error" ]
```

Rename particular files after downloading them:

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.9.1:
          download: 
            - from: log1.log
              to: log2.log
```

And even do so from different builds/steps:

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.9.1:
          step: UUID-DEFAULT
          build: UUID-DEFAULT-2
          download: 
            - from: log1.log
              to: log2.log
              step: UUID-1
            - from: log3.log
              to: log4.log
              build: UUID-2
```

## Configuration

### `upload` (string, array of strings, {from,to}, array of {from,to})

A glob pattern, or array of glob patterns, for files to upload.

### `download` (string, array of strings, {from,to}, array of {from,to[,step][,build]})

A glob pattern, or array of glob patterns, for files to download.

### `step` (optional, string)

The job UUID or name to download the artifacts from unless specified otherwise in the `download` array specification.

### `build` (optional, string)

The build UUID to download the artifact from unless specificed otherwise in the `download` array specification.

### `compressed` (optional, string)

⚠️ Limitations:
* filename needs to end with `.zip` or `.tgz` and that will determine the compression executable to use
* path globs (`*`) are interpreted by agent's shell and (un)compressing program, meaning that `*` and `**` will not work.

When uploading, the file or directory specified in the `upload` option will be compressed in a single file with this name and uploaded as a single artifact. The following example will get the directory matching `log/my-folder`, zip them up and upload a single artifact file named `logs.zip`:


```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "log/my-folder"
        compressed: logs.zip
```

When downloading, this option states the actual name of the artifact to be downloaded in the `download` option will be extracted off of it. The following example will download the `logs.tgz` artifact and extract all files in it matching `log/file.log`:

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.9.1:
          download: "log/file.log"
          compressed: logs.tgz
```

### `ignore-missing` (optional, boolean)

If set to `true`, it will ignore errors caused when calling `buildkite-agent artifact` to prevent failures if you expect artifacts not to be present in some situations.

### `skip-on-status` (optional, integer or array of integers, uploads only)

You can set this to the exit codes or array of exit codes of the command step (as defined by the `BUILDKITE_COMMAND_EXIT_STATUS` variable) that will cause the plugin to avoid trying to upload artifacts.

This should allow you to specify known failure conditions that you want to avoid uploading artifacts. For example, because you know logs will be huge or not useful.

Skip uploading if the main command failed with exit code 147:

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "log/*.log"
        skip-on-status: 147
```

Alternatively, skip artifact uploading on exit codes 1 and 5:

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.9.1:
        upload: "log/*.log"
        skip-on-status:
          - 1
          - 5
```

## Developing

To run testing, shellchecks and plugin linting use use `bk run` with the [Buildkite CLI](https://github.com/buildkite/cli).

```bash
bk run
```

Or if you want to run just the tests, you can use the docker [Plugin Tester](https://github.com/buildkite-plugins/buildkite-plugin-tester):

```bash
docker run --rm -ti -v "${PWD}":/plugin buildkite/plugin-tester:latest
```

## License

MIT (see [LICENSE](LICENSE))
