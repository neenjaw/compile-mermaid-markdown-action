FROM node:13.7.0-alpine3.11

RUN apk add --no-cache udev ttf-freefont chromium git

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV CHROMIUM_PATH /usr/bin/chromium-browser

WORKDIR /opt/compile-mermaid

COPY . /opt/compile-mermaid

RUN npm i --production

ENTRYPOINT [ "/opt/compile-mermaid/entrypoint.sh" ]