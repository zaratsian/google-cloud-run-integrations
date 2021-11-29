FROM python:3.9-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED=True

ARG GCP_PROJECT_ID
ENV GCP_PROJECT_ID=$GCP_PROJECT_ID

ARG GCP_REGION
ENV GCP_REGION=$GCP_REGION

ARG CLOUDSQL_INSTANCE_NAME
ENV CLOUDSQL_INSTANCE_NAME=$CLOUDSQL_INSTANCE_NAME

ARG CLOUDSQL_DB_NAME
ENV CLOUDSQL_DB_NAME=$CLOUDSQL_DB_NAME

ARG CLOUDSQL_USERNAME
ENV CLOUDSQL_USERNAME=$CLOUDSQL_USERNAME

ARG CLOUDSQL_USERPASS
ENV CLOUDSQL_USERPASS=$CLOUDSQL_USERPASS

WORKDIR /app

COPY main.py requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

# Download CloudSQL Proxy
RUN apt-get update && apt-get install -y wget && wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy
# Start the Proxy
RUN echo "CloudSQL Instance Name: $GCP_PROJECT_ID:$GCP_REGION:$CLOUDSQL_INSTANCE_NAME"
RUN nohup ./cloud_sql_proxy -instances=$GCP_PROJECT_ID:$GCP_REGION:$CLOUDSQL_INSTANCE_NAME=tcp:3306 &

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 main:app