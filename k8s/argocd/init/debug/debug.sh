#! /bin/bash

helm template ../ -f ../values.yaml --debug > ./output.yaml
