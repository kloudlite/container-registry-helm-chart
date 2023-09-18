{{- $name := print (include "registry-helmchart.fullname" .) "-registry" -}}
{{- $authName := print (include "registry-helmchart.fullname" .) "-auth" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: {{ .Values.registry.clusterIssuer }}
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/preserve-trailing-slash: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: 200m
    nginx.ingress.kubernetes.io/proxy-buffer-size: 10k
    nginx.ingress.kubernetes.io/auth-url: http://{{ $authName }}.{{ $namespace }}.svc.cluster.local

  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ingressClassName: {{ .Values.registry.ingressClassName }}
  rules:
  - host: {{ .Values.registry.host }} }}}
    http:
      paths:
      - backend:
          service:
            name: {{ $name }}
            port:
              number: 80
        path: /(.*)
        pathType: Prefix

  {{ if .Values.registry.tls }}
  tls: {{ .Values.registry.tls | toYaml | nindent 4}}
  {{ end }}
