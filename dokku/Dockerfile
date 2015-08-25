FROM ubuntu:14.04

RUN apt-get install -y wget

RUN wget -qO- https://raw.github.com/progrium/dokku/v0.3.13/bootstrap.sh | sudo DOKKU_TAG=v0.3.13 bash

