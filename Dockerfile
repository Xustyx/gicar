FROM  centos:6.6

RUN yum install httpd glibc libstdc++ ncurses perl unzip tar xz -y

ENV httpd /etc/httpd

RUN mkdir -p ${httpd}/CA/webagent

RUN curl -o ${httpd}/CA/webagent.tar.xz http://canigo.ctti.gencat.cat/related/cloud/fitxers-suport/webagent.tar.xz
RUN tar xfvJ ${httpd}/CA/webagent.tar.xz -C ${httpd}/CA/
RUN rm ${httpd}/CA/webagent.tar.xz

RUN curl -o ${httpd}/conf/config.zip http://canigo.ctti.gencat.cat/related/cloud/fitxers-suport/config.zip
RUN unzip  -o ${httpd}/conf/config.zip -d  ${httpd}/conf/
RUN rm ${httpd}/conf/config.zip

ENV NETE_WA_ROOT ${httpd}/CA/webagent
ENV NETE_WA_PATH ${NETE_WA_ROOT}/bin
ENV CAPKIHOME ${httpd}/CA/webagent/CAPKI
ENV LD_LIBRARY_PATH ${NETE_WA_ROOT}/bin:${NETE_WA_ROOT}/bin/thirdparty:${LD_LIBRARY_PATH}
ENV PATH ${NETE_WA_PATH}:${PATH}

RUN mv ${httpd}/conf/headers.cgi /var/www/cgi-bin/
RUN mv ${httpd}/conf/index.html /var/www/html/
RUN chmod 755 -R /var/www/cgi-bin/
RUN chmod 755 -R /var/www/html/

RUN echo "#!/bin/bash" > /entrypoint.sh
RUN echo "set -m" >> /entrypoint.sh
RUN echo "/usr/sbin/apachectl -D FOREGROUND &" >> /entrypoint.sh
#RUN echo "sleep 30" >> /entrypoint.sh
RUN echo "/etc/httpd/CA/webagent/bin/smreghost -i \$PS_IP -u \$GICARUSER -p \$GICARPWD -hn \$ContainerHostName -hc \$HCOGICAR -f /etc/httpd/conf/Smhost.conf -o" >> /entrypoint.sh
RUN echo "sed -i -- 's/\\\$AgentConfigDocker/'\"\$AgentConfigDocker\"'/g' /etc/httpd/conf/WebAgent.conf" >>  /entrypoint.sh
RUN echo "sed -i -- 's/\\\$AGENTNAME/'\"\$AGENTNAME\"'/g' /etc/httpd/conf/LocalConfigGicar.conf" >> /entrypoint.sh
RUN echo "chown apache:apache /etc/httpd/conf/Smhost.conf" >> /entrypoint.sh
RUN echo "fg" >> /entrypoint.sh

RUN chmod 755 /entrypoint.sh

#Copiem el fitxer wait-for-it
COPY wait-for-it.sh /
RUN chmod 755 /wait-for-it.sh

COPY httpd.conf {httpd}/conf/

CMD ["/entrypoint.sh"]
