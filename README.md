# Artifacts Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for uploading and downloading artifacts.

## Uploading artifacts

This functionality duplicates the [artifact_paths]() property in the pipeline yaml files.

```yml
steps:
  - plugins:
      artifacts#v1.1.0:
        upload: "log/**/*.log"
```

## Downloading artifacts

This downloads artifacts matching globs to the local filesystem. See [downloading artifacts](https://buildkite.com/docs/agent/cli-artifact#downloading-artifacts) for more details.

```yml
steps:
  - plugins:
      artifacts#v1.1.0:
        download: "log/**/*.log"
```

## Configuration

### `upload`

A glob pattern for files to upload.

### `download`

A glob pattern for files to download.

### `step` (optional)

The job UUID or name to download the artifact from.

### `build` (optional)

The build UUID to download the artifact from.

## License

MIT (see [LICENSE](LICENSE))
