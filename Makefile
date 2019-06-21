CLUSTER_NAME?=local

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

.PHONY: env-configpath
env-configpath:
	@export KUBECONFIG=`kind get kubeconfig-path --name $(CLUSTER_NAME)`

.PHONY: clip-dashboard-token
clip-dashboard-token:
	@KUBECONFIG=`kind get kubeconfig-path --name $(CLUSTER_NAME)` && \
	kubectl get secret/`kubectl get serviceaccounts/admin-user -n kube-system -o jsonpath='{.secrets[0].name}'` -n kube-system -o jsonpath='{.data.token}' | base64 -d -w0 | xclip -sel clip

.PHONY: helm
helm:
	@KUBECONFIG=`kind get kubeconfig-path --name $(CLUSTER_NAME)` && \
	kubectl apply -f ./hack/tiller-clusterRole.yaml && \
	kubectl create sa tiller -n kube-system && \
	kubectl apply -f ./hack/tiller-clusterRoleBinding.yaml && \
	helm init --upgrade --service-account tiller
