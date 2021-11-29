# GCP Project Details
export TF_VAR_GCP_PROJECT_ID=fit-entity-333016
export TF_VAR_GCP_PROJECT_NUMBER=485413351481
export TF_VAR_GCP_REGION=us-central1
# Artifact Repo
export TF_VAR_ARTIFACT_REPO_NAME="app-repo"
# Cloud Run
export TF_VAR_APP_CLOUD_RUN_NAME=${TF_VAR_GCP_PROJECT_ID}-app
export TF_VAR_APP_CLOUD_RUN_REGION=${TF_VAR_GCP_REGION}
# CloudSQL
export TF_VAR_CLOUDSQL_INSTANCE_NAME="cloudsql-mysql1"
export TF_VAR_CLOUDSQL_REGION=${TF_VAR_GCP_REGION}
export TF_VAR_CLOUDSQL_DB_VERSION=MYSQL_5_7
export TF_VAR_CLOUDSQL_TIER=db-f1-micro
export TF_VAR_CLOUDSQL_DB_NAME=mydb
export TF_VAR_CLOUDSQL_USERNAME=admin
export TF_VAR_CLOUDSQL_USERPASS=password123
export TF_VAR_CLOUDSQL_HOST="%"
export TF_VAR_CLOUDSQL_DISK_AUTORESIZE=true
export TF_VAR_CLOUDSQL_DISK_SIZE=10
# Memorystore Redis
export TF_VAR_REDIS_INSTANCE_NAME="redis-instance"
export TF_VAR_REDIS_VERSION=redis_6_x
# Networking
export TF_VAR_VPC_NETWORK_NAME="zvpcnetwork"
export TF_VAR_DYNAMIC_ROUTING_MODE=global

# Enable GCP APIs
gcloud services enable \
    compute.googleapis.com \
    sqladmin.googleapis.com \
    run.googleapis.com \
    containerregistry.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    servicenetworking.googleapis.com

# Create Artifact Repo
gcloud artifacts repositories create ${TF_VAR_ARTIFACT_REPO_NAME} \
    --repository-format=docker \
    --location=${TF_VAR_GCP_REGION} \
    --description="App repository"

# Provision CloudSQL (MySQL) Instance
gcloud sql instances create ${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
    --database-version=${TF_VAR_CLOUDSQL_DB_VERSION} \
    --cpu=1 \
    --memory=4GB \
    --region=${TF_VAR_CLOUDSQL_REGION} \
    --root-password=${TF_VAR_CLOUDSQL_USERPASS}

# Create CloudSQL Database
gcloud sql databases create ${TF_VAR_CLOUDSQL_DB_NAME} --instance=${TF_VAR_CLOUDSQL_INSTANCE_NAME}

# Create a User
gcloud sql users create ${TF_VAR_CLOUDSQL_USERNAME} \
    --instance=${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
    --password=${TF_VAR_CLOUDSQL_USERPASS}

# Build Cloud Run App
./app/build.sh

# Deploy Cloud Run App

# Test Endpoint
#export CLOUD_RUN_ENDPOINT=$(gcloud run services list --format "value(status.url)")
#curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $CLOUD_RUN_ENDPOINT

# Get Compute Service Account Email
#export COMPUTE_SA=$(gcloud iam service-accounts list --format "value(email)" | grep ${TF_VAR_GCP_PROJECT_NUMBER}-compute)

# Add IAM Policy
#gcloud projects add-iam-policy-binding ${TF_VAR_GCP_PROJECT_ID} \
#    --member="serviceAccount:${COMPUTE_SA}" \
#    --role="roles/cloudsql.client"

#gcloud run services add-iam-policy-binding ${TF_VAR_APP_CLOUD_RUN_NAME} \
#    --member="${COMPUTE_SA}" \
#    --role="roles/run.invoker"

# Create VPC Network
gcloud compute networks create ${TF_VAR_VPC_NETWORK_NAME} \
    --subnet-mode=auto \
    --bgp-routing-mode=${TF_VAR_DYNAMIC_ROUTING_MODE} \
    --mtu=1460

# IAM Binding for Redis
gcloud projects add-iam-policy-binding ${TF_VAR_GCP_PROJECT_ID} \
    --member="serviceAccount:service-${TF_VAR_GCP_PROJECT_NUMBER}@cloud-redis.iam.gserviceaccount.com" \
    --role="roles/redis.serviceAgent"

# Create Cloud Memorystore Redis Instance
gcloud redis instances create ${TF_VAR_REDIS_INSTANCE_NAME} \
    --size=2 \
    --region=${TF_VAR_GCP_REGION} \
    --redis-version=${TF_VAR_REDIS_VERSION} \
    --network ${TF_VAR_VPC_NETWORK_NAME} \
    --tier basic

