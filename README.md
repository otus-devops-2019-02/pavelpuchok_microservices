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
