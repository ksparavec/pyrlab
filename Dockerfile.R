ARG PYTHONBASE
FROM rlab-base:${PYTHONBASE}

ARG APTPROXY
ARG PIPPROXY
ARG PIPHOST
ENV PORT=9999

USER ${USER}

WORKDIR ${HOMEDIR}

COPY --chown=${USER}:${USER} r_requirements.txt ./
COPY --chown=${USER}:${USER} r_packages.txt ./

# install non-system Python modules into ${HOMEDIR}/.local
RUN set -eux; \
    export PYTHONDONTWRITEBYTECODE=1; \
    [[ zzz${PIPPROXY} != zzz ]] && export USEPROXY="-i ${PIPPROXY}/root/pypi/+simple --trusted-host ${PIPHOST}"; \
    pip install --upgrade pip; \
    pip install \
        --no-warn-script-location \
        --no-cache-dir \
        --no-compile \
        --user \
        ${USEPROXY} -r r_requirements.txt

# install further R packages
RUN set -eux; \
    [[ zzz${APTPROXY} != zzz ]] && export http_proxy="${APTPROXY}"; \
    command="install.packages(c("; \
    while read package; do \
        command=${command}'"'${package}'",'; \
    done <r_packages.txt; \
    command=$(echo ${command} | sed 's/,$//'); \
    command=${command}"),Ncpus=8)"; \
    r -e ${command}; \
    r -e 'IRkernel::installspec()'; \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD cd ${HOMEDIR} && \
    rmdir .ssh && \
    find /notebook/docker -mindepth 1 -maxdepth 1 -exec ln -s {} . \; && \
    [[ -x ./.rlabrc ]] && ./.rlabrc && \
    [[ -d /usr/local/cuda/bin ]] && export PATH=/usr/local/cuda/bin${PATH:+:${PATH}} && \
    [[ -d /usr/local/cuda/bin ]] && export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} && \
    cd ${FILES} && \
    SHELL=/bin/bash jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0 --LabApp.token=''

