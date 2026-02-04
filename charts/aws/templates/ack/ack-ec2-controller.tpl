# {{/*kast - Kubernetes arcane spelling technology
# Copyright (C) 2026 kazapeke@gmail.com
# Licensed under the GNU GPL v3. See LICENSE file for details.
# */}}
# {{- define "aws.ack-ec2-controller" }}
# {{- $root := index . 0 -}}
# {{- $glyphDefinition := index . 1 }}
# {{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name) | fromJson) "results" }}
# {{- range $k8sCluster := $k8sClusters }}
# {{- $controllerName := default "ack-ec2-controller" $glyphDefinition.controllerName }}
# {{- $namespace := default "ack-system" $glyphDefinition.namespace }}
# {{- $serviceAccountName := default "ack-ec2-controller" $glyphDefinition.serviceAccountName }}
# {{- $path := default "/ack/" $glyphDefinition.path }}
# {{- $region := default $k8sCluster.region $glyphDefinition.region }}
# {{- $accountID := default $k8sCluster.accountID $glyphDefinition.accountID }}
# {{- $oidcID := default $k8sCluster.oidcID $glyphDefinition.oidcID }}
# ---
# apiVersion: iam.services.k8s.aws/v1alpha1
# kind: Role
# metadata:
#   name: {{ $glyphDefinition.name }}
#   namespace: {{ $namespace }}
#   labels:
#     {{- include "common.all.labels" $root | nindent 4 }}
#     app.kubernetes.io/component: ack-ec2-controller
#     {{- with $glyphDefinition.labels }}
#     {{- toYaml . | nindent 4 }}
#     {{- end }}
# spec:
#   name: {{ $glyphDefinition.name }}
#   path: {{ $path }}
#   description: {{ default (printf "IAM Role for %s" $controllerName) $glyphDefinition.roleDescription | quote }}
#   {{- with $glyphDefinition.permissionsBoundary }}
#   permissionsBoundary: {{ . }}
#   {{- end }}
#   assumeRolePolicyDocument: |
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Principal": {
#             "Federated": "arn:aws:iam::{{ $accountID }}:oidc-provider/oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}"
#           },
#           "Action": "sts:AssumeRoleWithWebIdentity",
#           "Condition": {
#             "StringEquals": {
#               "oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}:sub": "system:serviceaccount:{{ $namespace }}:{{ $serviceAccountName }}",
#               "oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}:aud": "sts.amazonaws.com"
#             }
#           }
#         }
#       ]
#     }
#   policies:
#     - arn:aws:iam::{{ $accountID }}:policy{{ $path }}{{ $glyphDefinition.name }}-iam-policy
#   {{- if $glyphDefinition.tags }}
#   tags:
#     {{- range $glyphDefinition.tags }}
#     - key: {{ .key }}
#       value: {{ .value }}
#     {{- end }}
#   {{- else }}
#   tags:
#     - key: Name
#       value: {{ $glyphDefinition.name }}
#     - key: ManagedBy
#       value: ack-iam-controller
#     - key: Component
#       value: ack-ec2-controller
#   {{- end }}
# ---
# apiVersion: iam.services.k8s.aws/v1alpha1
# kind: Policy
# metadata:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   namespace: {{ $namespace }}
#   labels:
#     {{- include "common.all.labels" $root | nindent 4 }}
#     app.kubernetes.io/component: ack-ec2-controller
#     {{- with $glyphDefinition.labels }}
#     {{- toYaml . | nindent 4 }}
#     {{- end }}
# spec:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   path: {{ $path }}
#   description: {{ default (printf "IAM Policy for %s to manage EC2 resources" $controllerName) $glyphDefinition.policyDescription | quote }}
#   policyDocument: |
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Action": [
#             "ec2:DescribeVpcs",
#             "ec2:DescribeVpcAttribute",
#             "ec2:DescribeVpcClassicLink",
#             "ec2:DescribeVpcClassicLinkDnsSupport",
#             "ec2:CreateSubnet",
#             "ec2:DeleteSubnet",
#             "ec2:DescribeSubnets",
#             "ec2:ModifySubnetAttribute",
#             "ec2:CreateSecurityGroup",
#             "ec2:DeleteSecurityGroup",
#             "ec2:DescribeSecurityGroups",
#             "ec2:DescribeSecurityGroupRules",
#             "ec2:AuthorizeSecurityGroupIngress",
#             "ec2:AuthorizeSecurityGroupEgress",
#             "ec2:RevokeSecurityGroupIngress",
#             "ec2:RevokeSecurityGroupEgress",
#             "ec2:ModifySecurityGroupRules",
#             "ec2:CreateRouteTable",
#             "ec2:DeleteRouteTable",
#             "ec2:DescribeRouteTables",
#             "ec2:AssociateRouteTable",
#             "ec2:DisassociateRouteTable",
#             "ec2:CreateRoute",
#             "ec2:DeleteRoute",
#             "ec2:ReplaceRoute",
#             "ec2:CreateInternetGateway",
#             "ec2:DeleteInternetGateway",
#             "ec2:DescribeInternetGateways",
#             "ec2:AttachInternetGateway",
#             "ec2:DetachInternetGateway",
#             "ec2:CreateNatGateway",
#             "ec2:DeleteNatGateway",
#             "ec2:DescribeNatGateways",
#             "ec2:AllocateAddress",
#             "ec2:ReleaseAddress",
#             "ec2:DescribeAddresses",
#             "ec2:AssociateAddress",
#             "ec2:DisassociateAddress",
#             "ec2:CreateTags",
#             "ec2:DeleteTags",
#             "ec2:DescribeTags"
#           ],
#           "Resource": "*"
#         }
#       ]
#     }
#   {{- if $glyphDefinition.tags }}
#   tags:
#     {{- range $glyphDefinition.tags }}
#     - key: {{ .key }}
#       value: {{ .value }}
#     {{- end }}
#   {{- else }}
#   tags:
#     - key: Name
#       value: {{ $glyphDefinition.name }}-iam-policy
#     - key: ManagedBy
#       value: ack-iam-controller
#     - key: Component
#       value: ack-ec2-controller
#   {{- end }}
# {{- end }}
# {{- end }}