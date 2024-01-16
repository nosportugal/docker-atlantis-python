FROM ghcr.io/runatlantis/atlantis:v0.27.0
RUN apk add python3 --no-cache
COPY ./policies /policies