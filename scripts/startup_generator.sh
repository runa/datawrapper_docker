#!/bin/bash

export MYSQL_PASSWORD=""
envtpl < /tmp/templates/startup.sh.template > /tmp/startup.sh
chmod +x /tmp/startup.sh
/tmp/startup.sh
