FROM ghcr.io/runatlantis/atlantis:v0.26.0
RUN apk add python3 --no-cache
COPY ./policies /policies