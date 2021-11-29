SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker build -t zsql \
    --build-arg GCP_PROJECT_ID=${TF_VAR_GCP_PROJECT_ID} \
    --build-arg GCP_REGION=${TF_VAR_GCP_REGION} \
    --build-arg CLOUDSQL_INSTANCE_NAME=${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
    --build-arg CLOUDSQL_DB_NAME=${TF_VAR_CLOUDSQL_DB_NAME} \
    --build-arg CLOUDSQL_USERNAME=${TF_VAR_CLOUDSQL_USERNAME} \
    --build-arg CLOUDSQL_USERPASS=${TF_VAR_CLOUDSQL_USERPASS} \
    $SCRIPT_DIR
