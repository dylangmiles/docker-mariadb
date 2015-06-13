FROM debian:jessie

MAINTAINER "Dylan Miles" <dylan.g.miles@gmail.com>

# Install MariaDB.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xcbcb082a1bb943db && \
  echo "deb http://mariadb.biz.net.id//repo/10.1/debian sid main" > /etc/apt/sources.list.d/mariadb.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server && \
  rm -rf /var/lib/apt/lists/*


# Configure MariaDB
ADD config/my.cnf /etc/mysql/my.cnf
ADD config/my.cnf /etc/my.cnf


# All the MariaDB data that you'd want to backup will be redirected here
RUN mkdir -p /data/mariadb
RUN chown mysql:mysql /data/mariadb
VOLUME ["/data/mariadb"]

# Port 3306 is where MariaDB listens on
EXPOSE 3306

# These scripts will be used to launch MariaDB and configure it
# securely if no data exists in /data/mariadb
COPY config/mariadb-start.sh /opt/bin/mariadb-start.sh 
COPY config/mariadb-setup.sql /opt/bin/mariadb-setup.sql
RUN chmod u=rwx /opt/bin/mariadb-start.sh
RUN chown mysql:mysql /opt/bin/mariadb-start.sh /opt/bin/mariadb-setup.sql

#RUN echo "root:docker" | chpasswd

# run all subsequent commands as the mysql user
USER mysql

ENTRYPOINT ["/opt/bin/mariadb-start.sh"]

