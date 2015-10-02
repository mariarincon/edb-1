#!/bin/bash

 #echo 'Installing modules...'
 #cd /opt/nodejs; npm install

 echo 'Starting app... 2'
 nohup pm2 --help > /dev/null 2>&1&
 cd /opt/nodejs; pm2 -s -x start collectorApp.js
 cd /opt/nodejs; pm2 -s -x start senderApp.js
 cd /opt/java; nohup java -jar dcaAnalyzer.jar > analyzer.log  &