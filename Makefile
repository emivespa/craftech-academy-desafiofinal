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

# https://blog.marcnuri.com/prometheus-grafana-setup-minikube

.PHONY: prometheus
prometheus:
	kubectl create namespace monitoreo || true
	# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	# helm repo update
	helm upgrade --install -n monitoreo prometheus prometheus-community/prometheus
	kubectl -n monitoreo expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
	# minikube service prometheus-server-np -n monitoreo
	# # Add datasource to grafana as http://service:port

.PHONY: grafana
grafana:
	kubectl create namespace monitoreo || true
	# helm repo add grafana https://grafana.github.io/helm-charts
	# helm repo update
	helm upgrade --install -f grafana-values.yaml -n monitoreo grafana grafana/grafana
	kubectl -n monitoreo expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
	kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
	# minikube service grafana-np -n monitoreo
	# # Add prometheus and loki datasources as http://service:port
	# TODO: add gitlab-runner dashboards.
	# TODO: configure datasources via values?

.PHONY: loki
loki:
	kubectl create namespace monitoreo || true
	# helm repo add grafana https://grafana.github.io/helm-charts
	# helm repo update
	helm upgrade --install -n monitoreo loki grafana/loki-stack
	# # Add datasource to grafana as http://service:port

################################################################################

# CICD

.PHONY: gitlab-runner
gitlab-runner:
	kubectl create namespace gitlab-runner || true
	# helm repo add gitlab https://charts.gitlab.io
	# helm repo update
	helm upgrade --install -f gitlab-runner-values.yaml -n gitlab-runner gitlab-runner gitlab/gitlab-runner
	k apply -f cluster-admin-rolebinding.yaml 
