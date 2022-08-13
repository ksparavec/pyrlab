FROM rlab-base

ENV PORT=9999

USER ${USER}

WORKDIR ${HOMEDIR}

COPY --chown=${USER}:${USER} r_requirements.txt ./

# install non-system Python modules
RUN set -eux; \
    export PYTHONDONTWRITEBYTECODE=1; \
    pip install \
        --no-warn-script-location \
        --disable-pip-version-check \
        --no-cache-dir \
        --no-compile \
        --user \
        -r r_requirements.txt; \
    export PATH=${HOMEDIR}/.local/bin:${PATH}; \
    mkdir -p -m 0755 ${FILES} ${HOME}/.local/bin

# Add spreadsheet view functionality
RUN jupyter labextension install jupyterlab-spreadsheet

COPY --chown=${USER}:${USER} r_packages.txt ./

# install further R packages
RUN set -eux; \
    command="install.packages(c("; \
    while read package; do \
        command=${command}'"'${package}'",'; \
    done <r_packages.txt; \
    command=$(echo ${command} | sed 's/,$//'); \
    command=${command}"),Ncpus=8)"; \
    r -e ${command}; \
    export PATH=${HOMEDIR}/.local/bin:${PATH}; \
    r -e 'IRkernel::installspec()'; \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds; \
    mkdir -p -m 0755 ${FILES} ${HOME}/.local/bin

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD cd ${HOMEDIR} && cd ${FILES} && jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0

