default: ;

.PHONY: repos
repos:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add gitlab https://charts.gitlab.io
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

################################################################################

# test-app

.PHONY: test-app-db
test-app-db:
	kubectl create namespace $(namespace) || true
	helm upgrade --install -f test-app-db-values.yaml -n $(namespace) test-app-db bitnami/postgresql

.PHONY: test-app-backend
test-app-backend: test-app-db
	kubectl create namespace $(namespace) || true
	helm upgrade --install -n $(namespace) test-app-backend test-app-backend/chart

.PHONY: test-app-frontend
test-app-frontend:
	kubectl create namespace $(namespace) || true
	helm upgrade --install -n $(namespace) test-app-frontend test-app-frontend/chart

################################################################################

# Monitoreo
# 
# OLD: https://blog.marcnuri.com/prometheus-grafana-setup-minikube

.PHONY: loki
loki:
	kubectl create namespace monitoreo || true
	helm upgrade --install -n monitoreo -f loki-values.yaml loki grafana/loki-stack

.PHONY: kube-prometheus-stack
kube-prometheus-stack:
	kubectl create namespace monitoreo || true
	helm -n monitoreo upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack

################################################################################

# CICD

.PHONY: gitlab-runner
gitlab-runner:
	kubectl create namespace gitlab-runner || true
	helm upgrade --install -f gitlab-runner-values.yaml -n gitlab-runner gitlab-runner gitlab/gitlab-runner
	kubectl apply -f cluster-admin-rolebinding.yaml 
