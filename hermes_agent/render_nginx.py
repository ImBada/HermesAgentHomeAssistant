#!/usr/bin/env python3
import os
from pathlib import Path


def main():
    nginx_tpl_path = Path(os.environ.get("NGINX_TEMPLATE", "/etc/nginx/nginx.conf.tpl"))
    landing_tpl_path = Path(os.environ.get("LANDING_TEMPLATE", "/etc/nginx/landing.html.tpl"))
    nginx_out_path = Path(os.environ.get("NGINX_OUTPUT", "/etc/nginx/nginx.conf"))
    dashboard_proxy_out_path = Path(os.environ.get("DASHBOARD_PROXY_OUTPUT", "/etc/nginx/dashboard_proxy.conf"))
    landing_out_dir = Path(os.environ.get("LANDING_OUTPUT_DIR", "/etc/nginx/html"))
    mime_types_path = os.environ.get("NGINX_MIME_TYPES", "/etc/nginx/mime.types")

    terminal_port = os.environ.get("TERMINAL_PORT", "7681")
    dashboard_port = os.environ.get("DASHBOARD_PORT", "9118")
    enable_terminal = os.environ.get("ENABLE_TERMINAL", "true")
    enable_dashboard = os.environ.get("ENABLE_DASHBOARD", "true")
    nginx_log_level = os.environ.get("NGINX_LOG_LEVEL", "minimal")

    disk_total = os.environ.get("DISK_TOTAL", "")
    disk_used = os.environ.get("DISK_USED", "")
    disk_avail = os.environ.get("DISK_AVAIL", "")
    disk_pct = os.environ.get("DISK_PCT", "")

    access_log = (
        "map $http_user_agent $loggable {\n"
        "    ~HomeAssistant 0;\n"
        "    default 1;\n"
        "  }\n"
        "  access_log /dev/stdout combined if=$loggable;"
        if nginx_log_level == "minimal"
        else "access_log /dev/stdout;"
    )

    conf = nginx_tpl_path.read_text(encoding="utf-8")
    conf = conf.replace("__NGINX_ACCESS_LOG__", access_log)
    conf = conf.replace("__NGINX_MIME_TYPES__", mime_types_path)
    conf = conf.replace("__TERMINAL_PORT__", terminal_port)
    conf = conf.replace("__DASHBOARD_PORT__", dashboard_port)
    conf = conf.replace("__DASHBOARD_PROXY_INCLUDE__", str(dashboard_proxy_out_path))
    conf = conf.replace("__TERMINAL_BLOCK__", "" if enable_terminal == "true" else "return 404;")
    conf = conf.replace("__DASHBOARD_BLOCK__", "" if enable_dashboard == "true" else "return 404;")
    nginx_out_path.parent.mkdir(parents=True, exist_ok=True)
    nginx_out_path.write_text(conf, encoding="utf-8")

    dashboard_proxy = f"""proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
proxy_set_header X-Forwarded-Host $http_host;
proxy_set_header X-Forwarded-Prefix /dashboard;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $remote_addr;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header Accept-Encoding "";
proxy_redirect http://127.0.0.1:{dashboard_port}/ ./;
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
proxy_buffering off;
sub_filter_once off;
sub_filter_types text/css application/javascript text/javascript application/json;
sub_filter 'http://127.0.0.1:{dashboard_port}/' './';
sub_filter 'http://127.0.0.1:{dashboard_port}' '.';
sub_filter 'ws://127.0.0.1:{dashboard_port}/ws' './ws';
sub_filter 'ws://127.0.0.1:{dashboard_port}' './ws';
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
"""
    dashboard_proxy_out_path.parent.mkdir(parents=True, exist_ok=True)
    dashboard_proxy_out_path.write_text(dashboard_proxy, encoding="utf-8")

    landing = landing_tpl_path.read_text(encoding="utf-8")
    terminal_status = "Enabled" if enable_terminal == "true" else "Disabled"
    dashboard_status = "Enabled" if enable_dashboard == "true" else "Disabled"
    replacements = {
        "__ENABLE_TERMINAL__": enable_terminal,
        "__ENABLE_DASHBOARD__": enable_dashboard,
        "__TERMINAL_STATUS__": terminal_status,
        "__DASHBOARD_STATUS__": dashboard_status,
        "__DASHBOARD_PORT__": dashboard_port,
        "__DISK_TOTAL__": disk_total,
        "__DISK_USED__": disk_used,
        "__DISK_AVAIL__": disk_avail,
        "__DISK_PCT__": disk_pct,
    }
    for key, value in replacements.items():
        landing = landing.replace(key, value)

    landing_out_dir.mkdir(parents=True, exist_ok=True)
    out_file = landing_out_dir / "index.html"
    out_file.write_text(landing, encoding="utf-8")
    landing_out_dir.chmod(0o755)
    out_file.chmod(0o644)


if __name__ == "__main__":
    main()
