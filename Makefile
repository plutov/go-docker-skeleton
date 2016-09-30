# The binary to build
BIN := app

# Root import path
PKG := github.com/plutov/go-docker-skeleton

# Registry name
REGISTRY ?= pltvs

# Which architecture to build
ARCH ?= amd64

# To run tests
SRC_DIRS := cmd pkg

# Set default base image dynamically for each arch
ifeq ($(ARCH),amd64)
    BASEIMAGE?=alpine
endif
ifeq ($(ARCH),arm)
    BASEIMAGE?=armel/busybox
endif
ifeq ($(ARCH),arm64)
    BASEIMAGE?=aarch64/busybox
endif
ifeq ($(ARCH),ppc64le)
    BASEIMAGE?=ppc64le/busybox
endif

IMAGE := $(REGISTRY)/$(BIN)-$(ARCH)

BUILD_IMAGE ?= golang:1.7-alpine

VERSION := $(shell git rev-parse HEAD)

all: build

build: bin/$(ARCH)/$(BIN)

bin/$(ARCH)/$(BIN): build-dirs
	@echo "building: $@"
	@docker run \
	    -ti \
	    -u $$(id -u):$$(id -g) \
	    -v $$(pwd)/.go:/go \
	    -v $$(pwd):/go/src/$(PKG) \
	    -v $$(pwd)/bin/$(ARCH):/go/bin \
	    -v $$(pwd)/bin/$(ARCH):/go/bin/$$(go env GOOS)_$(ARCH) \
	    -v $$(pwd)/.go/std/$(ARCH):/usr/local/go/pkg/linux_$(ARCH)_static \
	    -w /go/src/$(PKG) \
	    $(BUILD_IMAGE) \
	    /bin/sh -c " \
	        ARCH=$(ARCH) \
	        VERSION=$(VERSION) \
	        PKG=$(PKG) \
	        ./build/build.sh"

DOTFILE_IMAGE = $(subst /,_,$(IMAGE))-$(VERSION)

container: .container-$(DOTFILE_IMAGE) container-name
.container-$(DOTFILE_IMAGE): bin/$(ARCH)/$(BIN) Dockerfile
	@sed \
	    -e 's|ARG_BIN|$(BIN)|g' \
	    -e 's|ARG_ARCH|$(ARCH)|g' \
	    -e 's|ARG_FROM|$(BASEIMAGE)|g' \
	    Dockerfile > .dockerfile-$(ARCH)
	@docker build -t $(IMAGE):$(VERSION) -f .dockerfile-$(ARCH) .
	@docker images -q $(IMAGE):$(VERSION) > $@

container-name:
	@echo "container: $(IMAGE):$(VERSION)"

push: .push-$(DOTFILE_IMAGE) push-name
.push-$(DOTFILE_IMAGE): .container-$(DOTFILE_IMAGE)
	@docker push $(IMAGE):$(VERSION)
	@docker images -q $(IMAGE):$(VERSION) > $@

push-name:
	@echo "pushed: $(IMAGE):$(VERSION)"

version:
	@echo $(VERSION)

test: build-dirs
	@docker run \
	    -ti \
	    -u $$(id -u):$$(id -g) \
	    -v $$(pwd)/.go:/go \
	    -v $$(pwd):/go/src/$(PKG) \
	    -v $$(pwd)/bin/$(ARCH):/go/bin \
	    -v $$(pwd)/.go/std/$(ARCH):/usr/local/go/pkg/linux_$(ARCH)_static \
	    -w /go/src/$(PKG) \
	    $(BUILD_IMAGE) \
	    /bin/sh -c "./build/test.sh $(SRC_DIRS)"

build-dirs:
	@mkdir -p bin/$(ARCH)
	@mkdir -p .go/src/$(PKG) .go/pkg .go/bin .go/std/$(ARCH)

clean: container-clean bin-clean

container-clean:
	rm -rf .container-* .dockerfile-* .push-*

bin-clean:
	rm -rf .go bin
