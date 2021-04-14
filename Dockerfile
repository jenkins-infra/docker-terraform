# Golang is required for terratest
# 1.15 ensure that the latest patch is always used but avoiding breaking changes when Golang as a minor upgrade
# Alpine is used by default for fast and ligthweight customization
ARG GO_VERSION=1.15.11
FROM golang:"${GO_VERSION}-alpine"

## Repeating the ARG to add it into the scope of this image
ARG GO_VERSION=1.15.11

ARG AWS_CLI_VERSION=1.18
RUN apk add --no-cache \
  aws-cli=~"${AWS_CLI_VERSION}" \
  # To allow easier CLI completion + running shell scripts with array support
  bash=~5 \
  # Used to download binaries (implies the package "ca-certificates" as a dependency)
  curl=~7 \
  # Dev. Tooling packages (e.g. tools provided by this image installable through Alpine Linux Packages)
  git=~2 \
  make=~4 \
  # Used to unarchive Terraform downloads
  unzip=~6

## bash need to be installed for this instruction to work as expected
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

### Install Terraform CLI
# Retrieve SHA256sum from https://releases.hashicorp.com/terraform/<TERRAFORM_VERSION>/terraform_<TERRAFORM_VERSION>_SHA256SUMS
# For instance: "
# TERRAFORM_VERSION=X.YY.Z
# curl -sSL https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_SHA256SUMS | grep linux_amd64
ARG TERRAFORM_VERSION=0.13.6
ARG TERRAFORM_ARCHIVE_SHA256=55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9
RUN curl --silent --show-error --location --output /tmp/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && sha256sum /tmp/terraform.zip | grep -q "${TERRAFORM_ARCHIVE_SHA256}" \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && terraform --version | grep "${TERRAFORM_VERSION}"

ARG TFSEC_VERSION=0.39.5
RUN curl --silent --show-error --location --output /tmp/tfsec \
    "https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" \
  && chmod a+x /tmp/tfsec \
  && mv /tmp/tfsec /usr/local/bin/tfsec \
  && tfsec --version | grep "${TFSEC_VERSION}"


ARG GOLANGCILINT_VERSION=1.35.2
RUN curl --silent --show-error --location --fail \
  https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
  | sh -s -- -b "$(go env GOPATH)/bin" "v${GOLANGCILINT_VERSION}"

RUN curl --silent --show-error --location --fail --output /usr/local/bin/aws-iam-authenticator \
  https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator \
  && chmod a+x /usr/local/bin/aws-iam-authenticator \
  && aws-iam-authenticator version

ENV USER=infra
ENV HOME=/home/"${USER}"

RUN adduser -D -u 1000 "${USER}" \
  && chown -R "${USER}" /home/"${USER}" \
  && chmod -R 750 /home/"${USER}"

USER "${USER}"

LABEL io.jenkins-infra.tools="golang,terraform,tfsec,golangci-lint,aws-cli,aws-iam-authenticator"
LABEL io.jenkins-infra.tools.terraform.version="${TERRAFORM_VERSION}"
LABEL io.jenkins-infra.tools.golang.version="${GO_VERSION}"
LABEL io.jenkins-infra.tools.tfsec.version="${TFSEC_VERSION}"
LABEL io.jenkins-infra.tools.golangci-lint.version="${GOLANGCILINT_VERSION}"
LABEL io.jenkins-infra.tools.aws-cli.version="${AWS_CLI_VERSION}"
LABEL io.jenkins-infra.tools.aws-iam-authenticator.version="latest"

WORKDIR /app

CMD ["/bin/bash"]
