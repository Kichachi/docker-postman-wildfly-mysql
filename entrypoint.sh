#!/bin/bash
#WFeD0rZipz 
/etc/init.d/mysql start

git clone http://jit_user:WFeD0rZipz@bitbucket.lppdev.pl/scm/plog/locus.git
git checkout PLOG-393
cd locus && mvn clean install -D skipTests -P setup-local-wildfly
cp locus-services/target/locus-services.war wildfly-10.1.0.Final/standalone/deployments/

cp locus-courier-dpd/target/locus-courier-dpd.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-ups/target/locus-courier-ups.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-gls/target/locus-courier-gls.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-cdek/target/locus-courier-cdek.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-dpdru/target/locus-courier-dpdru.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-hermes/target/locus-courier-hermes.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-xpress/target/locus-courier-xpress.war wildfly-10.1.0.Final/standalone/deployments/
cp locus-courier-russianpost/target/locus-courier-russianpost.war wildfly-10.1.0.Final/standalone/deployments/

mysql -u root -e 'CREATE USER "locus"@"localhost" IDENTIFIED BY "locus1234"';
mysql -u root < locus-database/docker/init.sql
sh wildfly-10.1.0.Final/bin/standalone.sh &

while ! [ -f wildfly-10.1.0.Final/standalone/deployments/locus-services.war.deployed ];
do
    echo "#"
    sleep 1
done
newman run postman-tests/Token/Token.json --export-globals globals.json -e postman-tests/LOCALHOST_8080.postman_environment.json --reporter-html-template token-results.html --reporter-junit-export token-results.xml
newman run postman-tests/tracking/DPD.json --globals globals.json -e postman-tests/LOCALHOST_8080.postman_environment.json --reporter-html-template tracking-dpd-results.html --reporter-junit-export tracking-dpd-results.xml


#docker run -v c:\repos\locus-2\postman-tests:/postman -it postman/newman_ubuntu1404 --collection="/postman/tracking/DPD.json" --environment="/postman/LOCALHOST_8080.postman_environment.json" --html="newman-results.html" --testReportFile="newman-report.xml"