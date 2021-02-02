ARG GO_VERSION=1.15

FROM golang:"${GO_VERSION}-alpine"

ARG GO_VERSION

RUN apk add --no-cache   bash=~5   curl=~7   git=~2   make=~4   unzip=~6

SHELL [ "/bin/bash","-o","pipefail","-c" ]

ARG TERRAFORM_VERSION=0.14.5

ARG TERRAFORM_ARCHIVE_SHA256=55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9

RUN curl --silent --show-error --location --output /tmp/terraform.zip     "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"   && \
sha256sum /tmp/terraform.zip | grep -q "${TERRAFORM_ARCHIVE_SHA256}"   && \
unzip /tmp/terraform.zip -d /usr/local/bin   && \
rm -f /tmp/terraform.zip   && \
terraform --version | grep "${TERRAFORM_VERSION}"

ARG TFSEC_VERSION=0.37.1

ARG TFSEC_SHA256=29adc26d88659bc727a0e02546067c1c8398797f5c5bc248abee6e32393f2f20

RUN curl --silent --show-error --location --output /tmp/tfsec     "https://github.com/tfsec/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64"   && \
sha256sum /tmp/tfsec | grep -q "${TFSEC_SHA256}"   && \
chmod a+x /tmp/tfsec   && \
mv /tmp/tfsec /usr/local/bin/tfsec   && \
tfsec --version | grep "${TFSEC_VERSION}"

ENV USER=infra

ENV HOME=/home/"${USER}"

RUN adduser -D -u 1000 "${USER}"   && \
chown -R "${USER}" /home/"${USER}"   && \
chmod -R 750 /home/"${USER}"

USER "${USER}"

LABEL io.jenkins-infra.tools="golang,terraform"

LABEL io.jenkins-infra.tools.terraform.version="${TERRAFORM_VERSION}"

LABEL io.jenkins-infra.tools.golang.version="${GO_VERSION}"

WORKDIR /app

CMD [ "/bin/bash" ]

