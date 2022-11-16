default: ;

.PHONY: namespaces
namespaces:
	kubectl create namespace prd
	kubectl create namespace dev
	kubectl create namespace monitoreo
	kubectl create namespace gitlab-runner

.PHONY: test-app-db
test-app-db:
	kubectl create namespace $(namespace) || true
	# helm repo add bitnami https://charts.bitnami.com/bitnami
	# helm repo update
	kubectl apply -f test-app-db-env.yaml
	helm install -f test-app-db-values.yaml -n $(namespace) test-app-db bitnami/postgresql

################################################################################

# Monitoreo
# 
# OLD: https://blog.marcnuri.com/prometheus-grafana-setup-minikube

.PHONY: loki
loki:
	kubectl create namespace monitoreo || true
	# helm repo add grafana https://grafana.github.io/helm-charts
	# helm repo update
	helm upgrade --install -n monitoreo -f loki-values.yaml loki grafana/loki-stack
	# # Add datasource to grafana as http://service:port

.PHONY: kube-prometheus-stack
kube-prometheus-stack:
	kubectl create namespace monitoreo || true
	# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	# helm repo update
	helm -n monitoreo upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack

################################################################################

# CICD

.PHONY: gitlab-runner
gitlab-runner:
	kubectl create namespace gitlab-runner || true
	# helm repo add gitlab https://charts.gitlab.io
	# helm repo update
	helm upgrade --install -f gitlab-runner-values.yaml -n gitlab-runner gitlab-runner gitlab/gitlab-runner
	kubectl apply -f cluster-admin-rolebinding.yaml 
