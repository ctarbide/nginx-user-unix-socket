
daemon off;

worker_processes 2;

error_log PWD/var/error.log;
pid PWD/var/nginx.pid;

events {
    worker_connections 1024;
}

http {
    client_body_temp_path PWD/var/client-body 1;
    proxy_temp_path PWD/var/proxy 1;
    fastcgi_temp_path PWD/var/fastcgi 1;
    scgi_temp_path PWD/var/scgi 1;
    uwsgi_temp_path PWD/var/uwsgi 1;

    include PWD/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log PWD/var/access.log  main;

    sendfile on;
    keepalive_timeout 65;

    server {
        listen LISTEN default_server;
        server_name _;
        location / {
            index index.html;
            charset utf-8;
            root  PWD/html;
        }
        # just an example, cf. https://github.com/ctarbide/coolscripts
        location ^~ /test/ {
            location ~* \.(eot|ttf|woff|woff2|json|otf|svg)$ {
                add_header Access-Control-Allow-Origin *;
            }
            index 00index___.html;
            autoindex on;
            charset utf-8;
            alias HOME/Downloads/coolscripts/;
        }
        include customize.conf;
    }
}
