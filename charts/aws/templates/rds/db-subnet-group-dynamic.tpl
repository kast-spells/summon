{{/*kast - Kubernetes arcane spelling technology
Copyright (C) 2026  kazapeke@gmail.com
Licensed under the GNU GPL v3. See LICENSE file for details.
*/}}
{{- define "aws.db-subnet-group" }}
{{- $root := index . 0 -}}
{{- $glyphDefinition := index . 1 }}
---
apiVersion: rds.services.k8s.aws/v1alpha1
kind: DBSubnetGroup
metadata:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  namespace: {{ default $root.Release.Namespace $glyphDefinition.namespace }}
  labels:
    {{- include "common.all.labels" $root | nindent 4 }}
    {{- with $glyphDefinition.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    services.k8s.aws/adoption-policy: {{ default "adopt" $glyphDefinition.adoptionPolicy }}
    {{- with $glyphDefinition.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  description: {{ default (printf "Subnet group for %s" (default (include "common.name" $root) $glyphDefinition.name)) $glyphDefinition.description | quote }}
  {{- if $glyphDefinition.subnetIDs }}
  {{/* Direct subnet IDs provided */}}
  subnetIDs:
    {{- range $glyphDefinition.subnetIDs }}
    - {{ . }}
    {{- end }}
  {{- else if $glyphDefinition.subnets }}
  {{/* Use runicIndexer to discover subnets */}}
  subnetIDs:
    {{- range $subnet := $glyphDefinition.subnets }}
      {{- if $subnet.selector }}
        {{- $results := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $subnet.selector) "aws-subnet" $root.Values.chapter.name) | fromJson) "results" }}
        {{- range $result := $results }}
    - {{ $result.id }}
        {{- end }}
      {{- else if $subnet.id }}
    - {{ $subnet.id }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- with $glyphDefinition.tags }}
  tags:
    {{- range . }}
    - key: {{ .key }}
      value: {{ .value }}
    {{- end }}
  {{- end }}
{{- end }}
