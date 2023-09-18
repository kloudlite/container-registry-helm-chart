{{- $name := print (include "registry-helmchart.fullname" .) "-auth" -}}
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
  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ingressClassName: {{ .Values.ingressClassName }}
  rules:
  - host: {{ .Values.authHost }}}
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
  tls: {{ .Values.tls | toYaml | nindent 4 }}
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
    targetPort: 3000
  selector:
    name: {{ $name }}

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
      - name: auth
        image: ghcr.io/kloudlite/platform/apis/registry-authorizer:v0.0.1
