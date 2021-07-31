#!/bin/sh

docker stop nginx-logrotate
docker rm nginx-logrotate
docker rmi nginx-logrotate

docker build -t nginx-logrotate .

# 引数でログをマウントするディレクトリを指定する
docker run -v $1:/var/log/nginx -p 3000:80 -e TZ=Asia/Tokyo -u root --name nginx-logrotate -d --restart always -it nginx-logrotate
