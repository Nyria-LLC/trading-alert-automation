# TradingView to Alpaca

To automate TradingView alerts to Alpaca, add an Alpaca API key in Nyria, then add your webhook URL to a TradingView alert.

## Broker notes

Alpaca connects with an API key and secret, not a sign-in flow. Generate a key in your Alpaca dashboard and paste it into Nyria. Paper and live keys both work.

Alpaca trades stocks, options and crypto spot.

The alert message itself is the same regardless of which broker you use. Nyria reads the action, ticker and direction from it and places the order through Alpaca.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert setup

TradingView webhook alerts require a paid plan with two-factor authentication turned on.

For a `strategy()` script, create one "Order fills only" alert per ticker. For an `indicator()` script, create one alert per side per ticker.

Paste your Nyria webhook URL into the Notifications tab: `https://trades.nyria.io/webhooks/<your-token>`.

## Examples

Copy-paste alert messages tested against an Alpaca bot:
[examples/tradingview/alpaca](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/alpaca)

## Full guide

[TradingView to Alpaca: step-by-step setup](https://nyria.io/automate/tradingview-to-alpaca)
