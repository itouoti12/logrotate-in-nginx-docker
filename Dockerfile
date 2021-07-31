FROM nginx:latest

# add proxy settings
#ENV http_proxy http://host:port/
#ENV https_proxy http://host:port/
#ENV HTTP_PROXY http://host:port/
#ENV HTTPS_PROXY http://host:port/

# copy to nginx settings
COPY ./default.conf /etc/nginx/conf.d/
COPY ./nginx.conf /etc/nginx/

RUN apt-get update

##### rsyslog settings #####
RUN apt -y install rsyslog
COPY ./conf/rsyslog/50-default.conf /etc/rsyslog.d/
RUN update-rc.d rsyslog enable

##### logrotate settings #####
RUN apt -y install logrotate
# nginxのlogrotate以外は動かさない
RUN rm /etc/cron.daily/passwd
RUN rm /etc/cron.daily/dpkg
RUN rm /etc/cron.daily/apt-compat
RUN rm /etc/cron.daily/exim4-base
# copy to logrotate settings
COPY ./conf/logrotate/nginx_rotate /etc/logrotate.d/nginx
COPY ./conf/logrotate/daily_crontab /etc/cron.d/
COPY ./conf/logrotate/status /var/lib/logrotate
RUN update-rc.d cron enable

CMD service cron start && touch /etc/crontab /etc/cron.d/* && service rsyslog start && nginx -g 'daemon off;'