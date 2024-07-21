# change if you need a different node version
ARG NODE_VERSION=22

FROM alpine AS litestream-builer
# change to your desired litestream version
ARG LITESTREAM_VERSION=0.3.13

ENV LITESTREAM_VERSION=${LITESTREAM_VERSION}
ADD "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-amd64.tar.gz" /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

FROM n8nio/base:${NODE_VERSION}
# change to your desired n8n version
ARG N8N_VERSION="1.50.1"
EXPOSE 5678
RUN if [ -z "$N8N_VERSION" ] ; then echo "The N8N_VERSION argument is missing!" ; exit 1; fi

ENV N8N_VERSION=${N8N_VERSION}
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
ENV GCS_BUCKET_URL=xxx
ENV N8N_ENCRYPTION_KEY=xxx
# max age, in hours, of the data of the executions
ENV EXECUTIONS_DATA_MAX_AGE=72
# whether to share the telemetry data with the n8n team 
ENV N8N_DIAGNOSTICS_ENABLED=false
# n8n base url (custom domain)
ENV N8N_EDITOR_BASE_URL=https://localhost:5678
# personalization for new users
ENV N8N_PERSONALIZATION_ENABLED=false
# display the hiring banner
ENV N8N_HIRING_BANNER_ENABLED=false
# when the workflow is success, the data won't be saved to the database
ENV EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
# prune past executions data
ENV EXECUTIONS_DATA_PRUNE=true

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
# copy the litestream binary from the previous stage
COPY --from=litestream-builer /usr/local/bin/litestream /usr/local/bin/litestream
COPY litestream.yml /etc/litestream.yml
RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /etc/litestream.yml
RUN chmod +x /usr/local/bin/litestream

RUN apk add bash

RUN \
	mkdir .n8n && \
	chmod +x .n8n && \
	chown node:node .n8n
USER node


ENTRYPOINT ["/docker-entrypoint.sh"]
