{{- $name := print (include "registry-helmchart.fullname" .) "-registry" -}}
{{- $configName := print (include "registry-helmchart.fullname" .) "-config" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
  labels:
    app: {{ $name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ $name }}
  template:
    metadata:
      labels:
        app: {{ $name }}
    spec:
      containers:
      - name: registry-container
        image: registry:2
        resources: {{ .Values.registry.resources | toYaml | nindent 10 }}
        env:
          {{ if .Values.registry.redis }}
          - name: REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR
            value: redis
          - name: REGISTRY_REDIS_ADDR
            value: {{ .Values.registry.redis.host }}:{{ .Values.registry.redis.port }}
          - name: REGISTRY_REDIS_PASSWORD
            value: {{ .Values.registry.redis.password }}
          {{end}}

          - name: REGISTRY_STORAGE
            value: s3

          - name: REGISTRY_STORAGE_S3_REGION
            value: {{ .Values.registry.s3.region }}

          - name: REGISTRY_STORAGE_S3_BUCKET
            value: {{ .Values.registry.s3.bucket }}


          - name: REGISTRY_STORAGE_S3_ACCESSKEY
            value: {{ .Values.registry.s3.accessKey }}

          - name: REGISTRY_STORAGE_S3_SECRETKEY
            value: {{ .Values.registry.s3.secretKey }}

        volumeMounts:
        - name: config-volume
          mountPath: /etc/docker/registry

      volumes:
      - name: config-volume
        configMap:
          name: {{ $configName }}
