#!/usr/bin/env bash

set -ex

# This script is going to assume some things
# 1.  You have already cf logged in to the foundation you wish to target
# 2.  Run this script from the directory where bthelen/jacoco-e2e-coverage is checked out

# build and deploy app we are going to use
mvn clean install -DskipTests
# the contents of this user provided service really don't matter because we are overriding the start command
cf cups my-jacoco-service -p '{"address":"jacoco-tcpserver.apps.internal","includes":"*", "port":"6300"}'
cf push -f manifest.yml

sleep 5

# run tests against client
mvn test -Dapp.url="https://jacoco-e2e-coverage.apps.pcfone.io" -Dparameter=5

# If you want more coverage...run this one as well
# mvn test -Dapp.url="https://jacoco-e2e-coverage.apps.pcfone.io" -Dparameter=11

set +x
echo "**************************************************************************************"
echo "Please run \"cf ssh -N -T -L 5000:localhost:5000 jacoco-e2e-coverage\" in another window"
echo "Waiting 25 seconds for you to get that up and running..."
echo "**************************************************************************************"
sleep 25
set -x

# get the results via JMX from the server.
# cf ssh -N -T -L 5000:localhost:5000 jacoco-e2e-coverage
java -cp ./target/test-coverage-example-0.0.1-SNAPSHOT.jar.original com.ps.e2e.jacoco.testcoverageexample.MBeanClient

# Run mvn to create the report from that file we just downloaded
mvn antrun:run@generate-report -Dskip.int.tests.report=false

# Undeploy the app we are testing
cf delete jacoco-e2e-coverage -f

# clean up user provided service
cf delete-service my-jacoco-service -f
