FROM mysql:5.7

ADD startup docker-entrypoint-initdb.d
