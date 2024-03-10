# db.Dockerfile
FROM mariadb

ADD /assets/*.sql /docker-entrypoint-initdb.d