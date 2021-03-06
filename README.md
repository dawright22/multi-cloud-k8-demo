
#Please visit https://github.com/dawright22/connected-clouds for a more up-to-date version 

# Multi-cloud-k8-demo
A terraform module to create a basic MariaDB SQL service and the Transit APP that is configured to use Dynamic Secrets and Transit Encryption using Vault. To conect these service Consul is configuread as a service registory.

## Usage
If you clone the repo and run an apply without changing anything a random pet name will be created with the TFE prefix and used in each cluster

```hcl
terraform {
  required_version = ">= 0.12"
}

resource "random_pet" "name" {
  prefix = "TFE"
  length = 1
}

#AWS
module "Cluster_EKS" {
  source       = "./Cluster_EKS"
  cluster-name = "${random_pet.name.id}"

}
#MSFT
module "Cluster_AKS" {
  source       = "./Cluster_AKS"
  cluster-name = "${random_pet.name.id}"

}
#Google
module "Cluster_GKE" {
  source       = "./Cluster_GKE"
  cluster_name = "${random_pet.name.id}"
}
```
## Pre-requirements 
Before you run this you will need to:

1.You will need to auth to GCP,Azure and AWS

2.Install helm V2 **if you use helm version 3 the tiller install will fail**

3.Install aswcli v2 https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html 

4.Install GKE SDK https://cloud.google.com/sdk/docs/downloads-interactive 

5.Insall Azure Cli https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest 

6.Clone this repo

7.Run terraform apply


## Inputs
### AKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "appId" 
  default = "41111111111111111111111"

variable "password" 
  default = "c3444444444444444444444444444444"

variable "location" 
  default = "Australia East"
```
### EKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "aws_region" 
```
### GKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "gcp_region" 

  description = "GCP region, e.g. us-east1"
  
  default     = "australia-southeast1"

variable "gcp_zone" 

  description = "GCP zone, e.g. us-east1-b (which must be in gcp_region)"
  
  default     = "australia-southeast1-c"

variable "gcp_project" 

  description = "GCP project name"
  
  default     = "your-project-name"
```

### Main.tf
Here you can name the clusters by altering the following:

```hcl
cluster_name = "your-name"
```

## Outputs
The Terraform will locally install the user creds into your kubectl config file so that you can switch between the clusters use the kubectl config get-contexts command to see cluster names


### App deployment

Use the kubectl config user-context <name> to set the enviroment you wish to deploy too.
CD into the main app_stack directory in there you will see app_<cloud> stacks which are cloud specifc namaged K8 clusters. CD into the enviroment you wish to deploy too and run
  

./full_stack_deploy.sh


NOTE: You may need to change permission on the above script and ./clean.sh before you run the scripts. These script reference other scripts at the below directorys within the app_XXX stack. You should check all the scripts have the correct permision to run. 

tiller

./helm-init.sh

in consul

./consul.sh

in mariadb

./mariadb.sh

in vault

./vault.sh

run kubectl get svc to see the EXTERNAL-IP to connect to for the service.


### What you get!
### Consul

You can connect to the consul UI and see the services registerd using http://<EXTERNAL-IP>

it should look like this:

![](/images/consul.png)

### Vault
You can connect to the Vault UI and see the secrets engines enabled using http://<EXTERNAL_IP:8200>

You will need to login in using the ROOT TOKEN from the init.txt file located in app_stack/app_<cloud>/vault/init.txt to authenticate

it should look like this:

![](/images/vault.png)

### Transit-app

You can connect to the Vault UI and see the secrets engines enabled using http://<EXTERNAL_IP:5000>

![](/images/tranist-app.png)


## Clean up

To delete your enviroments you need to run

./clean.sh in each of the K8 clusters

then run terraform destroy

To clean up you will want to remove the user profile from your kubeconfig

## NOTE:

### If you want to run this demo for a second time 

### please check to see if app_stack/app_cloud_name/vault/init.txt exists.

### If it does please remove it before running again.


inspired and leverage code from this article

https://medium.com/hashicorp-engineering/hashicorp-consul-multi-cloud-and-multi-platform-service-mesh-372a82264e8e
