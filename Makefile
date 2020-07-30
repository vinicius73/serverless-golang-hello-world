.PHONY: build clean deploy install run

ROOT_DIR=$(shell pwd)
SRC_DIR=${ROOT_DIR}/src
BIN_DIR=${ROOT_DIR}/bin

define build
	echo "Building '${1}'" && \
	cd ${SRC_DIR} && \
	env GOOS=linux go build -ldflags="-s -w" -o ${BIN_DIR}/${1} handlers/${1}/main.go

endef

install: ## Install dependencies
	- cd ${SRC_DIR} && go mod vendor
	- docker pull lambci/lambda:go1.x
	- yarn install

build: ## Build functions
	- @$(call build,hello)
	- @$(call build,world)

run: clean build ## Run local development server
	- npx serverless offline --useDocke

clean: ## Clear build files
	- rm -rf ./bin

deploy: clean build ## Run deploy command
	- sls deploy --verbose

help: ## Show makefile helper
	- @printf '\e[1;33m%-6s\e[m' "Makefile available commands"
	- @echo ''
	- @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	- @echo ""
