FROM node:13.7.0-alpine3.11

WORKDIR /opt/compile-mermaid

COPY . /opt/compile-mermaid

RUN npm i --production

ENTRYPOINT [ "/opt/compile-mermaid/entrypoint.sh" ]