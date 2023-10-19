# ghcr.io/kloudlite/platform/apis/docker:dind
FROM docker:dind

RUN apk add git

ENTRYPOINT ["dockerd-entrypoint.sh"]

