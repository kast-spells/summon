{{/*kast - Kubernetes arcane spelling technology
Copyright (C) 2026  kazapeke@gmail.com
Licensed under the GNU GPL v3. See LICENSE file for details.
*/}}
{{- define "aws.db-instance" }}
{{- $root := index . 0 -}}
{{- $glyphDefinition := index . 1 }}
---
apiVersion: rds.services.k8s.aws/v1alpha1
kind: DBInstance
metadata:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  namespace: {{ default $root.Release.Namespace $glyphDefinition.namespace }}
  labels:
    {{- include "common.all.labels" $root | nindent 4 }}
    {{- with $glyphDefinition.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if or $glyphDefinition.annotations $glyphDefinition.adoptionPolicy }}
  annotations:
    {{- if $glyphDefinition.adoptionPolicy }}
    services.k8s.aws/adoption-policy: {{ $glyphDefinition.adoptionPolicy }}
    {{- end }}
    {{- with $glyphDefinition.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  dbInstanceIdentifier: {{ default (include "common.name" $root) $glyphDefinition.name }}
  dbInstanceClass: {{ default "db.t3.micro" $glyphDefinition.instanceClass }}
  engine: {{ default "postgres" $glyphDefinition.engine }}
  {{- with $glyphDefinition.engineVersion }}
  engineVersion: {{ . | quote }}
  {{- end }}

  # Storage configuration
  allocatedStorage: {{ default 20 $glyphDefinition.allocatedStorage }}
  {{- with $glyphDefinition.maxAllocatedStorage }}
  maxAllocatedStorage: {{ . }}
  {{- end }}
  storageType: {{ default "gp3" $glyphDefinition.storageType }}
  {{- with $glyphDefinition.iops }}
  iops: {{ . }}
  {{- end }}
  {{- with $glyphDefinition.storageThroughput }}
  storageThroughput: {{ . }}
  {{- end }}
  storageEncrypted: {{ default false $glyphDefinition.storageEncrypted }}
  {{- with $glyphDefinition.kmsKeyID }}
  kmsKeyID: {{ . }}
  {{- end }}

  # Master credentials
  {{- with $glyphDefinition.masterUsername }}
  masterUsername: {{ . }}
  {{- end }}
  {{- with $glyphDefinition.masterUserPassword }}
  masterUserPassword:
    {{- with .namespace }}
    namespace: {{ . }}
    {{- end }}
    name: {{ .name }}
    key: {{ default "password" .key }}
  {{- end }}

  # Database name
  {{- with $glyphDefinition.dbName }}
  dbName: {{ . }}
  {{- end }}

  # Networking - Subnet Group
  {{- if $glyphDefinition.dbSubnetGroupName }}
  dbSubnetGroupName: {{ $glyphDefinition.dbSubnetGroupName }}
  {{- else if $glyphDefinition.subnetGroup }}
    {{- if $glyphDefinition.subnetGroup.name }}
  dbSubnetGroupName: {{ $glyphDefinition.subnetGroup.name }}
    {{- else if $glyphDefinition.subnetGroup.selector }}
      {{- $results := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.subnetGroup.selector) "aws-db-subnet-group" $root.Values.chapter.name) | fromJson) "results" }}
      {{- range $result := $results }}
  dbSubnetGroupName: {{ $result.name }}
      {{- end }}
    {{- end }}
  {{- end }}

  # Parameter Group
  {{- if $glyphDefinition.dbParameterGroupName }}
  dbParameterGroupName: {{ $glyphDefinition.dbParameterGroupName }}
  {{- else if $glyphDefinition.parameterGroup }}
    {{- if $glyphDefinition.parameterGroup.name }}
  dbParameterGroupName: {{ $glyphDefinition.parameterGroup.name }}
    {{- else if $glyphDefinition.parameterGroup.selector }}
      {{- $results := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.parameterGroup.selector) "aws-db-parameter-group" $root.Values.chapter.name) | fromJson) "results" }}
      {{- range $result := $results }}
  dbParameterGroupName: {{ $result.name }}
      {{- end }}
    {{- end }}
  {{- end }}

  # Security Groups
  {{- if $glyphDefinition.vpcSecurityGroupIDs }}
  vpcSecurityGroupIDs:
    {{- range $glyphDefinition.vpcSecurityGroupIDs }}
    - {{ . }}
    {{- end }}
  {{- else if $glyphDefinition.securityGroups }}
  vpcSecurityGroupIDs:
    {{- range $sg := $glyphDefinition.securityGroups }}
      {{- if $sg.id }}
    - {{ $sg.id }}
      {{- else if $sg.selector }}
        {{- $results := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $sg.selector) "aws-security-group" $root.Values.chapter.name) | fromJson) "results" }}
        {{- range $result := $results }}
    - {{ $result.id }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  publiclyAccessible: {{ default false $glyphDefinition.publiclyAccessible }}
  port: {{ default 5432 $glyphDefinition.port }}

  # High availability
  multiAZ: {{ default false $glyphDefinition.multiAZ }}
  {{- with $glyphDefinition.availabilityZone }}
  availabilityZone: {{ . }}
  {{- end }}

  # Backup configuration
  {{- with $glyphDefinition.backupRetentionPeriod }}
  backupRetentionPeriod: {{ . }}
  {{- end }}
  {{- with $glyphDefinition.preferredBackupWindow }}
  preferredBackupWindow: {{ . | quote }}
  {{- end }}
  {{- with $glyphDefinition.preferredMaintenanceWindow }}
  preferredMaintenanceWindow: {{ . | quote }}
  {{- end }}
  copyTagsToSnapshot: {{ default false $glyphDefinition.copyTagsToSnapshot }}

  # Updates and maintenance
  autoMinorVersionUpgrade: {{ default false $glyphDefinition.autoMinorVersionUpgrade }}
  deletionProtection: {{ default false $glyphDefinition.deletionProtection }}

  # Performance Insights
  {{- if $glyphDefinition.enablePerformanceInsights }}
  enablePerformanceInsights: {{ $glyphDefinition.enablePerformanceInsights }}
  {{- with $glyphDefinition.performanceInsightsRetentionPeriod }}
  performanceInsightsRetentionPeriod: {{ . }}
  {{- end }}
  {{- end }}

  # Monitoring
  {{- with $glyphDefinition.monitoringInterval }}
  monitoringInterval: {{ . }}
  {{- end }}
  {{- with $glyphDefinition.monitoringRoleARN }}
  monitoringRoleARN: {{ . }}
  {{- end }}
  {{- with $glyphDefinition.enableCloudwatchLogsExports }}
  enableCloudwatchLogsExports:
    {{- range . }}
    - {{ . }}
    {{- end }}
  {{- end }}

  # Tags
  {{- with $glyphDefinition.tags }}
  tags:
    {{- range . }}
    - key: {{ .key }}
      value: {{ .value }}
    {{- end }}
  {{- end }}
{{- end }}
