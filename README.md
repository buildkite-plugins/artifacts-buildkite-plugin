# Artifacts Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for uploading and downloading artifacts.

## Uploading artifacts

This functionality duplicates the [artifact_paths]() property in the pipeline yaml files.

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.2.0:
        upload: "log/**/*.log"
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.2.0:
        upload: [ "log/**/*.log", "debug/*.error" ]
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.2.0:
        upload: 
          from: log1.log
          to: log2.log
```

or

```yml
steps:
  - command: ...
    plugins:
    - artifacts#v1.2.0:
        upload: 
        - from: log1.log
          to: log2.log
```

## Downloading artifacts

This downloads artifacts matching globs to the local filesystem. See [downloading artifacts](https://buildkite.com/docs/agent/cli-artifact#downloading-artifacts) for more details.

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.2.0:
          download: "log/**/*.log"
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.2.0:
          download: [ "log/**/*.log", "debug/*.error" ]
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.2.0:
          download: 
            from: log1.log
            to: log2.log
```

or

```yml
steps:
  - command: ...
    plugins:
      - artifacts#v1.2.0:
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
