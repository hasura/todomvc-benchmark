# Setting up nginx with SSL certificates

* Install nginx
```shell
$ sudo apt-get install nginx
```

* Configure nginx to proxy pass to your gunicorn webserver. The gunicorn server
  is listening on port 8000. Modify the ``/etc/nginx/sites-enabled/default``
file to have the following:

```nginx
server {
    listen 80;

    server_name rails.benchmark.hasura.io;

    access_log            /var/log/nginx/todomvc_rails.access.log;

    location / {

      proxy_set_header    Host $host;
      proxy_set_header    X-Real-IP $remote_addr;
      proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header    X-Forwarded-Proto $scheme;

      proxy_pass          http://localhost:8000;
      proxy_read_timeout  90;
    }
  }
```

* Then obtain your SSL certificates, and put the certificate and the
  certificate key inside the ``/etc/nginx``. Modify the nginx conf to look like
the following. Below we have called it ``cert.crt`` and ``cert.key``. Update
these with the actual filenames you are using.

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {

    listen 443;
    server_name rails.benchmark.hasura.io;

    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;

    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    access_log            /var/log/nginx/todomvc_rails.access.log;

    location / {

      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      proxy_pass          http://localhost:8000;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:8000 https://rails.benchmark.hasura.io;
    }
  }
```
