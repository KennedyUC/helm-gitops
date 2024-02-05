# Deploying Simple FastAPI Application in Kubernetes using Helm and ArgoCD

Deploying an application to a Kubernetes cluster using GitOps, in addition to the automated deployment, can help to minimize the access points for interferring with the state of the application, as GitHub serves as the only source of truth for updating the application's state.  
  
In this task, ArgoCD (a GitOps tool) is used to deploy a simple python FastAPI application to a Kubernetes cluster using Helm Chart. The Helm Chart is used to package and manage the application state (defined in YAML manifest files).  
  
## STEPS
**Install the base CLI tools**:  
The commands for the task are organized within a `Makefile` to make the flow smoother and neater. To be able to run the `make` commands, you need to install `make` CLI (Command Line Interface).  

```BASH
sudo apt update
sudo apt install make -y
```  

To confirm that the installation is successful, run the command below.  
  
```BASH
make -version
```
  
The docker images for the deployment scripts are built and pushed to the container registry using `skaffold`. The next step involved installing `skaffold` CLI.  
  
```BASH
make install-skaffold
```  
  
To confirm that the installation is successful, run the command below.
  
```BASH
skaffold -version
```  
  
**Install ArgoCD**  
Command:  
```BASH
make install-argocd
```  
  
The command above installs the ArgoCD CRDs (Custom Resource Definitions) and operators required to be able to run the ArgoCD Applications in the cluster. The command also installs the `argocd` CLI tool for interacting with the ArgoCD applications.  
  
**Authenticate to the Docker Registry**  
Command:
```BASH
make docker-login DOCKER_USERNAME=<replace_with_registry_username> \
                  DOCKER_PASSWORD=<replace_with_registry_password>
```  
  
**Build the docker images with skaffold**  
Command:
```BASH
make skaffold-build DOCKER_USERNAME=<registery_username> \
                    VERSION=<image_version> \
                    ENV=<env>  
```  
  
**Update the Application Chart values**  
Command:
```BASH
make update-chart-values APP_NAMESPACE=<namespace> \
                         DOCKER_USERNAME=<registry_username> \
                         VERSION=<image_version> 
                         ENV=<env>
```  
  
**Setup the target GitHub Repo on the ArgoCD UI**  
Setup the ArgoCD password to be able to login to the UI.  
  
```BASH
make set-argocd-password
```
  
To access the ArgoCD UI, run the command below.  

```BASH
make open-argocd-ui
```  
  
Setup the Target GitHub Repo on the ArgoCD UI. [TODO => Add pictures of the UI]  
  
**Deploy the FastAPI Apllication**  
Command:
```BASH  
make deploy-app
```  
  
**Monitor the deployment**  
Open the ArgoCD UI to check the deployment status of the application.  You can also check the status using `kubectl` commands.