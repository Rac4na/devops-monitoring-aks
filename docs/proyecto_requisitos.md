# Proyecto Final — DevOps Monitoring

**Diplomado de DevOps** · Monitoreo con Kubernetes, Prometheus y Grafana

---

## 1. Objetivo

Documentar y publicar un entorno de monitoreo sobre **Azure Kubernetes Service (AKS)**, creado con Terraform, e instalar las herramientas de observabilidad del stack Prometheus + Grafana.

---

## 2. Entregable — Documento técnico

Elaborar un documento (Word o PDF) que cubra, de forma clara y ordenada. El documento debe incluir la **URL del repositorio público**.


| Sección                   | Contenido esperado                                                      |
| ------------------------- | ----------------------------------------------------------------------- |
| **Repositorio**           | URL del repositorio público con el código Terraform                     |
| **Infraestructura**       | Aprovisionar un clúster de Kubernetes con Terraform                     |
| **Herramientas**          | Instalación de las herramientas (Prometheus, Grafana, Loki) con Helm    |
| **Teoría**                | Explicar diferencias entre el uso de herramientas Open Source y de Paga |
| **Teoría**                | Explicar los beneficios de DevOps Monitoring                            |
| **Práctica** *(opcional)* | Desplegar un microservicio y validar logs y métricas en Grafana         |




### Configuración requerida

Debe quedar configurado:

- **Nombre de los componentes** según nomenclatura y estándar de Azure.



### Sección opcional — Microservicio y validación en Grafana

Incluir en este **mismo documento** el despliegue de un microservicio y la evidencia de impacto en **logs** y **métricas**.


| Paso           | Qué demostrar                                                            |
| -------------- | ------------------------------------------------------------------------ |
| **Despliegue** | Levantar el MS en AKS (Deployment + Service)                             |
| **Logs**       | Ver los logs del MS en Loki / Grafana (Explore o dashboard de logs)      |
| **Métricas**   | En Grafana, comparar CPU y memoria **antes y después** de levantar el MS |


**Evidencia esperada:** pod en `Running`, logs del MS visibles en Grafana y gráficos donde se vea el **aumento de CPU y memoria** al iniciar el MS (capturas de pantalla o dashboard exportado).

---



## 3. Checklist de entrega

- [ ] Documento técnico (incluye la **URL del repositorio** y el resto del cuadro)
- [ ] Sección opcional — Microservicio, logs y métricas en Grafana