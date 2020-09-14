# Override the default common all.
.PHONY: all
all: precheck style unused build test

DOCKER_ARCHS      ?= $(shell uname -m)
DOCKER_IMAGE_NAME ?= ipmi-exporter
DOCKER_REPO       ?= carlosedp
PLATFORMS=linux/amd64 linux/arm64 linux/arm linux/ppc64le

temp = $(subst /, ,$@)
os = $(word 1, $(temp))
arch = $(word 2, $(temp))
noop=
space = $(noop) $(noop)
comma = ,

all: $(PLATFORMS)

$(PLATFORMS):
	GOOS=$(os) GOARCH=$(arch) CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-s -w -extldflags "-static"' -o ${DOCKER_IMAGE_NAME}-$(os)-$(arch)

docker-local: $(PLATFORMS)
	docker buildx build -t ${DOCKER_REPO}/${DOCKER_IMAGE_NAME} --platform=$(subst $(space),$(comma),$(PLATFORMS)) --no-cache --push -f Dockerfile-local .

include Makefile.common

docker: common-docker
