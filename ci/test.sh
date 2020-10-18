#!/bin/bash

scan_terraform () {
    terrascan scan \
        -t aws \
        -p ${HOME}/programming/terrascan/pkg/policies/opa/rego/ \
        -d infrastructure
}

scan_terraform
