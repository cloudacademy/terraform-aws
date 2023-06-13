FROM public.ecr.aws/docker/library/mysql:8.0.33-debian

COPY ./create-local-db.sql /tmp

CMD [ "mysqld", "--init-file=/tmp/create-local-db.sql" ]