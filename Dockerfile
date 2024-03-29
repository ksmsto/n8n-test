# change if you need a different node version
ARG NODE_VERSION=18
FROM n8nio/base:${NODE_VERSION}

# change to your desired n8n version
ARG N8N_VERSION="1.23.0"
EXPOSE 5678
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

ENV N8N_VERSION=${N8N_VERSION}
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
# change variables to your postgresdb settings in cloudrun variables
ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_DATABASE=xxx
ENV DB_POSTGRESDB_HOST=xxx
ENV DB_POSTGRESDB_PORT=xxx
ENV DB_POSTGRESDB_USER=xxx
ENV DB_POSTGRESDB_SCHEMA=xxx
ENV DB_POSTGRESDB_PASSWORD=xxx
ENV N8N_ENCRYPTION_KEY=xxx

RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
	'armv7') apk --no-cache add --virtual build-dependencies python3 build-base;; \
	esac && \
	npm install -g --omit=dev n8n@${N8N_VERSION} && \
	case "$apkArch" in \
	'armv7') apk del build-dependencies;; \
	esac && \
	rm -rf /usr/local/lib/node_modules/n8n/node_modules/@n8n/chat && \
	rm -rf /usr/local/lib/node_modules/n8n/node_modules/n8n-design-system && \
	rm -rf /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/node_modules && \
	find /usr/local/lib/node_modules/n8n -type f -name "*.ts" -o -name "*.js.map" -o -name "*.vue" | xargs rm -f && \
	rm -rf /root/.npm

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN \
	mkdir .n8n && \
	chown node:node .n8n
USER node

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]