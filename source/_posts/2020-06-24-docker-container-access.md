---
layout: post
title: Docker Container Access
date: 2020-06-24 21:43:47 GMT-0500
categories: posts
tags: docker network
---

Making http calls from Docker containers to applications in other containers.

## Setup

Lets create containers that fire up a python http server.

```shell
~$ mkdir tmp && cd tmp
~/tmp$ echo ContainerA > indexA.html && echo ContainerB > indexB.html
```

Create the files `a.Dockerfile`

```dockerfile
FROM python:3.5.9-alpine3.12

WORKDIR /app

COPY indexA.html index.html

CMD [ "python", "-m", "http.server" ]
```

and `b.Dockerfile`

```dockerfile
FROM python:3.5.9-alpine3.12

WORKDIR /app

COPY indexB.html index.html

CMD [ "python", "-m", "http.server" ]
```

Create the images

```shell
docker build -t image-a -f a.Dockerfile . && docker build -t image-b -f b.Dockerfile .
```

Lets run `image-a` on port 8000

```shell
docker run -p 8000:8000 -it --rm --name image_a image-a
```

and `image-b` on port 9000

```shell
docker run -p 9000:8000 -it --rm --name image_b image-b
```

![image]({{ site.baseurl }}/assets/img/posts/docker-container-access/localhost.png)

## Issues

In the host machine we can open up a terminal and do

```shell
~$ curl http://localhost:8000
ContainerA
~$ curl http://localhost:9000
ContainerB
```

From within the container we should be able to do the same

```shell
~$ docker exec -it image_a sh
/app # apk add curl
fetch http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.12/community/x86_64/APKINDEX.tar.gz
(1/3) Installing nghttp2-libs (1.41.0-r0)
(2/3) Installing libcurl (7.69.1-r0)
(3/3) Installing curl (7.69.1-r0)
Executing busybox-1.31.1-r16.trigger
OK: 10 MiB in 28 packages
/app # curl http://localhost:8000
ContainerA
/app # curl http://localhost:9000
curl: (7) Failed to connect to localhost port 9000: Connection refused
```

How can we reach the server located in `image_b` container?

> Use the IP address of the host

```shell
/app # curl http://192.168.1.21:9000
ContainerB
```

## Mac OS X

The above does not work on mac. Funny enough, if we obtain the IP address
from the OS X machine and curl port 9000 from a linux box we obtain the
file we want but the containers running inside OS X cannot connect to any other
container. Why?
