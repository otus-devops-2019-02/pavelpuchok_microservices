all: build push

build: build-ui build-comment build-post build-mongodb-exporter build-prometheus build-alertmanager build-fluentd

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

build-alertmanager:
	@echo ">>> building alertmanager"
	docker build -t ${USER_NAME}/alertmanager monitoring/alertmanager

build-fluentd:
	@echo ">>> building fluentd"
	docker build -t ${USER_NAME}/fluentd logging/fluentd

push: push-ui push-comment push-post push-mongodb-exporter push-prometheus push-fluentd

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

push-alertmanager:
	@echo ">>> pushing alertmanager"
	docker push ${USER_NAME}/alertmanager

push-fluentd:
	@echo ">>> pushing fluentd"
	docker push ${USER_NAME}/fluentd

up-all: up-logging up-app up-monitoring

down-all: down-monitoring down-logging down-app

restart-all: down-monitoring restart-logging restart-app up-monitoring

up-monitoring:
	@echo ">>> initializing monitoring services"
	cd docker; docker-compose -f docker-compose-monitoring.yml up -d

down-monitoring:
	@echo ">>> destroying monitoring services"
	cd docker; docker-compose -f docker-compose-monitoring.yml down

restart-monitoring: down-monitoring up-monitoring

up-app:
	@echo ">>> initializing application services"
	cd docker; docker-compose up -d

down-app:
	@echo ">>> destroying application services"
	cd docker; docker-compose down

restart-app: down-app up-app

up-logging:
	@echo ">>> initializing logging services"
	cd docker; docker-compose -f docker-compose-logging.yml up -d

down-logging:
	@echo ">>> destroying logging services"
	cd docker; docker-compose -f docker-compose-logging.yml down

restart-logging: down-logging up-logging
