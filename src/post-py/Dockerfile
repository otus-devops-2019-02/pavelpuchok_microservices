FROM python:3.6.0-alpine

RUN apk add --no-cache build-base=0.4-r1 && \
        rm -rf /var/cache/apk/*

WORKDIR /app
COPY . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
