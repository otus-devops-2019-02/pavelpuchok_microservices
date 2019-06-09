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
