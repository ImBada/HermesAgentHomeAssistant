worker_processes 1;
error_log /dev/stderr notice;

events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  __NGINX_ACCESS_LOG__
  error_log /dev/stderr notice;
  sendfile on;
  keepalive_timeout 65;

  server {
    listen 48099;

    location = / {
      root /etc/nginx/html;
      default_type text/html;
      try_files /index.html =404;
    }

    location = /terminal {
      return 302 /terminal/;
    }

    location ^~ /terminal/ {
      __TERMINAL_BLOCK__
      proxy_pass http://127.0.0.1:__TERMINAL_PORT__;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
    }

    location = /dashboard {
      return 302 /dashboard/;
    }

    location ^~ /dashboard/ {
      __DASHBOARD_BLOCK__
      rewrite ^/dashboard/(.*)$ /$1 break;
      proxy_pass http://127.0.0.1:9119;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Prefix /dashboard;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Accept-Encoding "";
      proxy_redirect http://127.0.0.1:9119/ /dashboard/;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
      proxy_buffering off;
      sub_filter_once off;
      sub_filter_types text/css application/javascript text/javascript application/json;
      sub_filter 'href="/' 'href="./';
      sub_filter 'src="/' 'src="./';
      sub_filter 'action="/' 'action="./';
      sub_filter 'url(/' 'url(./';
      sub_filter '"/assets/' '"./assets/';
      sub_filter "'/assets/" "'./assets/";
      sub_filter '"/api/' '"./api/';
      sub_filter "'/api/" "'./api/";
      sub_filter '"/ws' '"./ws';
      sub_filter "'/ws" "'./ws";
    }

    # Fallbacks for direct asset/API requests from the dashboard.
    location ^~ /assets/ {
      __DASHBOARD_BLOCK__
      proxy_pass http://127.0.0.1:9119;
      proxy_set_header Host $host;
      proxy_set_header Accept-Encoding "";
      sub_filter_once off;
      sub_filter_types text/css application/javascript text/javascript application/json;
      sub_filter '"/assets/' '"./assets/';
      sub_filter "'/assets/" "'./assets/";
      sub_filter '"/api/' '"./api/';
      sub_filter "'/api/" "'./api/";
      sub_filter '"/ws' '"./ws';
      sub_filter "'/ws" "'./ws";
    }

    location ^~ /api/ {
      __DASHBOARD_BLOCK__
      proxy_pass http://127.0.0.1:9119;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host $host;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
      proxy_buffering off;
    }

    location = /favicon.ico {
      __DASHBOARD_BLOCK__
      proxy_pass http://127.0.0.1:9119;
      proxy_set_header Host $host;
    }

    location / {
      return 404;
    }
  }
}
