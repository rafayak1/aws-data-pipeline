import boto3
import json
from dateutil import parser
from datetime import datetime, timedelta
import logging
import os

# Configuration
RAW_BUCKET     = os.environ["BUCKET"]
RAW_PREFIX     = "raw/"
FILTERED_PREFIX= "filtered/"
EXPIRY_DAYS    = 180  # six months

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize S3 client
s3 = boto3.client('s3')

def list_raw_objects(bucket, prefix):
    paginator = s3.get_paginator('list_objects_v2')
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get('Contents', []):
            yield obj['Key']

def load_json(bucket, key):
    resp = s3.get_object(Bucket=bucket, Key=key)
    return json.load(resp['Body'])

def save_json(bucket, key, data):
    out_key = key.replace(RAW_PREFIX, FILTERED_PREFIX)
    s3.put_object(
        Bucket=bucket,
        Key=out_key,
        Body=json.dumps(data).encode('utf-8')
    )
    logger.info(f"Wrote filtered record to s3://{bucket}/{out_key}")

def is_expiring(record, days=EXPIRY_DAYS):
    cutoff = datetime.utcnow() + timedelta(days=days)
    for acc in record.get('accreditations', []):
        dt = parser.isoparse(acc['valid_until'])
        if dt <= cutoff:
            return True
    return False

def main():
    for key in list_raw_objects(RAW_BUCKET, RAW_PREFIX):
        logger.info(f"Processing {key}")
        record = load_json(RAW_BUCKET, key)
        if is_expiring(record):
            save_json(RAW_BUCKET, key, record)

if __name__ == "__main__":
    main()