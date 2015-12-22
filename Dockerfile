FROM oneforone/backend-base:latest
MAINTAINER 1For1
LABEL version "1.0.0"

# Install TINI
RUN apt-get install -y curl
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# /root/.ipython/profile_default
RUN apt-get -y install libxft-dev libpng12-dev libzmq3-dev libsqlite3-dev sqlite3 zlib1g-dev\
    && pip install ipython[all] \
    && pip install ipywidgets matplotlib \
    && ipython profile create

EXPOSE 8888

VOLUME /app

ADD notebook.sh /

ENTRYPOINT ["tini", "--"]
CMD ["/notebook.sh"]
