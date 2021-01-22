# Golang is required for terratest
# 1.15 ensure that the latest patch is always used but avoiding breaking changes when Golang as a minor upgrade
# Alpine is used by default for fast and ligthweight customization
ARG GO_VERSION=1.15
FROM golang:"${GO_VERSION}-alpine"

## Repeating the ARG to add it into the scope of this image
ARG GO_VERSION

RUN apk add --no-cache \
  # To allow easier CLI completion + running shell scripts with array support
  bash=~5 \
  # Used to download binaries (implies the package "ca-certificates" as a dependency)
  curl=~7 \
  # Dev. Tooling packages (e.g. tools provided by this image installable through Alpine Linux Packages)
  make=~4 \
  # Used to unarchive Terraform downloads
  unzip=~6

### Install Terraform CLI
# Retrieve SHA256sum from https://releases.hashicorp.com/terraform/<TERRAFORM_VERSION>/terraform_<TERRAFORM_VERSION>_SHA256SUMS
# For instance: "
# TERRAFORM_VERSION=X.YY.Z
# curl -sSL https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_SHA256SUMS | grep linux_amd64
ENV TERRAFORM_VERSION=0.13.6 \
  TERRAFORM_ARCHIVE_SHA256=55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9

RUN curl --silent --show-error --location --remote-name \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin \
  && rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && terraform --version

LABEL io.jenkins-infra.tools="golang,terraform"
LABEL io.jenkins-infra.tools.terraform.version="${TERRAFORM_VERSION}"
LABEL io.jenkins-infra.tools.golang.version="${GO_VERSION}"
