---
layout: post
title:  Github SSH Keys
date:   2020-05-29 00:32:01 GMT-0500
categories: posts
tags: ssh github
---

Adding a public ssh key to Github allow us to perform git commands without having
to type in our password to authenticate. For this to work we need to make sure that
our repo is set to use ssh and that Github has our public key.

```config
jmlopez-rod.github.io $ cat .git/config 
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = git@github.com:jmlopez-rod/jmlopez-rod.github.io.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```

Notice that the url under `[remote "origin"]` starts with `git@github.com` and
not with `https://github.com`. Some reasons as to why it would use the https protocol
may be due to using [Github Desktop] or because we manually issued the command
`git clone https://github.com/...`.

## ssh

If you do not have any ssh keys in your machine then attempting to ssh to
github.com as the `git` user yields the following

```shell
$ ssh git@github.com
git@github.com: Permission denied (publickey).
```


### Create a key

Start by navigating to your `.ssh` directory

```shell
$ mkdir -p ~/.ssh && chmod 700 ~/.ssh && cd .ssh
```

The command to generate an ssh key is of the following form.

```shell
$ ssh-keygen -m PEM -f [file-name] -C [key-comment] -N '' -t rsa -q
```

Its helpful to add a comment on the key to help you remember what the key is used
for. Here is one way for instance

```shell
$ githubUser=[your-github-username]
$ ssh-keygen -m PEM -f "github_${githubUser}" -C "${githubUser}@github" -N '' -t rsa -q
```

Print the key with

```shell
cat "github_${githubUser}.pub"
```

Copy the string and add it to [Github][github-ssh].

### Using the key

To use the newly created key after the public key is added to Github we need to tell
ssh to use it. Here is one way

```shell
$ ssh -i "~/.ssh/github_${githubUser}" git@github.com
PTY allocation request failed on channel 0
Hi jmlopez-rod! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

The `-i` option specifies the identity file and it is useful whenever we are testing
connections via ssh keys without modifying the ssh configuration file. Which brings us
to the next step. Do the following command

```shell
$ touch ~/.ssh/config && chmod 600 ~/.ssh/config
```

Open it with your favorite editor and add the following

```config
Host github.com
  User git
  HostName github.com
  IdentityFile ~/.ssh/github_[your-github-username]
```

Now ssh will know how to connect to host.

```shell
$ ssh github.com
PTY allocation request failed on channel 0
Hi jmlopez-rod! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

Note that we did not have to specify the user, that is `ssh git@github.com`. This is because
the configuration specifies it in the `User` field. Now you should be able to do

```ssh
git clone git@github.com:owner/repo.git
```

as long as you have permissions to said repo.

[github-ssh]: https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account
[Github Desktop]: https://desktop.github.com/
