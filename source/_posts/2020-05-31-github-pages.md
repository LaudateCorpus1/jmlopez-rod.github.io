---
layout: post
title: Github Pages
date: 2020-05-31 21:24:47 GMT-0500
categories: posts
tags: github jekyll web
---

Setting up your github page with [jekyll] is relatively simple. This post
outlines all the step that were taken to create this site.

## Isolated Enviroment

The first thing to consider is that jekyll has a bit of [requirements]. The goal
for the project is be able to go to any machine that may have [docker] or
[podman] to update the site. Since Fedora already came with podman installed 
we'll be using `podman` commands. Keep in mind that these commands can be
substituded by `docker`.

To avoid having to do any setup in our machines and risking that a setup that
once worked before breaks when we update dependencies we will create the
following Dockerfile

```dockerfile
FROM alpine:3.11.6

RUN apk add --no-cache \
  build-base \
  ruby-full \
  ruby-dev \
  libxml2-dev \
  libxslt-dev \
  git

RUN gem install jekyll bundler && bundle config --global silence_root_warning 1

ENV GEM_HOME=./_gems
```

First we install ruby along with several dependencies that are necessary to
install jekyll and some of its plugins. At the moment of writing, the website is
very simple and it took a bit of google-ing to find out what libraries were needed
to get it to work under alpine. If the command `gem install jekyll bundler`
fails when you are building the image you may need to do a bit of google
searching to find out the libraries that need to be installed.

To build the image on your system add the following to a Makefile.

```make
image:
	podman build -t jmlopez-rod.github.io .
```

Then we can run `make image`. This will take a while so be patient. After it is
done we can see the size of each layer in the image by seeing its history

```shell
$ podman history jmlopez-rod.github.io
ID             CREATED       CREATED BY                                      SIZE      COMMENT
f919b980885c   3 hours ago   /bin/sh -c #(nop) ENV GEM_HOME=./_gems          0B        
<missing>      3 hours ago   /bin/sh -c gem install jekyll bundler && b...   56.34MB   
f9fbd7f231f1   2 days ago    /bin/sh -c apk add --no-cache build-base r...   225.8MB   
f70734b6a266   5 weeks ago   /bin/sh -c #(nop) CMD ["/bin/sh"]               0B        
<missing>      5 weeks ago   /bin/sh -c #(nop) ADD file:b91adb67b670d3a...   5.879MB
```

## Creating the site

Add the following to the Makefile

```make
container:
	podman run \
	  --rm \
	  -it \
	  -w /checkout \
	  -p 4000:4000 \
	  -v ${PWD}:/checkout:z \
	  jmlopez-rod.github.io \
	  /bin/sh
```

Run `make container` to run the image and to have a access to a shell. Once
inside the container you have access to `jekyll`. Start the site
with

```shell
jekyll new source
```

Add these new task to the Makefile

```make
install:
	cd source && bundle install

serve:
	cd source && bundle exec jekyll serve
```

The file `source/Gemfile` will eventually specify other modules so we'll have
to install them when we move to another machine. At this point we are ready
to see the changes. Run `make serve` and visit `http://localhost:4000`.

## Publishing

To publish we just need to make sure that the contents of `source/_site` are
at the root directory of the repo in the `master` branch. For this reason this
repo has all of the source files in the `source` branch.

Add the following to the `Makefile`.

```make
siteImage:
	podman build -t jmlopez-rod -f prod.Dockerfile .

publish:
	./publish.sh
```

where the files `prod.Dockerfile` and `publish.sh` have the following contents:

```dockerfile
FROM scratch

COPY source/_site ./_site
```

```shell
#!/bin/bash -x

git checkout master

image=jmlopez-rod
targetDir=.

podman create -it --name unpack "$image" bash || exit 1
podman cp unpack:/_site/. "$targetDir" || exit 1
podman rm -f unpack
```

Once the we have the static files we run `make siteImage` to store the static
files in the `jmlopez-rod` image. To get those files in the `master` branch we
run `make publish`. Make sure to run `chmod +x publish.sh` to give the shell
script exec permissions.

If successful the contents of the `source/_site` folder will be root repo
directory ready to be commited. Add a commit and push to see the changes
deployed by github.


[jekyll]: https://jekyllrb.com/docs/
[requirements]: https://jekyllrb.com/docs/installation/#requirements
[docker]: https://www.docker.com/get-started
[podman]: https://podman.io/getting-started/
