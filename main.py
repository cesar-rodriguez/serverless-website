import os
import json
import base64
import random
import logging
import sys
import boto3


def get_logos(bucket_name):
    """
    Retrieves logos

    This function retrieves logos from S3 bucket and
    stores them in /tmp/static. It returns the list of
    logos retrieved.
    """
    # Creating directory if it doesn't exist
    if not os.path.exists("/tmp/static"):
        os.makedirs("/tmp/static")

    # Setting up boto3
    s3_client = boto3.client("s3")
    s3 = boto3.resource("s3")

    # Getting list of logos in bucket
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix="static/")
    logos = [logo["Key"] for logo in response["Contents"]]

    # Downloading logos to /tmp
    for logo in logos:
        s3.meta.client.download_file(bucket_name, f"{logo}", f"/tmp/{logo}")

    logger.info(f"From BUCKET:{bucket_name} retrieved Logos:{logos}")
    return logos


def lambda_handler(event, context):
    logo_choice = random.choice(LOGOS)
    logger.info(f"Logo to be used:{logo_choice}")

    with open(f"/tmp/{logo_choice}", "rb") as img:
        image = img.read()

    return {
        "isBase64Encoded": True,
        "statusCode": 200,
        "headers": {"Content-Type": "image/png"},
        "body": base64.b64encode(image).decode("utf-8"),
    }


# Setup Logging
logging.basicConfig(stream=sys.stdout)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retrieve logos
LOGOS = get_logos(os.environ["BUCKET_NAME"])
