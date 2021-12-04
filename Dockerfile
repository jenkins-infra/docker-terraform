# Golang is required for terratest
# 1.15 ensure that the latest patch is always used but avoiding breaking changes when Golang as a minor upgrade
# Alpine is used by default for fast and ligthweight customization
ARG GO_VERSION=1.17.4
FROM golang:"${GO_VERSION}-alpine"

## Repeating the ARG to add it into the scope of this image
ARG GO_VERSION=1.17.4

RUN apk add --no-cache \
  # To allow easier CLI completion + running shell scripts with array support
  bash=~5 \
  # Used to download binaries (implies the package "ca-certificates" as a dependency)
  curl=~7 \
  # Dev. Tooling packages (e.g. tools provided by this image installable through Alpine Linux Packages)
  git=~2\
  make=~4 \
  # Required for aws-cli
  py-pip=~20 \
  # Used to unarchive Terraform downloads
  unzip=~6

## Install AWS Cli
ARG AWS_CLI_VERSION=1.22.14
RUN python3 -m pip install --no-cache-dir awscli=="${AWS_CLI_VERSION}"

## bash need to be installed for this instruction to work as expected
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

### Install Terraform CLI
# Retrieve SHA256sum from https://releases.hashicorp.com/terraform/<TERRAFORM_VERSION>/terraform_<TERRAFORM_VERSION>_SHA256SUMS
# For instance: "
# TERRAFORM_VERSION=X.YY.Z
# curl -sSL https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_SHA256SUMS | grep linux_amd64
ARG TERRAFORM_VERSION=1.0.11
RUN curl --silent --show-error --location --output /tmp/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && terraform --version | grep "${TERRAFORM_VERSION}"

ARG TFSEC_VERSION=0.61.2
RUN curl --silent --show-error --location --output /tmp/tfsec \
    "https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" \
  && chmod a+x /tmp/tfsec \
  && mv /tmp/tfsec /usr/local/bin/tfsec \
  && tfsec --version | grep "${TFSEC_VERSION}"


ARG GOLANGCILINT_VERSION=1.43.0
RUN curl --silent --show-error --location --fail \
  https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
  | sh -s -- -b "$(go env GOPATH)/bin" "v${GOLANGCILINT_VERSION}"

ENV USER=infra
ENV HOME=/home/"${USER}"

RUN adduser -D -u 1000 "${USER}" \
  && chown -R "${USER}" /home/"${USER}" \
  && chmod -R 750 /home/"${USER}"

USER "${USER}"

LABEL io.jenkins-infra.tools="golang,terraform,tfsec,golangci-lint,aws-cli"
LABEL io.jenkins-infra.tools.terraform.version="${TERRAFORM_VERSION}"
LABEL io.jenkins-infra.tools.golang.version="${GO_VERSION}"
LABEL io.jenkins-infra.tools.tfsec.version="${TFSEC_VERSION}"
LABEL io.jenkins-infra.tools.golangci-lint.version="${GOLANGCILINT_VERSION}"
LABEL io.jenkins-infra.tools.aws-cli.version="${AWS_CLI_VERSION}"

WORKDIR /app

CMD ["/bin/bash"]
