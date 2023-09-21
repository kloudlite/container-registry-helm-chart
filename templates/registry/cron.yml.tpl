{{- $configName := print (include "registry-helmchart.fullname" .) "-config" -}}
{{- $name := print (include "registry-helmchart.fullname" .) "-cron" -}}

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
