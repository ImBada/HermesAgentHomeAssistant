# Hermes Agent

Hermes Agent runs as a Home Assistant app/add-on and connects to Home Assistant through Hermes' built-in Home Assistant gateway adapter.

The add-on keeps all user data in `/config/.hermes`, exposes a small Home Assistant Ingress page, starts an optional Hermes dashboard, and embeds an optional web terminal for setup and maintenance.

## Required setup

Configure models and provider credentials inside Hermes, not in the Home Assistant add-on options. Open the add-on terminal or dashboard and run:

```sh
hermes setup
hermes model
hermes config edit
```

The add-on only manages container, Ingress, terminal/dashboard, and Home Assistant connection settings. Existing Hermes `.env`, `config.yaml`, and `SOUL.md` settings under `/config/.hermes` are preserved across add-on restarts.

## Ingress UI

Open the add-on from the Home Assistant sidebar or add-on page. The page provides:

- **Hermes Dashboard** at `/dashboard/`
- **Terminal** at `/terminal/`
- Basic runtime and disk usage status

The terminal runs inside the add-on container. Use it for commands like:

```sh
hermes status
hermes tools
hermes logs
```

The terminal opens in `/config/.hermes/workspace` with the Hermes virtualenv on `PATH`, so the `hermes` command should be available immediately.

When the add-on dashboard is enabled, Hermes runs on its default internal port `9119` and nginx exposes it through Home Assistant Ingress at `/dashboard/`.

## Home Assistant access

`use_supervisor_api` is enabled by default. In this mode the add-on uses Home Assistant's Supervisor-provided token. The add-on starts a tiny localhost compatibility proxy so Hermes can use its normal `/api/...` paths while Home Assistant receives requests through the Supervisor Core REST and WebSocket proxies.

The add-on does not use host networking. Dashboard, terminal, and Ingress ports are private to the add-on container, which avoids conflicts with other HAOS services.

If you turn `use_supervisor_api` off, set:

- `hass_url`: your Home Assistant URL, for example `http://homeassistant:8123`
- `hass_token`: a Home Assistant Long-Lived Access Token

## Event filters

Hermes only receives Home Assistant events matching the configured filters.

- `watch_domains`: entity domains to monitor, such as `light` or `climate`; `binary_sensor` is not watched by default because activity, presence, and motion sensors can be noisy
- `watch_entities`: exact entity IDs to monitor
- `ignore_entities`: exact entity IDs to suppress
- `watch_all`: forward all state changes; this is noisy and usually not recommended
- `cooldown_seconds`: minimum seconds between events for the same entity

## Notifications

`ha_notification_mode` controls Home Assistant persistent notifications created by Hermes:

- `errors_only` forwards only messages that look like errors or failures. This is the default.
- `all` forwards every Hermes response as a Home Assistant notification.
- `off` suppresses all Hermes persistent notifications.

This filtering is applied by the add-on's Supervisor API compatibility proxy. It does not affect Hermes' ability to read Home Assistant state changes or call Home Assistant services.

## Tool access

The default Home Assistant toolsets include smart-home controls, web tools, skills, memory, session search, tasks, and cron jobs. Terminal and file tools are not enabled by default for Home Assistant events. Add `terminal` or `file` to `toolsets` only if you want Hermes to execute commands or edit files inside the add-on container.

## Data

Hermes data is stored in `/config/.hermes` and is included in Home Assistant backups, except for cache paths listed in the add-on backup exclusions.
