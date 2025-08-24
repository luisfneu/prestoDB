# PrestoDB
https://prestodb.io/
https://dzone.com/refcardz/getting-started-with-prestodb
https://prestodb.io/docs/current/installation/deployment.html#installing-presto

https://hive.apache.org/


## Objetivo
Run PrestoDB in Docker
Persist data in Hive or other
Support SQL

## Folder
    presto-docker/
    ├── docker-compose.yaml
    ├── hive/
        └── warehouse/
    ├── etc/
        ├── catalog/
        │   └── hive.properties
        └── config.properties

## Docker
https://hub.docker.com/r/prestodb/presto

## Persist
All data persisted in hive/warehouse/

## run
    docker-compose up -d

## test
http://localhost:8080/

## how to use

    SHOW CATALOGS;

    SHOW SCHEMAS FROM hive;

    CREATE SCHEMA hive.LL_data;

    CREATE TABLE hive.LL_data.person (
    id INT,
    nome VARCHAR
    );

    INSERT INTO hive.LL_data.person VALUES (1, 'luis neu');

    SELECT * FROM hive.LL_data.person;