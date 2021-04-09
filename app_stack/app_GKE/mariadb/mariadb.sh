#!/bin/bash

helm2 install --name mariadb -f ./values.yaml stable/mariadb
