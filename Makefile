image:
	podman build -t jmlopez-rod.github.io .

container:
	podman run \
	  --rm \
	  -it \
	  -w /checkout \
	  -p 4000:4000 \
	  -v ${PWD}:/checkout:z \
	  jmlopez-rod.github.io \
	  /bin/sh

install:
	cd source && bundle install

serve:
	cd source && bundle exec jekyll serve
