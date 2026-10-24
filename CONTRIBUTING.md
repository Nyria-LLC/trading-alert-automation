# Contributing

Fixes and new examples are welcome. Examples here follow the [Nyria docs](https://docs.nyria.io), which stay the source of truth for field names and behavior.

## Report a problem

Open an issue with the file path and what Nyria's [alert tester](https://nyria.io/tools/alert-tester) shows for it. Never paste a webhook URL or token. If one was posted by mistake, rotate the token on the strategy's Integration tab.

## Add or change an example

1. Put the file in the folder for its source: `examples/tradingview`, `examples/trendspider`, `examples/webhook` or `examples/discord-telegram`. One file holds one alert, or one clearly named set of alerts.
2. Paste the alert into the [alert tester](https://nyria.io/tools/alert-tester) with the right source and asset type. Fill TradingView placeholders such as `{{ticker}}` and TrendSpider variables such as `%alert_symbol%` with sample values first. The reading must be the one you describe.
3. List the file in the folder's `README.md` with one line saying what it reads as.
4. Alerts that are checked by script, one folder per source and broker, belong in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples).

## Keep it true

- Do not claim a feature Nyria lacks. An alert cannot set the order size, and Nyria attaches no stop or target.
- Options need an expiration that exists. Change the dates in an example to a current expiration.
- Say what an example does, not what it earns. No performance claims.
- Plain, short sentences. No marketing copy.

By contributing you agree that your work is released under the [MIT license](LICENSE).
