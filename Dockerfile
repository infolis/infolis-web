FROM node:6.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update -y && apt-get install -y raptor2-utils

COPY package.json /usr/src/app/package.json
RUN npm install
COPY . /usr/src/app

CMD ['npm', 'start']
