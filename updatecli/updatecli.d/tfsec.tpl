---
title: "[Tfsec] Bump version"
PipelineID: updatecliToolsUpdates
sources:
  getTfsecVersion:
    kind: githubRelease
    name: Get the latest Tfsec version
    transformers:
      - trimPrefix: "v"
    spec:
      owner: "tfsec"
      repository: "tfsec"
      token: "{{ requiredEnv .github.token }}"
      username: "{{ .github.username }}"
      versionFilter:
        kind: latest
conditions:
  dockerfileArgTfsecVersion:
    name: "Does the Dockerfile have an ARG instruction which key is TFSEC_VERSION?"
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "TFSEC_VERSION"
targets:
  updateCstTfsecVersion:
    name: "Update the value of TFSEC_VERSION in the test harness"
    sourceID: getTfsecVersion
    kind: yaml
    spec:
      file: "cst.yml"
      key: "metadataTest.labels[3].value"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
  updateDockerfileArgTfsecVersion:
    name: "Update the value of ARG TFSEC_VERSION in the Dockerfile"
    sourceID: getTfsecVersion
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "TFSEC_VERSION"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
