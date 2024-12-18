cat << EOF > values-custom.yaml
deepflowServerNodeIPS:
- 10.50.1.111 
#deepflowK8sClusterID: "fffffff"  # FIXME: K8s ClusterID
image:
  repository: hub.deepflow.yunshan.net/public/deepflow-agent
  pullPolicy: Always
  tag: v6.5
EOF

helm repo add deepflow https://deepflowio.github.io/deepflow
helm repo update deepflow # use `helm repo update` when helm < 3.7.0
helm install deepflow-agent -n deepflow deepflow/deepflow-agent --create-namespace -f values-custom.yaml
#!/bin/bash

set -e

helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns deepflow || true

helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
  --namespace deepflow --create-namespace

cat > grafana-agent-config.yaml << EOF
global:
  image:
    registry: "images.onwalk.net/public"
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
  prometheus:
    instance: default
    remoteWrite:
      - url: http://deepflow-agent.deepflow/api/v1/prometheus 
    scrapeConfigs:
      - job_name: 'kube-state-metrics'
        static_configs:
          - targets:
              - http://10.43.155.169:8080/metrics
              - http://kube-state-metrics.deepflow.svc.cluster.local:8080
        relabel_configs:
          - action: keep
            source_labels: [__meta_kubernetes_service_name]
            regex: kube-state-metrics

logs:
  enabled: false
traces:
  enabled: false
EOF

helm upgrade --install grafana-agent grafana/grafana-agent \
  --namespace deepflow \
  -f grafana-agent-config.yaml

kubectl get pods -n deepflow

helm repo add vector https://helm.vector.dev
helm repo update
cat << EOF > vector-values-custom.yaml
role: Agent
#nodeSelector:
#  allow/vector: "false"

# resources -- Set Vector resource requests and limits.
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 200m
    memory: 256Mi
image:
  repository: images.onwalk.net/public/timberio/vector
  pullPolicy: Always
  tag: "0.37.1-distroless-libc"
podLabels:
  vector.dev/exclude: "true"
  app: deepflow
# extraVolumes -- Additional Volumes to use with Vector Pods.
  # extraVolumes:
  # - name: opt-log
  #   hostPath:
  #     path: "/opt/log/"
# extraVolumeMounts -- Additional Volume to mount into Vector Containers.
  # extraVolumeMounts:
  # - name: opt-log
  #   mountPath: "/opt/log/"
  #   readOnly: true
customConfig:
  ## The configuration comes from https://vector.dev/docs/reference/configuration/global-options/#data_dir
  data_dir: /vector-data-dir
  api:
    enabled: true
    address: 127.0.0.1:8686
    playground: false
  sources:
    kubernetes_logs:
      type: kubernetes_logs
      namespace_annotation_fields:
        namespace_labels: ""
      node_annotation_fields:
        node_labels: ""
      pod_annotation_fields:
        pod_annotations: ""
        pod_labels: ""

  transforms:
    remap_kubernetes_logs:
      type: remap
      inputs:
      - kubernetes_logs
      source: |-
        # try to parse json
        if is_string(.message) && is_json(string!(.message)) {
            tags = parse_json(.message) ?? {}
            .message = tags.message # FIXME: the log content key inside json
            del(tags.message)
            .json = tags
        }

        if !exists(.level) {
           if exists(.json) {
            .level = .json.level
            del(.json.level)
           } else {
            # match log levels surround by ``[]`` or ``<>`` with ignore case
            level_tags = parse_regex(.message, r'[\[\\\<](?<level>(?i)INFOR?(MATION)?|WARN(ING)?|DEBUG?|ERROR?|TRACE|FATAL|CRIT(ICAL)?)[\]\\\>]') ?? {}
            if !exists(level_tags.level) {
              # match log levels surround by whitespace, required uppercase strictly in case mismatching
              level_tags = parse_regex(.message, r'[\s](?<level>INFOR?(MATION)?|WARN(ING)?|DEBUG?|ERROR?|TRACE|FATAL|CRIT(ICAL)?)[\s]') ?? {}
            }
            if exists(level_tags.level) {
              level_tags.level = upcase(string!(level_tags.level))
              .level = level_tags.level
            }
          }
        }

        if !exists(._df_log_type) {
            # default log type
            ._df_log_type = "user"
        }

        if !exists(.app_service) {
            # FIXME: files 模块没有此字段，请通过日志内容注入应用名称
            .app_service = .kubernetes.container_name
        }
  sinks:
    http:
      encoding:
        codec: json
      inputs:
      - remap_kubernetes_logs # NOTE: 注意这里数据源是 transform 模块的 key
      type: http
      uri: http://deepflow-agent.deepflow/api/v1/log
EOF
helm upgrade --install vector vector/vector --namespace deepflow --create-namespace -f vector-values-custom.yaml