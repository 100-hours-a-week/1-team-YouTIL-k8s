{{/* Generate a fullname using the release name and chart name */}}
{{- define "youtil-be.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Common labels */}}
{{- define "youtil-be.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
