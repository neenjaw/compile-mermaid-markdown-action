FROM zenato/puppeteer

USER root
WORKDIR /
RUN yarn add mermaid.cli

WORKDIR /mmdc
COPY . /mmdc

ENV ENTRYPOINT_PATH /mmdc

ENTRYPOINT [ "/mmdc/entrypoint.sh" ]
CMD [ "--help" ]
