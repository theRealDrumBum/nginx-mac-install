#!/bin/bash

PCRE=pcre-8.01
NGINX=nginx-0.8.42
NGINX_UPSTREAM_HASH=Nginx_upstream_hash-0.3
NGINX_UPLOAD=nginx_upload_module-2.0.12
NGINX_GEO_IP=Nginx-geoip-0.2
MODULES_DIR=/usr/lib/nginx/modules/
DOWNLOAD_DIR=/Users/matt/Downloads/

pcre_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.01.tar.gz
nginx_url=http://sysoev.ru/nginx/nginx-0.8.42.tar.gz
geo_ip=http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
geo_city=http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
geo_country=http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
function download()
{
    local url="$1"
    local filename=$(basename $url)
    local target="${DOWNLOAD_DIR}${filename}"
    
    if [ ! -f "$target" ]; then
        sudo curl -OL "${url}"
        mv $filename $target
    fi
   echo "$target"
}

function extract()
{
   local target="$1"
   local path="${target%/*}/"
   local file=$(basename $target)
   local outputfile=${file%.tar.gz}
   local dest=${path}${outputfile}

   if [ ! -d $dest ]; then
       tar -xvf "${target}"
   fi

   echo "$dest"
}

echo "Downloading required files"
pcre_tar=$(download $pcre_url)
nginx_tar=$(download $nginx_url)


pcre_dir=$(extract $pcre_tar)
nginx_dir=$(download $nginx_tar)




exit

# This is a modification of a script found at 
# http://kwimg.com/wp-content/uploads/2010/02/build-nginx.sh.txt
# More info:
# http://www.kevinworthington.com/nginx-mac-os-snow-leopard-2-minutes
# Download the current builds of nginx and pcre
cd ~/Downloads/

# PCRE
if [ -f ~/Downloads/$PCRE.tar.gz ];
then
    echo "~/Downloads/$PCRE.tar.gz Already Exists"
else
    echo "Downloading $PCRE"
    sudo curl -OL ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PCRE.tar.gz > ~/Downloads/$PCRE.tar.gz
    echo "Extracting resource"
    tar -xf $PCRE.tar.gz 
    echo "done"
fi

# NGINX
if [ -f ~/Downloads/$NGINX.tar.gz ];
then
    echo "~/Downloads/$NGINX.tar.gz Already Exists"
else
    echo "Downloading $NGINX"
    sudo curl -OL http://sysoev.ru/nginx/$NGINX.tar.gz > ~/Downloads/$NGINX.tar.gz
    echo "Extracting resource"
    tar -xf $NGINX.tar.gz
    echo "done"
fi

mkdir -p $MODULES_DIR
# Upstream Hash Module for NGINX
#if [ -d /usr/lib/nginx/modules/$NGINX_UPSTREAM_HASH ];
#then
#    echo "$NGINX_UPSTREAM_HASH already installed"
#else
#    echo "Downloading $NGINX_UPSTREAM_HASH"
#    sudo curl -OL http://wiki.nginx.org/images/7/78/$NGINX_UPSTREAM_HASH.tar.gz > ~/Downloads/$NGINX_UPSTREAM_HASH.tar.gz
#    echo "Extracting resource"
#    tar -xf ~/Downloads/$NGINX_UPSTREAM_HASH.tar.gz
#    mv ~/Downloads/$NGINX_UPSTREAM_HASH $MODULES_DIR
#    echo "done"
#fi

# Upload Module
if [ -d /usr/lib/nginx/modules/$NGINX_UPLOAD ];
then
    echo "$NGINX_UPLOAD already installed"
else
    echo "Downloading $NGINX_UPLOAD"
    sudo curl -OL http://www.grid.net.ru/nginx/download/$NGINX_UPLOAD.tar.gz > ~/Downloads/$NGINX_UPLOAD.tar.gz
    echo "Extracting resource"
    tar -xf ~/Downloads/$NGINX_UPLOAD.tar.gz
    mv ~/Downloads/$NGINX_UPLOAD $MODULES_DIR
    echo "done"
fi

# GEOIP Module
# http://wiki.nginx.org/NginxHttpGeoIPModule
if [ -d /usr/lib/nginx/modules/$NGINX_GEO_IP ];
then
    echo "$NGINX_UPLOAD already installed"
else
    echo "Downloading $NGINX_GEO_IP"
#   I think this is the wrong url. Found a different one to use
#    sudo curl -OL http://wiki.nginx.org/images/d/d6/$NGINX_GEO_IP.tar.gz > ~/Downloads/$NGINX_GEO_IP.tar.gz
    sudo curl -OL http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz > ~/Downloads/$NGINX_GEO_IP.tar.gz

    sudo curl -OL http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz > ~/Downloads/GeoLiteCity.dat.gz
    sudo curl -OL http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz > ~/Downloads/GeoIP.dat.gz
    echo "Extracting resource"
    tar -xf ~/Downloads/$NGINX_GEO_IP.tar.gz
    mv ~/Downloads/$NGINX_GEO_IP $MODULES_DIR
    echo "done"
fi



# Install dependencies
cd ~/Downloads/$PCRE
./configure --prefix=/usr/local
make
sudo make install

# Install NGINX
cd ~/Downloads/$NGINX
patch -p0 < $MODULES_DIR$NGINX_UPSTREAM_HASH
./configure \
  --prefix=/usr/local \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --pid-path=/var/run/nginx/nginx.pid \
  --lock-path=/var/lock/nginx/nginx.lock \
  --with-pcre \
  --with-debug \

  --add-module=$MODULES_DIR$NGINX_UPLOAD \
  --add-module=$MODULES_DIR$NGINX_GEO_IP \
  --http-log-path=/var/log/nginx/access.log \
  --http-client-body-temp-path=/var/tmp/nginx/client_body \
  --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
  --http-proxy-temp-path=/var/tmp/nginx/proxy
make
sudo make install

