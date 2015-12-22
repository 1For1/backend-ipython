FROM oneforone/backend-base:latest
MAINTAINER 1For1
LABEL version "1.0.0"

# /root/.ipython/profile_default
RUN apt-get -y install libxft-dev libpng12-dev\
    && pip install ipython[all] \
    && pip install ipywidgets matplotlib \
    && ipython profile create

EXPOSE 8888

VOLUME /app

CMD ["ipython", "notebook", "--ip=0.0.0.0"]