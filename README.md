# jmlopez-rod

This repo contains the code to generate the main site for my account.

## Development

```shell
make image && make container
```

Once inside the container run

```shell
make install && make serve
```

Start making changes to the markdown files and see the changes
live at `http://localhost:4000`.

## Deployment

Inside the contain run `make build`. Exit the container and run `make siteImage`.

Run `make publish` and cross your fingers. If everything goes well you'll be
in the master branch and your changes will be reflected. Commit and push to Github.
