{{- $name := print (include "registry-helmchart.fullname" .) "-config" -}}

apiVersion: v1
data:
  config.yml: |-
    version: 0.1
    log:
      fields:
        service: registry
    storage:
      delete:
        enabled: true
      cache:
        blobdescriptor: inmemory
      filesystem:
        rootdirectory: /var/lib/registry
    http:
      addr: :5000
      headers:
        X-Content-Type-Options: [nosniff]
      secret: {{ .Values.registry.httpsecret }}
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
          url: {{ .Values.registry.eventPushUrl }}
          timeout: 1s
          threshold: 10
          backoff: 1s
          ignoredmediatypes:
            - application/octet-stream
          {{/* ignore: */}}
          {{/*   mediatypes: */}}
          {{/*     - application/octet-stream */}}
          {{/*   actions: */}}
          {{/*     - pull */}}
          {{/*     - push */}}
kind: ConfigMap
metadata:
  name: {{ $name }}
