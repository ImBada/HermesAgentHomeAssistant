# Hermes Agent Home Assistant Add-on

Home Assistant add-on repository for running [Hermes Agent](https://github.com/NousResearch/hermes-agent) as a supervised Home Assistant app.

The add-on wraps the official `nousresearch/hermes-agent` container and configures Hermes' built-in Home Assistant gateway. It can listen to selected Home Assistant state changes, let Hermes react to them, and send replies back as Home Assistant persistent notifications.

The add-on layout and user experience are modeled after [OpenClawHomeAssistant](https://github.com/techartdev/OpenClawHomeAssistant): persistent `/config` storage, Home Assistant Ingress landing page, embedded terminal, and dashboard access from the add-on page.

## Install

1. In Home Assistant, open **Settings > Add-ons > Add-on Store**.
2. Open the three-dot menu, choose **Repositories**, and add:

   `https://github.com/ImBada/HermesAgentHomeAssistant`

3. Install **Hermes Agent**.
4. Configure at least one LLM provider key, then start the add-on.

## Notes

- By default the add-on uses Home Assistant's Supervisor API token, so you do not need to create a Long-Lived Access Token.
- The add-on stores Hermes data under `/config/.hermes`, which is preserved by Home Assistant backups.
- The image is large because it uses the official Hermes Agent image with browser automation and messaging dependencies included.
