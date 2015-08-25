#!/bin/bash
docker run -it \
  -v /etc/localtime:/etc/localtime \
  -e GMAIL \
  -e GMAIL_NAME \
  -e GMAIL_PASS \
  -e GMAIL_FROM \
  -v $HOME/.gnupg:/home/user/.gnupg \
  mymutt
#jess/mutt
