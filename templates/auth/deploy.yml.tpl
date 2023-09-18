{{- $name := print (include "registry-helmchart.fullname" .) "-auth" -}}
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
      - name: auth
        image: ghcr.io/kloudlite/platform/apis/registry-authorizer:v0.0.1
        env:
        - name: SECRET_KEY
          value: {{ .Values.auth.secretKey }}
