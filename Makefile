all: build push

build: build-ui build-comment build-post build-mongodb-exporter build-prometheus

build-ui:
	@echo ">>> building ui"
	cd src/ui; bash docker_build.sh

build-comment:
	@echo ">>> building comment"
	cd src/comment; bash docker_build.sh

build-post:
	@echo ">>> building post"
	cd src/post-py; bash docker_build.sh

build-mongodb-exporter:
	@echo ">>> building mongodb-exporter"
	docker build -t ${USER_NAME}/mongodb-exporter monitoring/mongodb-exporter

build-prometheus:
	@echo ">>> building prometheus"
	docker build -t ${USER_NAME}/prometheus monitoring/prometheus

push: push-ui push-comment push-post push-mongodb-exporter push-prometheus

push-ui:
	@echo ">>> pushing ui"
	docker push ${USER_NAME}/ui

push-comment:
	@echo ">>> pushing comment"
	docker push ${USER_NAME}/comment

push-post:
	@echo ">>> pushing post"
	docker push ${USER_NAME}/post

push-mongodb-exporter:
	@echo ">>> pushing mongodb-exporter"
	docker push ${USER_NAME}/mongodb-exporter

push-prometheus:
	@echo ">>> pushing prometheus"
	docker push ${USER_NAME}/prometheus
