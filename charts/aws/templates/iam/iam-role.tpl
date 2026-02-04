{{/*kast - Kubernetes arcane spelling technology
Copyright (C) 2023 namenmalkv@gmail.com
Licensed under the GNU GPL v3. See LICENSE file for details.
*/}}
{{- define "aws.iam-role" }}
{{- $root := index . 0 -}}
{{- $glyphDefinition := index . 1}}
{{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name ) | fromJson) "results" }}
{{- range $k8sCluster := $k8sClusters }}
---
apiVersion: iam.services.k8s.aws/v1alpha1
kind: Role
metadata:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  {{- with $glyphDefinition.namespace }}
  namespace: {{ . }}
  {{- end }}
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
  {{- with $glyphDefinition.permissionsBoundary }}
  permissionsBoundary: {{ . }}
  {{- end }}
  assumeRolePolicyDocument: |
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "{{ $glyphDefinition.service }}"
          },
          "Action": "{{ $glyphDefinition.action }}"
        }
      ]
    }
  policies: # usear runic indexer para traer las policies por selector
  {{- range $policy := $glyphDefinition.policies }}
  {{- $policies := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $policy.selector ) "aws-iam-policy" $root.Values.chapter.name ) | fromJson) "results" }}
    {{- range $policyResult := $policies }}
    - {{ $policyResult.arn }}
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
{{- end }}
