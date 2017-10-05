APPLICATION_NAME=lock-api-ex-test
TEAM=video-apis
DOCKER_IMAGE_NAME="tsuru/elixir"
MIX_ENV?=prod
APP_REMOTE_DIR:=/home/ubuntu/src/${APPLICATION_NAME}
LOCAL_RELEASE_DIR=rel/releases/$(MIX_ENV)/$(VERSION)
GITHUB_APP_NAME=lock-api-test
CLONE_URL=https://codeload.github.com/HugoLnx/${GITHUB_APP_NAME}/tar.gz/${VERSION}
TMP_FILE_NAME=.tmp_$(APPLICATION_NAME).tar.gz
TSURU_APP_NAME?=lock-api-ex-test

###################
## COMMON DEPLOY ##
###################
release: prepare_build create_container generate_release remove_container tsuru_deploy
direct_release: prepare_build create_container generate_release remove_container direct_deploy

generate_release:
	echo "Generating release to ${MIX_ENV}"
	$(call docker_prepare_version,${DOCKER_ID},${VERSION})
	$(call docker_build_release,${DOCKER_ID},${VERSION})
	$(call docker_save_result,${DOCKER_ID},${VERSION})

#############
## PRIVATE ##
#############
prepare_build:
	$(call check_defined, VERSION)
	rm -rf $(LOCAL_RELEASE_DIR)
	mkdir -p $(LOCAL_RELEASE_DIR)

create_container:
	$(eval DOCKER_ID=$(shell docker run -d $(DOCKER_IMAGE_NAME) tail -f /dev/null))
	docker exec $(DOCKER_ID) /bin/bash -c "mkdir -p ${APP_REMOTE_DIR}"

remove_container:
	docker rm -f ${DOCKER_ID}

tsuru_deploy:
	rm -rf tmp_deploy
	mkdir -p tmp_deploy
	cp Procfile tsuru.yml tmp_deploy
	mv ${TMP_FILE_NAME} tmp_deploy
	tsuru bluegreen pre -t ${VERSION}
	rm -rf tmp_deploy

direct_deploy:
	rm -rf tmp_deploy
	mkdir -p tmp_deploy
	cp Procfile tsuru.yml tmp_deploy
	mv ${TMP_FILE_NAME} tmp_deploy
	tsuru app-deploy tmp_deploy --app ${TSURU_APP_NAME}
	rm -rf tmp_deploy

tsuru_swap:
	tsuru bluegreen swap

define docker_prepare_version
	# docker exec $(1) /bin/bash -c "sudo apt-get update -y && sudo apt-get install -y git"
	docker exec $(1) /bin/bash -c "curl -o ${APP_REMOTE_DIR}/${APPLICATION_NAME}.tar.gz ${CLONE_URL}"
	docker exec $(1) /bin/bash -c "cd ${APP_REMOTE_DIR} && tar xvzf ${APPLICATION_NAME}.tar.gz && mv ${GITHUB_APP_NAME}-* ${APPLICATION_NAME}"
	docker exec $(1) /bin/bash -c "cd ${APP_REMOTE_DIR}/${APPLICATION_NAME} && mix local.hex --force && mix local.rebar --force && mix deps.get"
endef

define docker_build_release
	docker exec $(1) /bin/bash -c "cd ${APP_REMOTE_DIR}/${APPLICATION_NAME}; MIX_ENV=${MIX_ENV} mix release --env=prod"
endef

define docker_build_upgrade
	docker exec $(1) /bin/bash -c "cd ${APP_REMOTE_DIR}/${APPLICATION_NAME}; MIX_ENV=${MIX_ENV} mix release --upgrade --env=prod"
endef

define docker_save_result
	$(eval BUILD_TAR_GZ=$(APP_REMOTE_DIR)/${APPLICATION_NAME}/_build/${MIX_ENV}/rel/${APPLICATION_NAME}/releases/$(2)/$(APPLICATION_NAME).tar.gz)
	docker cp $(1):$(BUILD_TAR_GZ) ${TMP_FILE_NAME}
endef

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
