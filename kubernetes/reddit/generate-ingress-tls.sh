#!/usr/bin/env sh

SUBJECT=$1

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=${SUBJECT}"

cat ingress-tls.yml.tpl | sed "s/%key%/$(cat tls.key | base64 -w 0)/" | sed "s/%crt%/$(cat tls.crt | base64 -w 0)/" > ingress-tls.yml
