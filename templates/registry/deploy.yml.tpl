{{- $name := print (include "registry-helmchart.fullname" .) "-registry" -}}
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
        resources: {{ .Values.registryResources | toYaml | nindent 8 }}
        env:
          {{ if .Values.redis }}
          - name: REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR
            value: redis
          - name: REGISTRY_REDIS_ADDR
            value: {{ .Values.redis.host }}:{{ .Values.redis.port }}
          - name: REGISTRY_REDIS_PASSWORD
            value: {{ .Values.redis.password }}
          {{end}}

          - name: REGISTRY_STORAGE
            value: s3

          - name: REGISTRY_STORAGE_S3_REGION
            value: {{ .Values.s3.region }}

          - name: REGISTRY_STORAGE_S3_BUCKET
            value: {{ .Values.s3.bucket }}


          - name: REGISTRY_STORAGE_S3_ACCESSKEY
            value: {{ .Values.s3.accessKey }}

          - name: REGISTRY_STORAGE_S3_SECRETKEY
            value: {{ .Values.s3.secretKey }}

