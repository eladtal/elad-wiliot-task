from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests
import psycopg2
import logging
import re

# DB connection settings
DB_HOST = "wiliot-devops-postgres.cniwsla7fltp.eu-west-1.rds.amazonaws.com"
DB_NAME = "wiliot"
DB_USER = "elad"
DB_PASS = "P$SSW0RD"
API_URL = "http://abe1100c7613a4bebae8d962d3fc539c-1534427791.eu-west-1.elb.amazonaws.com/users"

default_args = {
    'owner': 'elad',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

dag = DAG(
    dag_id='dummy_ingest',
    default_args=default_args,
    schedule_interval='@hourly',
    catchup=False
)

def fetch_and_transform_insert():
    logging.info("Calling dummy API")
    resp = requests.get(API_URL)
    data = resp.json()

    rows = []
    for user in data:
        name = user.get("name", "")
        email = user.get("email", "").lower()
        address = user.get("address", {})

        # Skip invalid emails
        if not email or not re.match(r"[^@]+@[^@]+\.[^@]+", email):
            continue

        # Normalize name
        name_parts = name.strip().split()
        first_name = name_parts[0] if len(name_parts) > 0 else ""
        last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else ""

        # Build full address
        street = address.get("street", "")
        suite = address.get("suite", "")
        city = address.get("city", "")
        zipcode = address.get("zipcode", "")
        full_address = f"{street} {suite}, {city}, {zipcode}".strip()

        rows.append((first_name, last_name, email, full_address))

    logging.info(f"Inserting {len(rows)} users into database")

    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS dummy_users (
            id SERIAL PRIMARY KEY,
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            address TEXT
        )
    """)

    cur.executemany("""
        INSERT INTO dummy_users (first_name, last_name, email, address)
        VALUES (%s, %s, %s, %s)
    """, rows)

    conn.commit()
    cur.close()
    conn.close()
    logging.info("Insert complete")

task = PythonOperator(
    task_id='fetch_transform_insert',
    python_callable=fetch_and_transform_insert,
    dag=dag
)