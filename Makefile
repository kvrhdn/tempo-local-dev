run: tk create-cluster tilt

.PHONY: tk
tk:
	$(MAKE) -C tk

.PHONY: create-cluster
create-cluster:
	k3d cluster create local-dev \
	  --registry-create local-dev-registry

.PHONY: destroy-cluster
destroy-cluster:
	k3d cluster delete local-dev

.PHONY: tilt
tilt:
	tilt up

.PHONY: provision-dashboards
provision-dashboards:
	make -C dashboards/
