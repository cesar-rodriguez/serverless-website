# diagram.py
from diagrams import Cluster, Diagram
from diagrams.aws.general import Users
from diagrams.aws.storage import S3
from diagrams.aws.compute import Lambda
from diagrams.aws.mobile import APIGateway

with Diagram("Terrascan Website", show=False, filename="01-s3-bucket"):
    users = Users("users")
    with Cluster("AWS Cloud"):
        s3 = S3("Logos Bucket")

    users >> s3

with Diagram("Terrascan Website", show=False, filename="02-lambda"):
    users = Users("users")
    with Cluster("AWS Cloud"):
        lambda_function = Lambda("Lambda Function")
        s3 = S3("Logos Bucket")

    users >> lambda_function >> s3

with Diagram("Terrascan Website", show=False, filename="03-gateway"):
    users = Users("users")
    with Cluster("AWS Cloud"):
        api_gw = APIGateway("API Gateway")
        lambda_function = Lambda("Lambda Function")
        s3 = S3("Logos Bucket")

    users >> api_gw >> lambda_function >> s3
