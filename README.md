# Artifacts Buildkite Plugin

A [Buildkite](https://buildkite.com/) plugin for uploading and downloading artifacts from the buildkite interface.

## Uploading artifacts

This functionality duplicates the [artifact_paths]() property in the pipeline yaml files.

```yml
steps:
  - plugins:
      artifacts#v1.0.0:
        upload: "log/**/*.log"
```

## Downloading artifacts

This downloads artifacts matching globs to the local filesystem. See [downloading artifacts](https://buildkite.com/docs/agent/cli-artifact#downloading-artifacts) for more details.

```yml
steps:
  - plugins:
      artifacts#v1.0.0:
        download: "log/**/*.log"
```

## License

MIT (see [LICENSE](LICENSE))
