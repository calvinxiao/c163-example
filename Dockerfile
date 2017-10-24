FROM hub.c.163.com/library/node:8.4.0-alpine
MAINTAINER xiaojiawei@yeezon.com
COPY . /app
WORKDIR /app
EXPOSE 3000
CMD node --max-old-space-size=600 app.js
