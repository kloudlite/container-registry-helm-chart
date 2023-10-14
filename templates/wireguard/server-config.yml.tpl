{{- $name := printf "%s-wg-server-config" .Release.Name -}}

apiVersion: v1
kind: Secret
metadata:
  name: {{ $name }}
type: Opaque
data:
  data: '{{- .Values.wgServerConfig | b64enc }}'
