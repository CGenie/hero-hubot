# DOCKER-VERSION  1.3.2

FROM ubuntu:14.04
MAINTAINER Nathaniel Hoag, info@nathanielhoag.com

ENV BOTDIR /opt/bot

RUN apt-get update && \
  apt-get install -y wget && \
  wget -q -O - https://deb.nodesource.com/setup | sudo bash - && \
  apt-get install -y git build-essential nodejs && \
  rm -rf /var/lib/apt/lists/*

WORKDIR ${BOTDIR}

ENV HUBOT_PORT 8080
ENV PORT ${HUBOT_PORT}

EXPOSE ${HUBOT_PORT}

ADD . ${BOTDIR}

RUN npm install

CMD bin/hubot
