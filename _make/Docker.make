

.DEFAULT_GOAL := help
.PHONY: help all clean distclean stop-containers clean-containers clean-images clean-volumes rebuild done clean-src local-src
HELP_COL_WIDTH=24


DOCKER_PREFIX = $(shell basename $$(pwd))

# Override these in $(dirname).d if necessary
REMOTE_DOCKER = cntrm00:5000
REMOTE_DOCKER_GATEWAY = nobody@example.com
LOCAL_PORT = 5001
# linux:
LOCAL_REGISTRY = localhost
# macOS:
LOCAL_REGISTRY = docker.for.mac.localhost


VOLUMES := $(basename $(wildcard *.volume))
VOLUME_TARGETS := $(addprefix build/,$(addsuffix .volume,$(IMAGES)))
IMAGES := $(basename $(wildcard *.dockerfile))
IMAGE_TARGETS := $(addprefix build/,$(addsuffix .image,$(IMAGES)))
CONTAINERS := $(basename $(wildcard *.runfile))
CONTAINER_TARGETS := $(addprefix build/,$(addsuffix .container,$(CONTAINERS)))


# build specifics
build/%.image: NAME = $(shell basename "$@" .image)
build/%.container: NAME = $(shell basename "$@" .container)
build/%.container: IMAGE = $(shell basename "$<" .image)
build/%.container: ARGS = $(shell cat "$$(basename "$@" .container).runfile" | grep -v ^# | tr '\n' ' ' )
build/%.volume: NAME = $(shell basename "$@" .container)
# pull in dependency info
-include $(DOCKER_PREFIX).d


help:	## Show this help message
	@grep -hE '^\S+.*##.*' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_COL_WIDTH)s\033[0m %s\n", $$1, $$2}'


all: volumes containers done 	## Build all volumes, images, and containers and run them


stage-prod: build/$(DOCKER_PREFIX)-live.image	## Stage the live image for deployment
	docker tag $(DOCKER_PREFIX)-live $(LOCAL_REGISTRY):$(LOCAL_PORT)/$(DOCKER_PREFIX)
	pkill -f 'ssh -fNL $(LOCAL_PORT)' || true
	ssh -fNL $(LOCAL_PORT):$(REMOTE_DOCKER) $(REMOTE_DOCKER_GATEWAY)
	docker login $(LOCAL_REGISTRY):$(LOCAL_PORT)
	docker push $(LOCAL_REGISTRY):$(LOCAL_PORT)/$(DOCKER_PREFIX)
ifdef DOCKERSCRIPT
	touch "$(DOCKERSCRIPT)"
endif
	@../../_scripts/00_done_notify.sh "Staging production image complete."



volumes: $(VOLUME_TARGETS)	## Create volume(s)


containers: $(CONTAINER_TARGETS)	## Create and run container(s)


images: $(IMAGE_TARGETS)	## Create image(s)


# $(LOCAL_SRC_FILES): %: $(VIRTUALENV)/%
# 	@echo "Updating code - changed files"
# 	cp $< $@
#
#
# $(LOCAL_SRC): %: $(VIRTUALENV)/%
# 	@echo "Updating code - add or deleted files"
# 	@mkdir -p $(@D)
# 	rsync $(RSYNC_FLAGS) $</* $@/
# 	touch $@
#
#
# local-src: $(LOCAL_SRC) $(LOCAL_SRC_FILES)


build/%.image: %.dockerfile
	if docker ps --format '{{.Names}}' | grep ^$(NAME); then docker stop "$(NAME)" ; fi
	if docker ps -a --format '{{.Names}}' | grep ^$(NAME); then docker rm "$(NAME)"; fi
	if docker images --format '{{.Repository}}' | grep $(NAME); then docker rmi "$(NAME)"; fi
	docker build --no-cache -t $(NAME) -f "$<" assets/
	@mkdir -p $(@D)
	touch "$@"


build/%.container: build/%.image %.runfile
	if docker ps --format '{{.Names}}' | grep ^$(NAME); then docker stop "$(NAME)" ; fi
	if docker ps -a --format '{{.Names}}' | grep ^$(NAME); then docker rm "$(NAME)"; fi
	docker run --name $(NAME) -d --restart=always $(ARGS) $(IMAGE)
	@mkdir -p $(@D)
	touch "$@"
	if test -f $(NAME).postrun; then bash $(NAME).postrun; fi



build/%.volume:
	docker volume create $(NAME)
	@mkdir -p $(@D)
	touch "$@"


clean: clean-images ## Stop and remove all relevant containers and images


clean-src:
	rm -rf src/*


distclean: clean clean-volumes clean-src	## Stop and remove all gauss-eparch-app containers, images, and volumes


stop-containers:	## Stop all running gauss-eparch-app containers
	for m in $$(docker ps --format '{{.Names}}\t{{.Image}}' | grep ^$(DOCKER_PREFIX)- | cut -f 1); do docker stop "$$m" ; done


clean-containers: stop-containers	## Remove all gauss-eparch-app containers
	for m in $$(docker ps -a --format '{{.Names}}\t{{.Image}}' | grep ^$(DOCKER_PREFIX)- | cut -f 1); do docker rm "$$m"; done
	rm -f build/*.container


clean-images: clean-containers	## Remove all gauss-eparch-app images
	for m in $$(docker images --format '{{.Repository}}' | grep $(DOCKER_PREFIX)-); do docker rmi "$$m"; done
	rm -f build/*.image


clean-volumes: stop-containers
	for v in $$(docker volume ls --format '{{.Name}}' | grep $(DOCKER_PREFIX)-); do docker volume rm "$$v"; done
	rm -f build/*.volume


rebuild: clean all	## Shortcut for clean then all


done:
	@../../_scripts/00_done_notify.sh "Docker build complete."
