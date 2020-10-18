#!/bin/bash


plan () {
    VERSION=$1
    terraform plan \
        -destroy \
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

plan $1
apply $1
