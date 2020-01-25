FROM alpine:edge

# Installs latest Chromium package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      npm

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

WORKDIR /opt/compile-mermaid

COPY . /opt/compile-mermaid
RUN npm i --production

ENTRYPOINT [ "/opt/compile-mermaid/entrypoint.sh" ]