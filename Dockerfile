FROM mattrayner/lamp:latest-1604
RUN apt-get -y remove php*-snmp
MAINTAINER Martin Sarsale <martin@properati.com>


ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV DATAWRAPPER_ROOT_DIRECTORY /app2/
ENV DATAWRAPPER_PLUGINS_DIRECTORY $DATAWRAPPER_ROOT_DIRECTORY/plugins
ENV DATAWRAPPER_WWW_DIRECTORY $DATAWRAPPER_ROOT_DIRECTORY/www
ENV DATAWRAPPER_WWW_CHART_DIRECTORY $DATAWRAPPER_ROOT_DIRECTORY/charts/static

# enable mod_rewrite
RUN a2enmod rewrite

ADD templates/ /tmp/templates
ADD scripts/startup_generator.sh /tmp/startup_generator.sh

#RUN chmod +x /tmp/startup_generator.sh && \
#    sed -i.bak "s|touch /mysql-configured|touch /mysql-configured\n/tmp/startup_generator.sh|g" start.sh

RUN apt-get -y autoremove && \
    apt-get clean
RUN apt-get update -yq --fix-missing && \
    apt-get install -y software-properties-common \
                       python-software-properties \
                       build-essential \
                       nano
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
 
RUN apt-get update -yq && \
    apt-get install -yqf zip curl git tree python-pip nodejs && \
    apt-get -y autoremove && \
    apt-get clean && \
    pip install envtpl

WORKDIR $DATAWRAPPER_ROOT_DIRECTORY
RUN curl -s -L https://github.com/datawrapper/datawrapper/archive/v1.10.1.tar.gz | tar xz --strip-components=1
RUN git clone https://github.com/properati/publish-embed.git $DATAWRAPPER_PLUGINS_DIRECTORY/publish-embed
RUN git clone https://github.com/properati/datawrapper-plugin-publish-rsync.git $DATAWRAPPER_PLUGINS_DIRECTORY/publish-rsync
RUN pwd
RUN ls
RUN touch X
RUN ls



# php config is generated at startup time to provide customizable sql credentials and settings.

RUN curl  -sS https://getcomposer.org/installer | php
RUN ls
RUN php composer.phar install

RUN chown -R www-data:www-data $DATAWRAPPER_ROOT_DIRECTORY/charts
RUN chown -R www-data:www-data $DATAWRAPPER_ROOT_DIRECTORY/tmp

#do the stuff in the makefile, particularly related to grunt and stuffs.
#RUN npm install
#RUN cd dw.js && npm install
#RUN make clean && make all

#fuck the grunt stuff, just pretend we minified, handle this later.
RUN cp www/static/js/dw-2.0.js www/static/js/dw-2.0.min.js

# final installation steps require sql to be present and running, this is done in startup.sh, 
# which is generated by startup_generator.sh
CMD ["/run.sh"]

