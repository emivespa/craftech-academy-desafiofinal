<!-- [Plan de migracion a AWS](https://docs.google.com/document/d/1r4y3ZLJOV95E42FV_pBEpUUAIzd7uj5HfRDfE2F0tAE/edit?usp=sharing) -->

## Running locally

I've set up convenience recipes for setting up the cluster locally,
so after you make sure you've got the submodules and the cluster is up,

```bash
git submodule update --init # If you didn't clone --recursive.
minikube start
```

you can just run these (see `Makefile` for the full commands):

- To spin up the production environment:
  ```bash
  make test-app-db test-app-backend test-app-frontend namespace=prd
  ```
  - You can run the same with `namespace=dev` to set up the dev environment.
  - It'll use the master branch from the modules as well, but CI uses dev.
  - Ideally I'd use Argo or Flux for mapping master/dev -> prod/dev.
- To spin up monitoring:
  ```bash
  make loki kube-prometheus-stack
  ```
  - Default grafana pass is 'prom-operator'.
- To spin up the CI runner:
  ```bash
  make gitlab-runner
  ```
