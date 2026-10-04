# Salt Docker Images — local build & test
#
# Usage:
#   make build-salt-core                          # build salt-core with default version
#   make build-salt-core SALT_VERSION=3007.1      # build salt-core with specific version
#   make build-kitchen PLATFORM=kitchen-debian-12  # build one kitchen image
#   make build-kitchen-all                         # build all kitchen images
#   make test-salt-core                            # build + quick smoke test
#   make test-kitchen PLATFORM=kitchen-ubuntu-2404 # build + smoke test kitchen image
#   make clean                                     # remove built images

SALT_VERSION   ?= 3006.9
REGISTRY       ?= ghcr.io
REPO           ?= someblackmagic/salt-docker-images

SALT_CORE_IMAGE = $(REGISTRY)/$(REPO)/salt-core:$(SALT_VERSION)
KITCHEN_IMAGE   = $(REGISTRY)/$(REPO)/$(PLATFORM):$(SALT_VERSION)

PLATFORM       ?= kitchen-debian-12

KITCHEN_PLATFORMS = \
	kitchen-debian-12 \
	kitchen-ubuntu-2204 \
	kitchen-ubuntu-2404 \
	kitchen-rockylinux-9 \
	kitchen-amazonlinux-2023 \
	kitchen-centos-stream-9 \
	kitchen-almalinux-9 \
	kitchen-opensuse-leap-15

.PHONY: build-salt-core test-salt-core \
        build-kitchen build-kitchen-all test-kitchen test-kitchen-all \
        clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ---------- salt-core ----------

build-salt-core: ## Build salt-core image
	docker build \
		--build-arg SALT_VERSION=$(SALT_VERSION) \
		-t salt-core:$(SALT_VERSION) \
		-t $(SALT_CORE_IMAGE) \
		salt-core/

test-salt-core: build-salt-core ## Build & smoke-test salt-core
	@echo "--- smoke test: salt-core:$(SALT_VERSION) ---"
	docker run --rm salt-core:$(SALT_VERSION) salt-call --version
	docker run --rm salt-core:$(SALT_VERSION) salt --version
	docker run --rm salt-core:$(SALT_VERSION) salt-ssh --version
	@echo "--- PASS ---"

# ---------- kitchen ----------

build-kitchen: ## Build one kitchen image (PLATFORM=kitchen-debian-12)
	docker build \
		--build-arg SALT_VERSION=$(SALT_VERSION) \
		-t $(PLATFORM):$(SALT_VERSION) \
		-t $(KITCHEN_IMAGE) \
		salt-kitchen/$(PLATFORM)/

build-kitchen-all: ## Build all kitchen images
	@for p in $(KITCHEN_PLATFORMS); do \
		echo "=== Building $$p ($(SALT_VERSION)) ==="; \
		$(MAKE) build-kitchen PLATFORM=$$p SALT_VERSION=$(SALT_VERSION) || exit 1; \
	done

test-kitchen: build-kitchen ## Build & smoke-test one kitchen image
	@echo "--- smoke test: $(PLATFORM):$(SALT_VERSION) ---"
	docker run --rm $(PLATFORM):$(SALT_VERSION) cat /etc/os-release
	@echo "--- PASS ---"

test-kitchen-all: ## Smoke-test all kitchen images
	@for p in $(KITCHEN_PLATFORMS); do \
		$(MAKE) test-kitchen PLATFORM=$$p SALT_VERSION=$(SALT_VERSION) || exit 1; \
	done

# ---------- all ----------

build-all: build-salt-core build-kitchen-all ## Build everything

test-all: test-salt-core test-kitchen-all ## Test everything

# ---------- clean ----------

clean: ## Remove locally built images
	-docker rmi salt-core:$(SALT_VERSION) $(SALT_CORE_IMAGE) 2>/dev/null
	@for p in $(KITCHEN_PLATFORMS); do \
		docker rmi $$p:$(SALT_VERSION) $(REGISTRY)/$(REPO)/$$p:$(SALT_VERSION) 2>/dev/null; \
	done || true
