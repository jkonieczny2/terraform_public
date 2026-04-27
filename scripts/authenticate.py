#!/usr/bin/python3
import ast
import sys
import json
import boto3
import argparse
import functools

from botocore.exceptions import ClientError

REGIONS = [
    "us-east-2",
]

SECRETS = {
    "prod": "terraform-secret",
}

def get_boto3_creds_for_environment(environment):
    if environment not in SECRETS:
        raise Exception(f"No available secret for environment {environment}")

    raw = get_secret(SECRETS[environment])

    secret = json.loads(raw)

    ret = {}
    for key, value in secret.items():
        ret["aws_access_key_id"] = key
        ret["aws_secret_access_key"] = value
        break

    return ret

@functools.lru_cache(maxsize=None)
def get_ec2_client(region, environment):
    secret = get_boto3_creds_for_environment(environment)

    return boto3.client(
        "ec2",
        region_name=region,
        **secret,
    )

def get_secret(secret_name):

    region_name = "us-east-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response['SecretString']

    return secret

def create_bash_eval(secret):
    s = ""
    for key, value in secret.items():
        s += "export AWS_ACCESS_KEY={}".format(key)
        s += " && "
        s += "export AWS_SECRET_ACCESS_KEY={}".format(value)
        break

    return s

def create_parser():
    p = argparse.ArgumentParser()

    p.add_argument("environment", choices=SECRETS.keys())

    return p

def main():
    """
    Print environment variable-setting commands to stdout so they can be eval'd
    """
    p = create_parser()
    args = p.parse_args()

    secret_name = SECRETS[args.environment]

    secret = get_secret(secret_name)
    secret = ast.literal_eval(secret)

    print(create_bash_eval(secret))

if __name__ == "__main__":
    sys.exit(main())
