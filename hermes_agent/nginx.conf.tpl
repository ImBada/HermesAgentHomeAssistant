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
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
      proxy_buffering off;
    }

    # Hermes dashboard currently serves Vite-style absolute asset/API paths.
    # Proxy the common root-level paths so the dashboard still works behind
    # the /dashboard/ ingress entry point.
    location ^~ /assets/ {
      __DASHBOARD_BLOCK__
      proxy_pass http://127.0.0.1:9119;
      proxy_set_header Host $host;
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
