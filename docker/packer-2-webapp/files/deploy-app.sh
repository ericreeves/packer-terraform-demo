#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

echo "Creating /var/www/html/index.html"

cat << EOM > /var/www/html/index.html
<html>
  <head><title>AcmeCo Live Demo Build - Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://placekitten.com/600/400"></img></center>
  <center><h2>Meow World!</h2></center>
  Welcome to AcmeCo - Live Demo Build.
  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "deploy-app.sh Script Complete."
