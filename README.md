# Proyecto Final – DevOps Monitoring en AKS

Diplomado de DevOps · Módulo 5 · Monitoreo con Kubernetes, Prometheus, Grafana y Loki

Este repositorio contiene el código Terraform, los valores de Helm, los manifiestos de Kubernetes
y las evidencias del proyecto final: un clúster **Azure Kubernetes Service (AKS)** aprovisionado con
Terraform, con el stack de observabilidad **Prometheus + Grafana + Loki** instalado con Helm, y un
microservicio de prueba cuyo impacto se valida en logs y métricas dentro de Grafana.

> Repositorio: https://github.com/Rac4na/devops-monitoring-aks · Documento técnico (Word): `docs/Proyecto_Final_DevOps_Monitoring.docx`

## Estructura

| Ruta | Contenido |
| --- | --- |
| `provider.tf`, `aks.tf` | Terraform: resource group y clúster AKS |
| `helm/grafana-values.yaml` | Valores de Helm para Grafana (LoadBalancer, data sources y dashboards aprovisionados) |
| `dashboards/` | Dashboards de Grafana en JSON (nodos/pods y logs del microservicio) |
| `k8s/microservicio.yaml` | Microservicio `podinfo`: Namespace + Deployment + Service LoadBalancer |
| `k8s/load-generator.yaml` | Generador de tráfico para evidenciar el impacto en CPU, memoria y logs |
| `evidencias/` | Salidas de comandos, capturas de Grafana y gráficos antes/después |
| `comandos.md` | Guía paso a paso con todos los comandos ejecutados |
| `docs/` | Documento técnico (Word) y enunciado del proyecto |

## Nomenclatura Azure (Cloud Adoption Framework)

Formato `<tipo>-<carga>-<entorno>-<región>-<instancia>`:

| Recurso | Nombre |
| --- | --- |
| Resource Group | `rg-acuna-dev-eastus-01` |
| Clúster AKS | `aks-acuna-dev-eastus-01` |
| Node pool | `default` (1 × `Standard_D2als_v7`) |
| Namespaces | `monitoring` (stack de observabilidad), `dev` (microservicio) |

## Despliegue rápido

```bash
# 1) Infraestructura
cd <carpeta-del-repo>
terraform init && terraform apply
az aks get-credentials --resource-group rg-acuna-dev-eastus-01 --name aks-acuna-dev-eastus-01 --overwrite-existing

# 2) Herramientas con Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm upgrade --install prometheus prometheus-community/prometheus -n monitoring \
  --set alertmanager.enabled=false --set prometheus-pushgateway.enabled=false --set server.retention=3d
helm upgrade --install loki grafana/loki-stack -n monitoring \
  --set grafana.enabled=false --set promtail.enabled=true --set loki.image.tag=2.9.8
kubectl create configmap grafana-dashboards -n monitoring \
  --from-file=dashboards/aks-dashboard.json --from-file=dashboards/logs-dashboard.json
helm upgrade --install grafana grafana/grafana -n monitoring -f helm/grafana-values.yaml

# 3) Acceso a Grafana
kubectl get svc grafana -n monitoring            # EXTERNAL-IP
kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode

# 4) Microservicio y tráfico (sección práctica)
kubectl apply -f k8s/microservicio.yaml
kubectl apply -f k8s/load-generator.yaml
kubectl get pods,svc -n dev

# 5) Limpieza (evita costos)
kubectl delete -f k8s/load-generator.yaml -f k8s/microservicio.yaml
terraform destroy
```

Los detalles, la explicación de cada paso y las evidencias están en `comandos.md` y en el documento Word.
