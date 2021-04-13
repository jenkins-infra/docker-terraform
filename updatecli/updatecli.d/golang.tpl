---
title: "[golang base image] Bump version"
PipelineID: updatecliToolsUpdates
sources:
  getGolangVersion:
    kind: githubRelease
    name: Get the latest Golang version
    transformers:
      - trimPrefix: "go"
    spec:
      owner: "golang"
      repository: "go"
      token: "{{ requiredEnv .github.token }}"
      username: "{{ .github.username }}"
      versionFilter:
        kind: regex
        pattern: 'go1.15.(\d*)'
conditions:
  dockerfileArgGoVersion:
    name: "Does the Dockerfile have an ARG instruction which key is GO_VERSION?"
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "GO_VERSION"
targets:
  updateCstGoVersion:
    name: "Update the value of GO_VERSION in the test harness"
    sourceID: getGolangVersion
    kind: yaml
    spec:
      file: "cst.yml"
      key: "metadataTest.labels[2].value"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
  updateDockerfileArgGoVersion:
    name: "Update the value of ARG GO_VERSION in the Dockerfile"
    sourceID: getGolangVersion
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "GO_VERSION"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
