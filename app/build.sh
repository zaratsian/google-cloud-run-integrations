SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Auth
gcloud auth configure-docker ${TF_VAR_GCP_REGION}-docker.pkg.dev --quiet

# Container Tag
CONTAINER_TAG=${TF_VAR_GCP_REGION}-docker.pkg.dev/${TF_VAR_GCP_PROJECT_ID}/${TF_VAR_ARTIFACT_REPO_NAME}/${TF_VAR_APP_CLOUD_RUN_NAME}:latest

# Build Container
docker build --tag ${CONTAINER_TAG} \
    --build-arg GCP_PROJECT_ID=${TF_VAR_GCP_PROJECT_ID} \
    --build-arg GCP_REGION=${TF_VAR_GCP_REGION} \
    --build-arg CLOUDSQL_INSTANCE_NAME=${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
    --build-arg CLOUDSQL_DB_NAME=${TF_VAR_CLOUDSQL_DB_NAME} \
    --build-arg CLOUDSQL_USERNAME=${TF_VAR_CLOUDSQL_USERNAME} \
    --build-arg CLOUDSQL_USERPASS=${TF_VAR_CLOUDSQL_USERPASS} \
    $SCRIPT_DIR

# Push Container to Artifact Repo
docker push ${CONTAINER_TAG}