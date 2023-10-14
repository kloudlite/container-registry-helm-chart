{{- $name := .Release.Name -}}
{{- $namespace := .Release.Namespace -}}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    {{if .Values.registry.tlsEnabled }}
    cert-manager.io/cluster-issuer: {{ .Values.registry.clusterIssuer }}
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.kubernetes.io/ssl-redirect: "true"
    {{end}}
    nginx.ingress.kubernetes.io/preserve-trailing-slash: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/proxy-body-size: {{ .Values.registry.proxyBodySize }}
    nginx.ingress.kubernetes.io/proxy-buffer-size: {{ .Values.registry.proxyBufferSize }}
    nginx.ingress.kubernetes.io/auth-url: http://svc-{{$name}}-platform-registry-api.{{$namespace}}.svc.cluster.local/auth?path=$request_uri&method=$request_method

  name: {{ $name }}
spec:
  {{ if .Values.registry.tlsEnabled }}
  tls: {{ .Values.registry.tls | toYaml | nindent 4}}
  {{ end }}
  ingressClassName: {{ .Values.registry.ingressClassName }}
  rules:
  - host: {{ .Values.registry.host }}
    http:
      paths:
      - backend:
          service:
            name: svc-{{ $name }}
            port:
              number: 80
        path: /(.*)
        pathType: Prefix
