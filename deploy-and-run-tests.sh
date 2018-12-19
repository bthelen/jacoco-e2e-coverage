#!/usr/bin/env bash

set -ex

# This script is going to assume some things
# 1.  You have checked out bthelen/jacoco-e2e-coverage and bthelen/jacoco-tcpserver as to the same directory.
# 2.  You have already cf logged in to the foundation you wish to target
# 3.  You have permission to cf add-network-policy
# 4.  You have "expect" installed where this will run
# 5.  Run this script from the directory where bthelen/jacoco-e2e-coverage is checked out

# build and push --no-start jacoco tcp server
pushd ../jacoco-tcpserver
mvn clean install
cf push -f manifest.yml --no-start

# create the cups for the jacoco tcpserver
cf cups my-jacoco-service -p '{"address":"jacoco-tcpserver.apps.internal","includes":"*", "port":"6300"}'

# build and deploy --no-start client
popd
mvn clean install -DskipTests
cf push -f manifest.yml --no-start

# create network policy to let those two things speak
cf add-network-policy jacoco-e2e-coverage --destination-app jacoco-tcpserver  --protocol tcp --port 6300

# start jacoco tcp server
cf start jacoco-tcpserver

# start client
cf start jacoco-e2e-coverage

sleep 5

# run tests against client
mvn test -Dapp.url="https://jacoco-e2e-coverage.apps.pcfone.io" -Dparameter=5

sleep 5

# stop and undeploy client
cf stop jacoco-e2e-coverage

sleep 5

# copy file from jacoco tcp server -- but how to get password!!
# scp -P 2222 -o User=cf:$(cf app jacoco-tcpserver --guid)/0  ssh.run.pcfone.io:/home/vcap/app/jacoco-server.exec .
./get_jacoco_report.exp $(cf app jacoco-tcpserver --guid) $(cf ssh-code) ssh.run.pcfone.io

# Run mvn to create the report from that file we just downloaded
mvn antrun:run@generate-report -Dskip.int.tests.report=false

# Undeploy the app we are testing
cf delete jacoco-e2e-coverage -f

# stop and undeploy jacoco tcp server
cf delete jacoco-tcpserver -f

# clean up unused UPS
cf delete-service my-jacoco-service -f
