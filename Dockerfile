FROM zenato/puppeteer

USER root
WORKDIR /
RUN yarn add mermaid.cli

WORKDIR /mmdc

COPY . /mmdc

ENTRYPOINT [ "/mmdc/entrypoint.sh" ]
CMD [ "--help" ]
