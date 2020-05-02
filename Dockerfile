FROM node:12
LABEL maintainer="cmil@hashtable.de"

ENV dbhost 0.0.0.0
ENV dbport 1984
ENV dbname histvv

WORKDIR /usr/src/histvv
COPY . .
RUN npm install

# add wait-for-it.sh so it can be used with docker-compose
RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
      -O /usr/local/bin/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

EXPOSE 3000/tcp

# override node:12 ENTRYPOINT
ENTRYPOINT []

CMD /usr/src/histvv/bin/www --db $dbname --dbhost $dbhost --dbport $dbport
