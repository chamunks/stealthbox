FROM phusion/baseimage:0.9.16

MAINTAINER Rémi Alvergnat <toilal.dev@gmail.com>

CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

ADD pydio/bootstrap.json /home/box/pydio/plugins/boot.conf/
ADD pydio/pydio.db /home/box/pydio/plugins/conf.sql/
ADD pydio/cache/* /home/box/pydio/cache/
ADD sickrage/* /home/box/sickrage/
ADD couchpotato/* /home/box/couchpotato/
ADD headphones/* /home/box/headphones/
ADD deluge/* /home/box/deluge/
ADD nginx/* /etc/nginx/sites-available/
ADD stealthbox /opt/stealthbox/
ADD my_init.d/* /etc/my_init.d/
ADD services/ /etc/service/
ADD bin /home/box/bin

RUN rm -f /etc/apt/apt.conf.d/docker-gzip-indexes \
  add-apt-repository ppa:deluge-team/ppa \
  apt-get update -y \
  apt-get install -y wget git sqlite3 pwgen libcrack2 expect python-pip \
  pip install virtualenv \
  apt-get install -y php5 php5-fpm php5-gd php5-cli php5-mcrypt php5-sqlite \
  nginx \
  deluged deluge-web \
  git clone -b master https://github.com/Flexget/Flexget.git /opt/flexget \
  pip install --upgrade six \
  cd /opt/flexget && python /opt/flexget/bootstrap.py --system-site-packages \
  mkdir -p /opt/pydio \
  wget -qO- http://sourceforge.net/projects/ajaxplorer/files/pydio/stable-channel/6.0.5/pydio-core-6.0.5.tar.gz | tar xvz --strip-components=1 -C /opt/pydio \
  apt-get install -y python-cheetah \
  mkdir -p sickrage \
  git clone https://github.com/SiCKRAGETV/SickRage.git /opt/sickrage \
  mkdir -p couchpotato \
  git clone https://github.com/RuudBurger/CouchPotatoServer.git /opt/couchpotato \
  mkdir -p headphones \
  git clone https://github.com/rembo10/headphones /opt/headphones \
  useradd -ms /bin/bash box \
  echo 'box:box12345' | chpasswd \
  sed -ri 's/^[;#]?(file_uploads\s*=\s*).*/\1On/' /etc/php5/fpm/php.ini \
  sed -ri 's/^[;#]?(post_max_size\s*=\s*).*/\1512G/' /etc/php5/fpm/php.ini \
  sed -ri 's/^[;#]?(upload_max_filesize\s*=\s*).*/\1512G/' /etc/php5/fpm/php.ini \
  sed -ri 's/^[;#]?(max_file_uploads\s*=\s*).*/\120000/' /etc/php5/fpm/php.ini \
  sed -ri 's/^[;#]?(output_buffering\s*=\s*).*/\1Off/' /etc/php5/fpm/php.ini \
  php5enmod mcrypt \
  sed -ri 's/^[;#]?(user\s*=\s*).*/\1box/' /etc/php5/fpm/pool.d/www.conf \
  sed -ri 's/^[;#]?(group\s*=\s*).*/\1box/' /etc/php5/fpm/pool.d/www.conf \
  sed -ri 's/^[;#]?(listen.owner\s*=\s*).*/\1box/' /etc/php5/fpm/pool.d/www.conf \
  sed -ri 's/^[;#]?(listen.group\s*=\s*).*/\1box/' /etc/php5/fpm/pool.d/www.conf \
  mkdir -p /home/box/flexget \
  flexget/* /home/box/flexget/ \
  sed -ri 's/^(define\("AJXP_DATA_PATH",\s*).*(\);)/\1"\/home\/box\/pydio"\2/' /opt/pydio/conf/bootstrap_context.php \
  mv /opt/pydio/data /home/box/pydio \
  ln -s /home/box/pydio /opt/pydio/data \
  mkdir -p /home/box/sickrage \
  mkdir -p /home/box/sickrage/data \
  mkdir -p /home/box/couchpotato \
  mkdir -p /home/box/couchpotato/custom_plugins \
  git clone https://github.com/djoole/couchpotato.provider.t411 /home/box/couchpotato/custom_plugins/t411 \
  mkdir -p /home/box/headphones \
  mkdir -p /home/box/deluge/autoadd \
  mkdir -p /home/box/deluge/downloads \
  mkdir -p /home/box/deluge/tmp \
  mkdir -p /home/box/deluge/torrents \
  mkdir -p /home/box/nginx \
  rm /etc/nginx/sites-enabled/default \
  ln -s /etc/nginx/sites-available/stealthbox /etc/nginx/sites-enabled/stealthbox \
  sed -ri 's/^[;#]?(user\s*).*;/\1box;/' /etc/nginx/nginx.conf \
  ln -s /opt/stealthbox/boxpasswd.sh /usr/bin/boxpasswd \
  pip install https://github.com/joh/when-changed/archive/master.zip \
  mkdir -p /home/box/logs \
  /opt/stealthbox/docker/lsb_compat.sh \
  /opt/stealthbox/docker/runit_logs.sh \
  mkdir /home/box/etc \
  cp -R /etc/ssh /etc/ssh.default \
  mv /etc/ssh /home/box/etc \
  ln -s /home/box/etc/ssh /etc/ssh \
  chown -R box:box /home/box \
  chown -R box:box /opt/* \
  sed -ri 's/^(password\s+.*?\s+pam_unix.so\s+).*/\1sha512 minlen=0/' /etc/pam.d/common-password \
  rm -f /etc/service/sshd/down \
  sudo apt-get autoclean \
  sudo apt-get clean \
  sudo apt-get autoremove \
  rm -rf /tmp/*

# Mount home volume and expose required ports
VOLUME /home/box
VOLUME /etc/stealthbox/ssl

EXPOSE 443 80 22 6881
