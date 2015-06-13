![Docker + MariaDB](https://cloud.githubusercontent.com/assets/6241518/4245631/8db69fba-3a3c-11e4-8294-244919e4af7c.jpg)

docker-mariadb is an Ubunutu Docker image for MariaDB containers.

## Credits
This image is forked from [Dylan Lindgren's MariaDB project](https://github.com/dylanlindgren/docker-mariadb) and also uses a lot bits from [Dockerfile](https://github.com/dockerfile/mariadb).

## Image construction
The image is formed from the following layers
 - debian:jessie
 - MySQL 


## Getting the image
This image is published in the [Docker Hub](https://registry.hub.docker.com/). Simply run the below command to get it on your machine:

```bash
docker pull dylangmiles/docker-mariadb
```

## Understanding the image
This image adheres to the principle of having a Docker container for each process.

The image is constructed from the following layers:
 - debian:jesse
 - MariaDB 10.1

All data is redirected to the `/data/mariadb/data` location and when this is mapped to the host using the `-v` switch then the container is completely disposable.

The startup script (which is the containers default entrypoint) checks `/data/mariadb`, and if it's empty it initialises it by running the `/usr/bin/mysql_install_db` command, and then runs `/usr/bin/mysqld_safe` with an initial SQL file which ensures the database is securely configured for remote access. If the `/data/mariadb` folder contains data then it just runs `/usr/bin/mysqld_safe`.

The steps that are performed to secure the database:
 - Sets the `root` password as `abc123` **Note - you should change this!!**
 - Sets full privileges for `root'@'172.17.42.1`. 
 
`172.17.41.1` is the IP address of the `docker0` interface on the docker host. So this allows you to connect from an OSX host through an ssh tunnel into the docker host and from there a connection to the MariaDB port of 3309 can be made into the container. This is great for getting up and running dev environment easily. 

## Creating and running the container
To create and run the container:
```bash
docker run --privileged=true -v /data/mariadb:/data/mariadb:rw -p 3306:3306 -d --name mariadb dylangmiles/docker-mariadb
```
 - `-p` publishes the container's 3306 port to 3306 on the host
 - `--name` sets the name of the container (useful when starting/stopping).
 - `-v` maps the `/data/mariadb` folder as read/write (rw).
 - `-d` runs the container as a daemon


To stop the container:
```bash
docker stop mariadb
```

To start the container again:
```bash
docker start mariadb
```

## Notes on setting up the volume mapping on OSX using docker-machine
There are difficulties with mapped volume permissions when running Docker on OSX using Boot2Docker or the docker-machine to host the docker dameon. 

The problem comes into play because the container runs as the user mysql (uid:999) and the default /Users mount in docker-machine is owned by the docker user. As a result the container running as mysql does not have write permissions to the physical directory on the osx host. 

To get this working:
 - Create a directory on your host machine: `mkdir ~/Development/Storage/database`
 - Run `machine-docker ssh` and create a directory: `sudo mkdir /database` in the docker machine.
 - Open VirtualBox and create a shared folder mapping called `database` and mapped to the directory you created on your OSX host: `~/Development/Storage/database`
 - Mount the directory with a uid and guid of 999 (The mysql uid). You can run this command from your OSX host: `docker-machine ssh dev 'sudo mount -t vboxsf -o "defaults,uid=999,gid=999,rw" database /database'` 


### Running as a Systemd service
To run this container as a service on a [Systemd](http://www.freedesktop.org/wiki/Software/systemd/) based distro (e.g. CentOS 7), create a unit file under `/etc/systemd/system` called `mariadb.service` with the below contents
```bash
[Unit]
Description=MariaDB Docker container (dylangmiles/docker-mariadb)
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop mariadb
ExecStartPre=-/usr/bin/docker rm mariadb
ExecStartPre=-/usr/bin/docker pull dylanlindgren/docker-mariadb
ExecStart=/usr/bin/docker run --privileged=true -v /data/mariadb:/data/mariadb:rw -p 3306:3306 --name mariadb dylanlindgren/docker-mariadb
ExecStop=/usr/bin/docker stop mariadb

[Install]
WantedBy=multi-user.target
```
Then you can start/stop/restart the container with the regular Systemd commands e.g. `systemctl start mariadb.service`.

To automatically start the container when you restart enable the unit file with the command `systemctl enable mariadb.service`.
