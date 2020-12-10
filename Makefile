
IMAGE_NAME ?= docker-terraform
IMAGE_TARBALL ?= $(CURDIR)/$(IMAGE_NAME).tar
USE_DOCKER ?= true

### Utility steps
.PHONY: all
all: clean build test

.PHONY: clean
clean:
	@rm -rf $(IMAGE_TARBALL)

### Build steps
build_cmd = img
ifeq ($(USE_DOCKER),true)
	build_cmd := docker run --rm --tty --interactive --volume=$(CURDIR):$(CURDIR) --privileged r.j3ss.co/img:v0.5.11
endif
$(IMAGE_TARBALL):
	@$(build_cmd) build -t $(IMAGE_NAME) -f $(CURDIR)/Dockerfile -o type=docker,dest=$(IMAGE_TARBALL) $(CURDIR)/

.PHONY: build
build: $(IMAGE_TARBALL)
	@echo "Docker Image '$(IMAGE_NAME)' available as tarball archive at '$(IMAGE_TARBALL)'"
#@docker build --tag=$(IMAGE_NAME) $(CURDIR)/

### Testing steps
.PHONY: test
test_cmd = container-structure-test
ifeq ($(USE_DOCKER),true)
	test_cmd := docker run --rm --tty --interactive --volume=$(CURDIR):$(CURDIR) --privileged gcr.io/gcp-runtimes/container-structure-test:v1.9.1
endif
test: $(IMAGE_TARBALL)
	@$(test_cmd) test --driver=tar --image=$(IMAGE_TARBALL) --config $(CURDIR)/cst-test.yaml
