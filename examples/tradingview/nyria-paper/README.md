# TradingView to Nyria Paper

To automate TradingView alerts to Nyria Paper, create a paper bot in Nyria without connecting any broker, then add your webhook URL to a TradingView alert.

## Broker notes

Nyria Paper is a free simulated broker built into Nyria. No external account or credentials are needed. You can run up to 10 paper bots.

Paper bots trade stocks, options and crypto spot in simulation.

The alert message itself is the same regardless of which broker you use. Nyria reads the action, ticker and direction from it and simulates the order in the paper account.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert setup

TradingView webhook alerts require a paid plan with two-factor authentication turned on.

For a `strategy()` script, create one "Order fills only" alert per ticker. For an `indicator()` script, create one alert per side per ticker.

Paste your Nyria webhook URL into the Notifications tab: `https://trades.nyria.io/webhooks/<your-token>`.

Start with a paper bot to test your alert messages before connecting a live broker.

## Examples

Copy-paste alert messages tested against a Nyria Paper bot:
[examples/tradingview/nyria-paper](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/nyria-paper)

## Full guide

[TradingView to paper account: step-by-step setup](https://nyria.io/automate/tradingview-to-paper)
