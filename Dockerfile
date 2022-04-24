FROM python:3.9-bullseye AS pyrlab-build

ENV PORT=8880
ENV USER=notebook
ENV HOMEDIR=/notebook
ENV FILES=${HOMEDIR}/files

SHELL [ "/bin/bash", "-l", "-c" ]

# install various support packages, libraries and development tools
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            ed \
            less \
            locales \
            vim \
            tini \
            cmake \
            curl \
            wget \
            npm \
            nodejs \
            ca-certificates \
            build-essential \
            libzmq3-dev \
            libcurl4-openssl-dev \
            libssl-dev \
            libopenblas0-pthread \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.utf8; \
    update-locale LANG=en_US.UTF-8; \
    useradd -U ${USER} -m -d ${HOMEDIR} -s /bin/bash

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# install R distribution with development packages from r-project.org
RUN set -eux; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'; \
    echo 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/' >/etc/apt/sources.list.d/cran40.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            littler \
            r-cran-docopt \
            r-cran-littler \
            r-base \
            r-base-dev \
            r-base-core \
            r-recommended \
    ; \
    ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r; \
    ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r; \
    ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r; \
    ln -s /usr/lib/R/site-library/littler/examples/installDeps.r /usr/local/bin/installDeps.r; \
    ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r; \
    ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r; \
    chown -R ${USER}:${USER} /usr/local/lib/R; \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

USER ${USER}

WORKDIR ${HOMEDIR}

COPY --chown=${USER}:${USER} requirements.txt r_packages.txt ./

# install non-system Python modules and further R packages
RUN set -eux; \
    export PYTHONDONTWRITEBYTECODE=1; \
    pip install \
        --no-warn-script-location \
        --disable-pip-version-check \
        --no-cache-dir \
        --no-compile \
        --user \
        -r requirements.txt; \
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


# pyrlab slim runtime
FROM python:3.9-slim-bullseye AS pyrlab-slim

ENV PORT=8888
ENV USER=notebook                                                                                                                                                                    
ENV HOMEDIR=/notebook
ENV FILES=${HOMEDIR}/files

SHELL [ "/bin/bash", "-l", "-c" ]

# install diverse Debian support packages, libraries
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            gnupg \
            xz-utils \
            ed \
            locales \
            tini \
            npm \
            nodejs \
            ca-certificates \
            libzmq5 \
            libopenblas0-pthread \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.utf8; \
    update-locale LANG=en_US.UTF-8; \
    useradd -U ${USER} -m -d ${HOMEDIR} -s /bin/bash

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# install R distribution from r-project.org
RUN set -eux; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'; \
    echo 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/' >/etc/apt/sources.list.d/cran40.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            r-base \
            r-base-core \
            r-recommended \
    ; \
    chown -R ${USER}:${USER} /usr/local/lib/R; \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

COPY --from=pyrlab-build ${HOMEDIR} ${HOMEDIR}

COPY --from=pyrlab-build /usr/local/lib/R /usr/local/lib/R

USER ${USER}

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD cd ${HOMEDIR} && cd ${FILES} && jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0


# pyrlab with latex support
FROM pyrlab-slim AS pyrlab-latex

ENV PORT=8889
ENV USER=notebook                                                                                                                                                                    
ENV HOMEDIR=/notebook
ENV FILES=${HOMEDIR}/files

SHELL [ "/bin/bash", "-l", "-c" ]

USER root

# install LaTeX support
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
            pandoc \
            pandoc-data \
            python3-pandocfilters \
            fonts-texgyre \
            texlive-xetex \
            texlive-fonts-recommended \
            texlive-plain-generic \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

USER ${USER}

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD cd ${HOMEDIR} && cd ${FILES} && jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0

