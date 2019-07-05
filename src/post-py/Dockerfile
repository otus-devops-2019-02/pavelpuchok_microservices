FROM python:3.6.8-alpine3.10

RUN apk add --no-cache build-base=0.5-r1 musl-dev=1.1.22-r2 gcc=8.3.0-r0 && \
        rm -rf /var/cache/apk/*

WORKDIR /app
COPY . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
