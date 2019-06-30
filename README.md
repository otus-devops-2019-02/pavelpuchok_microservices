# pavelpuchok_microservices
pavelpuchok microservices repository

# docker 1
Добавлены конфиг для тревиса и шаблон PR github.
Разобраны разные команды для работы с контейнерами и изображениями.
Рассмотрены результаты вывода inspect для контейнера и изображения.

# docker 2
Рассмотрен способ создания docker-host
Создан образ reddit приложения и запушен в docker hub (pavelpuchok/otus-reddit)

# docker 3
В процессе создания post образа, пришлось доустановить GCC для компилирования зависимостей thriftpy в post-py, а так же поменять версию базового ruby образа для ui и comments образов.

Запуск с разными network alias:
```
!# /usr/bin/env bash

VERSION="2.0"

COMMENT_DB_HOST=test_comment_db
POST_DB_HOST=test_post_db
COMMENT_SERVICE_HOST=test_comment_service
POST_SERVICE_HOST=test_post_service

docker run -d --network=reddit \
    --network-alias=${POST_DB_HOST} \
    --network-alias=${COMMENT_DB_HOST} \
    --name=mongo \
    mongo:latest

docker run -d --network=reddit \
    --network-alias=${POST_SERVICE_HOST} \
    --env POST_DATABASE_HOST=${POST_DB_HOST} \
    --name=post \
    pavelpuchok/post:${VERSION}

docker run -d --network=reddit \
    --network-alias=${COMMENT_SERVICE_HOST} \
    --env COMMENT_DATABASE_HOST=${COMMENT_DB_HOST} \
    --name=comment \
    pavelpuchok/comment:${VERSION}

docker run -d --network=reddit \
    --env COMMENT_SERVICE_HOST=${COMMENT_SERVICE_HOST} \
    --env POST_SERVICE_HOST=${POST_SERVICE_HOST} \
    -p 9292:9292 \
    --name=ui \
    pavelpuchok/ui:${VERSION}
```

# docker 4
При попытке запустить несколько nginx в сети host работает только первый запущенный. Остальные не могут запуститься так как 80-ый порт в хостовой сети уже занят первым контейнером. Убедиться в этом можно посмотрев логи упавших контейнеров:

```
docker logs f54
2019/06/09 08:10:15 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2019/06/09 08:10:15 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2019/06/09 08:10:15 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2019/06/09 08:10:15 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2019/06/09 08:10:15 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
2019/06/09 08:10:15 [emerg] 1#1: still could not bind()
nginx: [emerg] still could not bind()
```

При помощи ``ip netns`` мы можем убедиться что тип сети none создает отдельный NS для каждого контейнера, в то время как сеть host использует NS хостовой машины.

При присоединении уже созданных контейнеров к сети необходимо помнить, алиас сети указанный при создании контейнера исопльзуется только в сети к которой он присоеденится при создании. Т.е. при необходимости, надо дополнительно указывать алиасы: ``docker network connect --alias container_alias network_name container_id``

## docker-compose
Базовое имя проекта конфигурируется с помощью аргумента CLI (-p) или через enviroment variables. Из официальной документации:
> The default project name is the basename of the project directory. You can set a custom project name by using the -p command line option or the COMPOSE_PROJECT_NAME environment variable.

# monitoring

[Docker Hub с собранными образами](https://hub.docker.com/u/pavelpuchok)

### mongodb-exporter
Для мониторинга MongoDB используется кастомный образ [mongodb-exporter от percona](https://github.com/percona/mongodb_exporter), т.к. сборки от автора на Docker Hub нету.

### blackbox-exporter
Экспортер это бинарь который слушает endpoint `/probe`.
Эндпоинт принимает параметры `target` и `module`. `target` - хост или урл который надо проверить. `module` - отвечает за prober котороый будет делать запрос на таргет. Пример: `/probe?module=http_2xx&target=example.com/mytargetendpoint`
Ответом на `/probe` запрос будут метрики состояния для указанного `target`

Для настройки экспортера используется relabel_configs.
**relabel_configs** - позволяет изменять, удалять, добавлять label к метрикам. Для настройки экспортера используется следующий relabel конфиг:

```
    relabel_configs:
      # берем из метрики label __address__ и копируем в __param_target label
      - source_labels: [__address__]
        target_label: __param_target # __param_target используется экспортером как значение target
      # берем из метрики label __param_target и копируем в instance label
      - source_labels: [__param_target]
        target_label: instance
      # устанавалием label __address__ в значение из replacement
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

Больше инфы про relabel_configs и blackbox-exporter:
 * [Some notes on Prometheus's Blackbox exporter](https://utcc.utoronto.ca/~cks/space/blog/sysadmin/PrometheusBlackboxNotes)
 * [Taking advantage of Prometheus relabeling](https://www.slideshare.net/roidelapluie/taking-advantage-of-prometheus-relabeling-109483749)
 * [Prometheus relabeling tricks](https://medium.com/quiq-blog/prometheus-relabeling-tricks-6ae62c56cbda)
 * [Устройство и механизм работы Prometheus Operator в Kubernetes](https://habr.com/ru/company/flant/blog/353410/)
