---
title: "[Golangcilint] Bump version"
PipelineID: updatecliToolsUpdates
sources:
  getGolangcilintVersion:
    kind: githubRelease
    name: Get the latest Golangcilint version
    transformers:
      - trimPrefix: "v"
    spec:
      owner: "golangci"
      repository: "golangci-lint"
      token: "{{ requiredEnv .github.token }}"
      username: "{{ .github.username }}"
      versionFilter:
        kind: latest
conditions:
  dockerfileArgGolangcilintVersion:
    name: "Does the Dockerfile have an ARG instruction which key is GOLANGCILINT_VERSION?"
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "GOLANGCILINT_VERSION"
targets:
  updateCstGolangcilintVersion:
    name: "Update the value of GOLANGCILINT_VERSION in the test harness"
    sourceID: getGolangcilintVersion
    kind: yaml
    spec:
      file: "cst.yml"
      key: "metadataTest.labels[4].value"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
  updateDockerfileArgGolangcilintVersion:
    name: "Update the value of ARG GOLANGCILINT_VERSION in the Dockerfile"
    sourceID: getGolangcilintVersion
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "GOLANGCILINT_VERSION"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
