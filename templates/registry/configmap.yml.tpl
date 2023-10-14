{{- $name := .Release.Name -}}
{{- $namespace := .Release.Namespace -}}

apiVersion: v1
data:
  config.yml: |-
    version: 0.1
    {{ if .Values.registry.redis.enabled }}
    redis:
      addr: {{ .Values.registry.redis.host }}:{{ .Values.registry.redis.port }}
      password: {{ .Values.registry.redis.password }}
    {{end}}
    log:
      fields:
        service: registry
    storage:
      delete:
        enabled: true
      cache:
        {{ if .Values.registry.redis.enabled }}
        blobdescriptor: redis
        {{else}}
        blobdescriptor: inmemory
        {{end}}

      {{if .Values.registry.s3 }}
      s3:
        accesskey: {{ .Values.registry.s3.accessKey }}
        secretkey: {{ .Values.registry.s3.secretKey }}
        region: {{ .Values.registry.s3.region }}
        bucket: {{ .Values.registry.s3.bucket }}
        {{ if .Values.registry.s3.regionEndpoint }}
        regionendpoint: {{ .Values.registry.s3.regionEndpoint }}
        {{end}}
      {{else}}
      filesystem:
        rootdirectory: /var/lib/registry
      {{end}}

    http:
      addr: :5000
      headers:
        X-Content-Type-Options: [nosniff]
    health:
      storagedriver:
        enabled: true
        interval: 10s
        threshold: 3

    notifications:
      events:
        includereferences: true
      endpoints:
        - name: alistener
          disabled: false
          url: http://svc-{{$name}}-platform-registry-api.{{$namespace}}.svc.cluster.local/events
          timeout: 1s
          threshold: 10
          backoff: 1s
          ignoredmediatypes:
            - application/octet-stream

kind: ConfigMap
metadata:
  name: {{ $name }}
