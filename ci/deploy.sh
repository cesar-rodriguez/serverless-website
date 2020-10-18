#!/bin/bash


init () {
    terraform init infrastructure
}

plan () {
    VERSION=$1
    terraform plan \
        -var "lambda_version=${VERSION}" \
        -detailed-exitcode \
        -out=out.tfplan \
        infrastructure
}

apply () {
    terraform apply out.tfplan && rm out.tfplan
}

terminate () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || terminate "1 argument required, $# provided"

init
plan $1
apply $1
