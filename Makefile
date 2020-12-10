
# tag::image_name[]
IMAGE_NAME ?= docker-terraform
# end::image_name[]

.PHONY: all
all: build test

.PHONY: build
build:
	@docker build --tag=$(IMAGE_NAME) $(CURDIR)/

.PHONY: test
test:
	@container-structure-test test --driver=tar --image $(IMAGE_NAME) --config $(CURDIR)/cst-test.yaml
