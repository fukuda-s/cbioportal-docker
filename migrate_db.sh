#!/bin/bash

PORTAL_HOME=/root/cbioportal

yes | migrate_db.py -p ${PORTAL_HOME}/src/main/resources/portal.properties -s ${PORTAL_HOME}/db-scripts/src/main/resources/migration.sql

exit 0
