# https://nodejs.org/en/about/releases/
# https://github.com/nodejs/Release#readme
FROM node:12-alpine3.11

RUN apk add --no-cache bash tini

EXPOSE 8081

# override some config defaults with values that will work better for docker
ENV ME_CONFIG_EDITORTHEME="default" \
    ME_CONFIG_MONGODB_URL="mongodb://mongo:27017" \
    ME_CONFIG_MONGODB_ENABLE_ADMIN="true" \
    ME_CONFIG_BASICAUTH_USERNAME="" \
    ME_CONFIG_BASICAUTH_PASSWORD="" \
    VCAP_APP_HOST="0.0.0.0"

ENV MONGO_EXPRESS 1.0.0-alpha.4

RUN set -eux; \
	apk add --no-cache --virtual .me-install-deps git; \
	npm install mongo-express@$MONGO_EXPRESS; \
    npm install --save dd-trace; \
	apk del --no-network .me-install-deps

COPY docker-entrypoint.sh /

WORKDIR /node_modules/mongo-express

# RUN cp config.default.js config.js
COPY config.js /node_modules/mongo-express/config.js

ENTRYPOINT [ "tini", "--", "/docker-entrypoint.sh"]
CMD ["mongo-express"]
