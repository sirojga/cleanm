#!/bin/bash

INSTALLATION_DIR=/opt/nms/
BUILD_DIR=./build

if [ -d ./unpacked ]; then
    rm ./unpacked -rf
fi

if [ -d ${BUILD_DIR} ]; then
    rm ${BUILD_DIR} -rf
fi
mkdir "${BUILD_DIR}"
mkdir "${BUILD_DIR}/migrations"
unzip "${INSTALLATION_DIR}/bin/nms-backend-1.0.jar" -d ./unpacked

cat `ls -- unpacked/BOOT-INF/classes/db/migration/*.sql | sort -V` > ${BUILD_DIR}/migrations/ALL.sql
sed -i 's/ пары/\n/g'  ${BUILD_DIR}/migrations/ALL.sql

systemctl stop nms

export PGPASSWORD=nms
psql -h localhost -U nms -d nmsdb -c "DROP SCHEMA nms_schema CASCADE;"
psql -h localhost -U nms -d nmsdb -c "CREATE SCHEMA nms_schema;"
psql -h localhost -U nms -d nmsdb -f ${BUILD_DIR}/migrations/ALL.sql

systemctl start nms