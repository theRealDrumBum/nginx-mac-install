#!/bin/bash

MODULES_DIR=/usr/lib/nginx/modules/
DOWNLOAD_DIR=~/Downloads/

pcre_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.01.tar.gz
nginx_url=http://sysoev.ru/nginx/nginx-0.7.67.tar.gz
nginx_upstream=
nginx_upload=http://www.grid.net.ru/nginx/download/nginx_upload_module-2.0.12.tar.gz
geo_ip=http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
geo_city=http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
geo_country=http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz

function download()
{
    local url="$1"
    local filename=$(basename $url)
    local target="${DOWNLOAD_DIR}${filename}"
    
    if [ ! -f $target ]; then
        sudo curl -OL $url > $target
    fi
    echo $target
}

function extract()
{
   local target="$1"
   local file=$(basename $target)
   local outputfile=${file%.tar*}
   if [ ! -e $outputfile ]; then
       mkdir -p $DOWNLOAD_DIR$outputfile
       tar --extract --file=$target --strip-components=2 --directory=${outputfile/ /}
   fi

   echo $outputfile
}

#################################
# Move to the working directory
#################################
if [ ! -d $DOWNLOAD_DIR ]; then
    mkdir -p $DOWNLOAD_DIR
fi
pushd $DOWNLOAD_DIR


#################################
# Download Required Files
#################################
echo -----------------------------
echo "Downloading required files"
echo -----------------------------
echo "$pcre_url"
pcre_tar=$(download $pcre_url)
echo "$nginx_url"
nginx_tar=$(download $nginx_url)
echo "$geo_ip"
geo_ip_tar=$(download $geo_ip)
echo "$geo_city"
geo_city_tar=$(download $geo_city)
echo "$geo_country"
geo_country_tar=$(download $geo_country)
echo "$nginx_upload"
nginx_upload_tar=$(download $nginx_upload)
echo "$nginx_upstream"
nginx_upstream_tar=$(download $nginx_upstream_tar)

#################################
# Extract required files
#################################
echo -----------------------------
echo "Extracting downloaded files"
echo -----------------------------
echo $pcre_tar
pcre_dir=$(extract $pcre_tar)
echo $nginx_tar
nginx_dir=$(extract $nginx_tar)
echo $geo_ip_tar
geo_ip_dir=$(extract $geo_ip_tar)
echo $geo_city_tar
geo_city_dir=$(extract $geo_city_tar)
echo $geo_country_tar
geo_country_dir=$(extract $geo_country_tar)
echo $nginx_upload_tar
nginx_upload_dir=$(extract $nginx_upload_tar)
chmod -R a+x $nginx_upload_dir
echo $nginx_upstream_tar
#nginx_upstream_dir=$(extract $nginx_upstream_tar)

echo -----------------------------
echo "Configuring Dependencies"
echo -----------------------------
#pushd $pcre_dir
#./configure --prefix=/usr/local
#make
#sudo make install
#popd

#pushd $geo_ip_dir
#./configure
#make
#sudo make install
#popd

echo 
echo
echo $geo_ip_dir
pushd $nginx_dir
./configure \
    --prefix=/usr/local \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx/nginx.pid \
    --lock-path=/var/lock/nginx/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var.log.nginx.access.log \
    --http-client-body-temp-path=/var/tmp/nginx/client_body \
    --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
    --http-proxy-temp-path=/var/tmp/nginx/proxy \
    --with-http_geoip_module \
#--add-module=$DOWNLOAD_DIR$geo_ip_dir \
    --add-module=$DOWNLOAD_DIR$nginx_upload_dir        
make
sudo make install
popd
exit

# This is a modification of a script found at 
# http://kwimg.com/wp-content/uploads/2010/02/build-nginx.sh.txt
# More info:
# http://www.kevinworthington.com/nginx-mac-os-snow-leopard-2-minutes
