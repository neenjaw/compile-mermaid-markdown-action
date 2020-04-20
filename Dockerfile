FROM neenjaw/mermaid:node-13

WORKDIR /mmdc
COPY . /mmdc

ENV ENTRYPOINT_PATH /mmdc

ENTRYPOINT [ "/mmdc/entrypoint.sh" ]
CMD [ "--help" ]
