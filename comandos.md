# Comandos ejecutados – Proyecto Final DevOps Monitoring

Clúster: `aks-acuna-dev-eastus-01` · Resource group: `rg-acuna-dev-eastus-01` · Región: East US

## 1. Infraestructura con Terraform

```bash
cd Clase_01_02
terraform init
terraform plan
terraform apply
terraform plan      # debe responder: "No changes. Your infrastructure matches the configuration."
```

## 2. Conectarse al clúster

```bash
az account set --subscription <ID_SUSCRIPCION>
az aks get-credentials --resource-group rg-acuna-dev-eastus-01 --name aks-acuna-dev-eastus-01 --overwrite-existing
kubectl get nodes -o wide
```

## 3. Namespace de monitoreo y repositorios de Helm

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## 4. Instalar Prometheus

Se desactivan Alertmanager y Pushgateway (no se usan en el proyecto) y se fija una retención corta
para no saturar el disco del nodo.

```bash
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring \
  --set alertmanager.enabled=false \
  --set prometheus-pushgateway.enabled=false \
  --set server.retention=3d
```

Prometheus queda accesible dentro del clúster en `http://prometheus-server.monitoring.svc.cluster.local:80`.

## 5. Instalar Loki (logs) con Promtail

```bash
helm upgrade --install loki grafana/loki-stack --namespace monitoring \
  --set grafana.enabled=false --set promtail.enabled=true --set loki.image.tag=2.9.8
```

Promtail corre como DaemonSet, lee los logs de todos los contenedores del nodo y los envía a
`http://loki.monitoring.svc.cluster.local:3100`.

## 6. Instalar Grafana con data sources y dashboards aprovisionados

Los data sources (Prometheus y Loki) y los dashboards se definen como código en
`helm/grafana-values.yaml` y `dashboards/*.json`, de modo que Grafana arranca ya configurado.

```bash
kubectl create configmap grafana-dashboards -n monitoring \
  --from-file=dashboards/aks-dashboard.json \
  --from-file=dashboards/logs-dashboard.json
helm upgrade --install grafana grafana/grafana --namespace monitoring -f helm/grafana-values.yaml
```

### Obtener IP pública y contraseña de Grafana

```bash
kubectl get svc grafana -n monitoring
kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

Usuario: `admin`. Data sources ya configurados:

| Nombre | Tipo | URL |
| --- | --- | --- |
| Prometheus | prometheus | `http://prometheus-server.monitoring.svc.cluster.local:80` |
| Loki | loki | `http://loki.monitoring.svc.cluster.local:3100` |

## 7. Verificación del stack

```bash
helm list -n monitoring
kubectl get pods,svc -n monitoring
kubectl top nodes
```

## 8. Sección práctica: microservicio, logs y métricas

### 8.1 Desplegar el microservicio (Deployment + Service)

El microservicio es `podinfo` (Go): expone una API REST en el puerto 9898, métricas Prometheus en
`/metrics` y escribe logs estructurados en stdout.

```bash
kubectl apply -f k8s/microservicio.yaml
kubectl rollout status deployment/podinfo -n dev
kubectl get deploy,pods,svc -n dev -o wide
```

### 8.2 Probar el microservicio

```bash
MS_IP=$(kubectl get svc podinfo -n dev -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$MS_IP/                 # 200 – JSON de bienvenida
curl -i http://$MS_IP/status/404    # 404 – ruta de prueba para logs
```

### 8.3 Generar tráfico continuo

```bash
kubectl apply -f k8s/load-generator.yaml
kubectl logs -n dev deploy/podinfo --tail=20
```

### 8.4 Ver logs en Grafana (Loki)

Grafana → Explore → data source **Loki**:

```logql
{namespace="dev", app="podinfo"}
{namespace="dev", app="podinfo"} |= "/status/404"
sum(count_over_time({namespace="dev", app="podinfo"}[1m]))
```

También está el dashboard **"Microservicio - Logs y Requests (Loki + Prometheus)"**.

### 8.5 Comparar CPU y memoria antes y después

Dashboard **"AKS - Monitoreo de Nodos y Pods"** (paneles *Uso de CPU (%) por nodo* y
*Uso de Memoria (%) por nodo*). Consultas PromQL usadas:

```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
sum(rate(container_cpu_usage_seconds_total{namespace="dev", container!=""}[2m]))
sum(container_memory_working_set_bytes{namespace="dev", container!=""})
```

## 9. Limpieza

```bash
kubectl delete -f k8s/load-generator.yaml -f k8s/microservicio.yaml
helm uninstall grafana loki prometheus -n monitoring
terraform destroy
```
