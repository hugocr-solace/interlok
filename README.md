# solace-interlok
Interlok solace template

## Overview
This project has a template to build interlok Docker Image and a Helm template to create a deploy on kubernetes

**Note:** The resources set in the deploy are not neccesay the ones that should be set, this is discresional

## Table of Contents
- [solace-interlok](#solace-interlok)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
      - [Optional for deploying local on Kubernetes](#optional-for-deploying-local-on-kubernetes)
  - [Interlok Compilation](#interlok-compilation)
  - [Interlok Docker Build](#interlok-docker-build)
    - [Without Data Dog Profiling](#without-data-dog-profiling)
    - [With DataDog Profiling](#with-datadog-profiling)
      - [Dockerfile](#dockerfile)
      - [bootstrap.properties](#bootstrapproperties)
        - [DataDog Configuration](#datadog-configuration)
        - [DataDog Tags](#datadog-tags)
        - [DataDog Health Check period](#datadog-health-check-period)
      - [build.gradle](#buildgradle)
      - [Build Docker Image](#build-docker-image)
  - [Execute Docker Container](#execute-docker-container)
    - [Emit DataDog Metrics locally](#emit-datadog-metrics-locally)
    - [Execute Docker Image](#execute-docker-image)
  - [Accesing Interlok Admin Page](#accesing-interlok-admin-page)
  - [Helm Install (Minikube)](#helm-install-minikube)
    - [Helm DataDog configuration](#helm-datadog-configuration)
    - [Install Helm DataDog Operator](#install-helm-datadog-operator)
  - [Install interlok Helm](#install-interlok-helm)
  - [Metrics](#metrics)

## Requirements
- Java 11
- Docker
#### Optional for deploying local on Kubernetes
- Kubectl
- MiniKube installed and running
- Helm

## Interlok Compilation
Go inside fhe folder `interlock-docker` and run the command
```
./gradlew clean build
```

## Interlok Docker Build
### Without Data Dog Profiling
In Docker file use this line as the one for the entrypoint
```
ENTRYPOINT ["/docker-entrypoint.sh"]
```

### With DataDog Profiling
#### Dockerfile
Validate this line is inside Dockerfile
```
ENTRYPOINT ["/docker-entrypoint-v2.sh"]
```
#### bootstrap.properties

##### DataDog Configuration
Add this lines in the file
```
datadogApiKey=<datadog api key>
datadogPushTimerSeconds=10
managementComponents=jmx:jetty:metrics-interlok:metrics-jvm:metrics-provider-datadog
```

##### DataDog Tags
These properties are needed and need to be unique becase will be the ones we user to recognize the service where where is running
```
env --> encirontment where the application is being executed suggestions LOCAL, DEV, QA or UAT, PROD
serviceId --> service id has to be unique and descriptive to easily recogonize the metrics

Example:
env=DEV
serviceId=Solace-ActiveMQ-service
```

##### DataDog Health Check period
Configuration for the period of time to checl all the componenets are healthy, the value has to be set in numbers
```
healthCheckWorkflow

Example:
healthCheckWorkflow=60
```


#### build.gradle
```
interlokRuntime ("com.adaptris:interlok-profiler:$interlokVersion")
interlokRuntime ("com.adaptris:interlok-rest-metrics-profiler:$interlokVersion")
interlokRuntime ("com.adaptris:interlok-rest-metrics-jvm:$interlokVersion")
interlokRuntime ("com.adaptris:interlok-rest-provider-datadog:$interlokVersion")

interlokJavadocs group: "com.adaptris", name: "interlok-profiler", version: "$interlokVersion", classifier: "javadoc", changing: true, transitive: false
interlokJavadocs group: "com.adaptris", name: "interlok-rest-metrics-profiler", version: "$interlokVersion", classifier: "javadoc", changing: true, transitive: false
interlokJavadocs group: "com.adaptris", name: "interlok-rest-metrics-jvm", version: "$interlokVersion", classifier: "javadoc", changing: true, transitive: false
interlokJavadocs group: "com.adaptris", name: "interlok-rest-provider-datadog", version: "$interlokVersion", classifier: "javadoc", changing: true, transitive: false
```

#### Build Docker Image
```
docker build --tag interlok 
```

## Execute Docker Container
### Emit DataDog Metrics locally
If you want to emit DataDog metrics from you docker image
```
docker run -d --cgroupns host --pid host --name dd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro -v \
/sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e DD_API_KEY=<APIKEY_VALUE> gcr.io/datadoghq/agent:7
```

### Execute Docker Image
```
docker run --name interlok --network host -it --rm -p 8080:8080 interlok
```

## Accesing Interlok Admin Page
```
http://localhost:8080/interlok
user: admin
password: admin
```

## Helm Install (Minikube)

### Helm DataDog configuration
Inside the file `datadog.yaml` need to configure this tags, this have to the same than the ones configured in the `bootstrap.properties` 
```
  tags:
    - "env:<value>"
    - "service_id:<value>"
```

### Install Helm DataDog Operator
```
helm install datadog -f ~/interlok-main/interlok-docker/datadog.yaml \
--set datadog.apiKey=<DD_APIKEY> datadog/datadog-operator
```
Notes: is important to use the correct path for the `datadog.yaml` file 

## Install interlok Helm
Make sure you are in the root level of this repo and execute the command
```
helm install interlok-deploy interlok-deployment --values interlok-deployment/values.yaml
```

## Metrics
The metrics we emit are:

- **interlok.check.component**: allow us to know which component is running and which is down
  - containing tags:
    - **component**:  name of the component
    - **service_id**: there service that is emiting this metric
    - **vendor**: name of the vendor
    - **env**: the environment that is emiting this metric
- **jvm.memory.used**: shows memory that is being used
- **process.cpu.usage**: cpu is being used
- **jvm.threads.states**: theards used by the jvm and their states