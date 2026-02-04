{{/*kast - Kubernetes arcane spelling technology
Copyright (C) 2023 namenmalkv@gmail.com
Licensed under the GNU GPL v3. See LICENSE file for details.
*/}}
{{- define "aws.iam-policy" }}
{{- $root := index . 0 -}}
{{- $glyphDefinition := index . 1}}
{{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name ) | fromJson) "results" }}
{{- $k8sCluster := first $k8sClusters }}
---
apiVersion: iam.services.k8s.aws/v1alpha1
kind: Policy
metadata:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  namespace: {{ default $root.Release.Namespace  $glyphDefinition.namespace }}
  labels:
    {{- include "common.all.labels" $root | nindent 4 }}
    {{- with $glyphDefinition.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $glyphDefinition.annotations }}
  annotations:
    {{- include "common.annotations" $root | nindent 4 }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  {{- with $glyphDefinition.path }}
  path: {{ . }}
  {{- end }}
  description: "{{ default (include "common.name" $root) $glyphDefinition.description }}"
  policyDocument: |
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "{{ $glyphDefinition.resources.effect | title }}",
          "Action": {{ $glyphDefinition.resources.actions | toJson | toString }},
          "Resource": "{{ $glyphDefinition.resources.arn }}"
        }
      ]
    }
  tags:
    - key: Name
      value: {{ default (include "common.name" $root) $glyphDefinition.name }}
    - key: ManagedBy
      value: ack-iam-controller
    {{- if $k8sCluster }}
      {{- if $k8sCluster.clusterName }}
    - key: Cluster
      value: {{ $k8sCluster.clusterName }}
      {{- end }}
      {{- if $k8sCluster.labels.environment }}
    - key: Environment
      value: {{ $k8sCluster.labels.environment }}
      {{- end }}
    {{- end }}
    {{- if $root.Values.book }}
    - key: Application
      value: {{ $root.Values.book.name }}
    {{- end }}
    {{- with $glyphDefinition.component }}
    - key: Component
      value: {{ . }}
    {{- end }}
    {{- range $glyphDefinition.tags }}
    - key: {{ .key }}
      value: {{ .value }}
    {{- end }}
{{- end }}