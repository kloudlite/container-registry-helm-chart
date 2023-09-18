{{- $name := print (include "registry-helmchart.fullname" .) "-auth" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: {{ .Values.clusterIssuer }}
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
