CLUSTER_NAME:=local

.PHONY: startup
startup: bootstrap addons

.PHONY: bootstrap
bootstrap:
	@echo "+ $@"
	kind create cluster --config kind.config --name $(CLUSTER_NAME)

.PHONY: addons
addons:
	@echo "+ $@"
	CLUSTER_NAME=$(CLUSTER_NAME) ./hack/enabled-addon.sh metrics-server
	CLUSTER_NAME=$(CLUSTER_NAME) ./hack/enabled-addon.sh dashboard
	CLUSTER_NAME=$(CLUSTER_NAME) ./hack/enabled-addon.sh ingress-nginx

.PHONY: clean
clean:
	@echo "+ $@"
	kind delete cluster --name $(CLUSTER_NAME)
