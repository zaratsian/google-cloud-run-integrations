
import datetime
import logging
import os
import ssl
import random

from flask import Flask, render_template, request, Response

from google.cloud.sql.connector import connector
import sqlalchemy
import pymysql
import redis

app = Flask(__name__)

logger = logging.getLogger()

'''
export INSTANCE_CONNECTION_NAME="zproject201807:us-central1:example-mysql-dcee"
export DB_NAME="default"
export DB_USER="default"
export DB_PASS="zpassword123"

export REDIS_HOST=10.102.40.131
export REDIS_PORT=6379

'''

# CloudSQL Params
instance_connection_name = os.environ['INSTANCE_CONNECTION_NAME']
database = os.environ['DB_NAME']
username = os.environ['DB_USER'] 
password = os.environ['DB_PASS']

# Memorystore/Redis Params
redis_host = os.environ.get('REDIS_HOST', 'localhost')
redis_port = int(os.environ.get('REDIS_PORT', 6379))
redis_client = redis.StrictRedis(host=redis_host, port=redis_port)

print(f'[ DEBUG ] INSTANCE_CONNECTION_NAME: {instance_connection_name}')
print(f'[ DEBUG ] DB_USER:                  {database}')
print(f'[ DEBUG ] DB_NAME:                  {username}')
print(f'[ DEBUG ] REDIS_HOST:               {redis_host}')
print(f'[ DEBUG ] REDIS_PORT:               {redis_port}')

def getconn() -> pymysql.connections.Connection:
    conn: pymysql.connections.Connection = connector.connect(
        instance_connection_name,
        "pymysql",
        user=username,
        password=password,
        db=database
    )
    return conn


pool = sqlalchemy.create_engine(
    "mysql+pymysql://",
    creator=getconn,
)


@app.route('/create_table', methods=['GET'])
def create_table():
    try:
        with pool.connect() as db_conn:
            # insert into database
            db_conn.execute('''CREATE TABLE Persons (
            PersonID int,
            LastName varchar(255),
            FirstName varchar(255)
            );''')
            
            # query database
            result = db_conn.execute("SELECT * from Persons").fetchall()
            
            # Do something with the results
            results = []
            for row in result:
                results.append(row)
                print(row)
        
        return results
    except Exception as e:
        print(f'[ EXCEPTION ] {e}')
        return f'{e}'


@app.route('/query', methods=['GET'])
def query():
    with pool.connect() as db_conn:
        
        db_conn.execute(f'''INSERT INTO Persons (PersonID, LastName, FirstName)
        VALUES ({random.randint(1000000,9000000)}, "Smith", "John");''')
        
        # query database
        result = db_conn.execute("SELECT * from Persons").fetchall()
        
        # Do something with the results
        results = []
        for row in result:
            results.append(row)
            print(row)
    
    return f'{results}'


@app.route('/redis')
def redis():
    value = redis_client.incr('counter', 1)
    return f'Visitor number: {value}'


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
