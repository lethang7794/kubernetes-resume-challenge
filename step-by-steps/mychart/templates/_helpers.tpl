{{/* Generate basic labels */}}
{{- define "mychart.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
    chart: {{ $.Chart.Name }}
    version: {{ $.Chart.Version }}
{{- end }}

{{- define "mychart.app" -}}
myAppName: {{ .Chart.Name }}
myAppVersion: "{{ .Chart.Version }}"
{{- end -}}