{{- $name := print (include "registry-helmchart.fullname" .) "-registry" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: cluster-issuer
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/preserve-trailing-slash: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: 200m
    nginx.ingress.kubernetes.io/proxy-buffer-size: 10k
    nginx.ingress.kubernetes.io/auth-url: https://{{ .Values.authHost }}

  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ingressClassName: {{ .Values.ingressClassName }}
  rules:
  - host: {{ .Values.registryHost }} }}}
    http:
      paths:
      - backend:
          service:
            name: {{ $name }}
            port:
              number: 80
        path: /(.*)
        pathType: Prefix

  {{ if .Values.tls }}
  tls: {{ .Values.tls | toYaml | nindent 4}}
  {{ end }}

---
apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ports:
  - name: "80"
    port: 80
    protocol: TCP
    targetPort: 5000
  selector:
    app: {{ $name }}

---
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

