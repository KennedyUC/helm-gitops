SHELL := /bin/bash

CWD:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

DOCKER_PASSWORD ?=
DOCKER_USERNAME ?=
ENV ?= dev
VERSION ?= v1.0.0
APP_NAMESPACE ?= fastapi-app


.PHONY: install-skaffold
install-skaffold:
	@curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
	sudo install skaffold /usr/local/bin/

.PHONY: install-helm
install-helm:
	@curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
	@sudo apt-get install apt-transport-https --yes
	@echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
	@sudo apt-get update
	@sudo apt-get install helm

.PHONY: install-argocd
install-argocd:
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@brew install argocd

.PHONY: docker-login
docker-login:
	@echo $(DOCKER_PASSWORD) | docker login -u $(DOCKER_USERNAME) --password-stdin

.PHONY: skaffold-build
skaffold-build:
	@skaffold build \
		--platform linux/amd64 \
		--default-repo="$(DOCKER_USERNAME)" \
		--cache-artifacts=false \
		--tag $(VERSION)-$(ENV) \
		--push

.PHONY: update-chart-values
update-chart-values:
	@pushd $(CWD)/app-chart && \
	sed -i "s|namespace: [^ ]*:[^ ]*|namespace: $(APP_NAMESPACE)|g" values.yaml && \
	sed -i "s|image: [^ ]*:[^ ]*|image: $(DOCKER_USERNAME)/fastapi-app|g" values.yaml && \
	sed -i "s|tag: [^ ]*:[^ ]*|tag: $(VERSION)-$(ENV)|g" values.yaml && \
	popd

.PHONY: set-argocd-password
set-argocd-password:
	@argocd admin initial-password -n argocd
	@argocd account update-password

.PHONY: open-argocd-ui
open-argocd-ui:
	@echo "The Argocd server can be accessed using https://localhost:8080"
	@kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: deploy-app
deploy-app:
	@pushd $(CWD)/argocd-app && \
	kubectl apply -f fastapi-app.yaml && \
	popd