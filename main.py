import json


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": json.dumps(
            """
            <html><head><title>
            Terrascan - Secure your Infrastructure as Code
            </title></head><body>
            <img width="500" src="/static/terrascan_logo.png" />
            </body></html>
            """
        ),
    }
