#! /usr/bin/sh

# Create random string
guid=$(cat /proc/sys/kernel/random/uuid)
suffix=${guid//[-]/}
suffix=${suffix:0:18}

# Set the necessary variables
RESOURCE_GROUP="rg-azure-certif-test"
RESOURCE_PROVIDER="Microsoft.MachineLearningServices"
RESOURCE_GROUP_LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)
WORKSPACE_NAME="mlw-ai300-l${suffix}"
COMPUTE_INSTANCE="ci${suffix}"
COMPUTE_CLUSTER="aml-cluster"

# Register the Azure Machine Learning resource provider in the subscription
echo "Register the Machine Learning resource provider:"
az provider register --namespace $RESOURCE_PROVIDER

# Use the existing resource group and set it as default
echo "Using existing resource group and setting as default:"
az configure --defaults group=$RESOURCE_GROUP

echo "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME --location $RESOURCE_GROUP_LOCATION
az configure --defaults workspace=$WORKSPACE_NAME

# Create compute instance
echo "Creating a compute instance with name: " $COMPUTE_INSTANCE
az ml compute create --name ${COMPUTE_INSTANCE} --size STANDARD_DS11_V2 --type ComputeInstance

# Create compute cluster
echo "Creating a compute cluster with name: " $COMPUTE_CLUSTER
az ml compute create --name ${COMPUTE_CLUSTER} --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute

# Create data assets
echo "Create training data asset:"
az ml data create --type mltable --name "diabetes-training" --path ../data/diabetes-data
az ml data create --type uri_file --name "diabetes-data" --path ../data/diabetes-data/diabetes.csv
