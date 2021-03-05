---
title: "[Terraform] Bump version"
PipelineID: updatecliToolsUpdates
sources:
  getTerraformVersion:
    kind: githubRelease
    name: Get the latest Terraform version
    transformers:
      - trimPrefix: "v"
    spec:
      owner: "hashicorp"
      repository: "terraform"
      token: "{{ requiredEnv .github.token }}"
      username: "{{ .github.username }}"
      versionFilter:
        kind: regex
        pattern: '0.13.(\d*)'
conditions:
  dockerfileArgTerraformVersion:
    name: "Does the Dockerfile have an ARG instruction which key is TERRAFORM_VERSION?"
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "TERRAFORM_VERSION"
targets:
  updateCstTerraformVersion:
    name: "Update the value of TERRAFORM_VERSION in the test harness"
    sourceID: getTerraformVersion
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
  updateDockerfileArgTerraformVersion:
    name: "Update the value of ARG TERRAFORM_VERSION in the Dockerfile"
    sourceID: getTerraformVersion
    kind: dockerfile
    spec:
      file: Dockerfile
      instruction:
        keyword: "ARG"
        matcher: "TERRAFORM_VERSION"
    scm:
      github:
        user: "{{ .github.user }}"
        email: "{{ .github.email }}"
        owner: "{{ .github.owner }}"
        repository: "{{ .github.repository }}"
        token: "{{ requiredEnv .github.token }}"
        username: "{{ .github.username }}"
        branch: "{{ .github.branch }}"
