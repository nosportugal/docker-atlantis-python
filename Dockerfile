FROM ghcr.io/runatlantis/atlantis:v0.28.3
USER root
RUN apk update && apk add python3 --no-cache && rm -rf /var/cache/apk/*
USER atlantis
COPY ./policies /policies