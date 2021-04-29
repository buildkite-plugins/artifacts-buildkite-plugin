# Artifacts Buildkite Plugin [![Build status](https://badge.buildkite.com/7b0170b44f960e219a66a4f5f09b3490fc0013f189d60b5d1f.svg?branch=master)](https://buildkite.com/buildkite/plugins-artifacts)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for uploading and downloading artifacts.

## Uploading artifacts

This functionality duplicates the [artifact_paths]() property in the pipeline yaml files; with the difference that it also allows downloading artifacts and that this plugin is executed before any command hook, so you can create dependencies on artifacts in your steps that are resolved before the actual step is executed. This is ideal for producing an artifact in one job and then downloading it in a different job before execution.

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.3.0:
        upload: "log/**/*.log"
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.3.0:
        upload: [ "log/**/*.log", "debug/*.error" ]
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.3.0:
        upload: 
          from: log1.log
          to: log2.log
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.3.0:
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
    - artifacts#v1.3.0:
        upload: "coverage-report/**/*"
        s3-upload-acl: public-read
```

eg: uploading a private file when using GS
```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.3.0:
        upload: "coverage-report/**/*"
        gs-upload-acl: private
```

## Downloading artifacts

This downloads artifacts matching globs to the local filesystem. See [downloading artifacts](https://buildkite.com/docs/agent/cli-artifact#downloading-artifacts) for more details.

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.3.0:
          download: "log/**/*.log"
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.3.0:
          download: [ "log/**/*.log", "debug/*.error" ]
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.3.0:
          download: 
            from: log1.log
            to: log2.log
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.3.0:
          download: 
          - from: log1.log
            to: log2.log
```

## Configuration

### `upload` (string, array of strings, {from,to}, array of {from,to})

A glob pattern, or array of glob patterns, for files to upload.

### `download` (string, array of strings, {from,to}, array of {from,to})

A glob pattern, or array of glob patterns, for files to download.

### `step` (optional, string)

The job UUID or name to download the artifact from.

### `build` (optional, string)

The build UUID to download the artifact from.

### Relocation

If a file needs to be renamed or moved before upload or after download, a nested object is used with `to` and `from` keys.
At this time, this can only be used with single files and does not support glob patterns.

## Developing

To run testing, shellchecks and plugin linting use use `bk run` with the [Buildkite CLI](https://github.com/buildkite/cli).

```bash
bk run
```

Or if you want to run just the tests, you can use the [Docker Compose CLI](https://docs.docker.com/compose/):

```bash
docker-compose run --rm tests
```

## License

MIT (see [LICENSE](LICENSE))
