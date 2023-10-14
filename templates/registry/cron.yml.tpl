{{- $configName := .Release.Name  -}}
{{- $name := .Release.Name -}}

apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $name }}
spec:
  schedule: "0 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: registry-container
            image: registry:2
            command:
            - /bin/sh
            - -c
            -  registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true
            imagePullPolicy: IfNotPresent
            resources: {{ .Values.registry.resources | toYaml | nindent 14 }}

            volumeMounts:
            - name: config-volume
              mountPath: /etc/docker/registry

          volumes:
          - name: config-volume
            configMap:
              name: {{ $configName }}
