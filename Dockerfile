FROM node:6.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update -y && apt-get install -y raptor2-utils

COPY . /usr/src/app
RUN npm install && npm run compile

EXPOSE 3000
CMD npm start
