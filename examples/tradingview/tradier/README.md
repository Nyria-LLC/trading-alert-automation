# TradingView to Tradier

To automate TradingView alerts to Tradier, connect Tradier through its sign-in flow in Nyria, then add your webhook URL to a TradingView alert.

## Broker notes

Tradier offers a live brokerage account and a Sandbox account. The Sandbox is a paper account. Both connect through the Tradier sign-in or Sandbox credentials.

Tradier trades stocks and options only. No crypto.

The alert message itself is the same regardless of which broker you use. Nyria reads the action, ticker and direction from it and places the order through Tradier.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert setup

TradingView webhook alerts require a paid plan with two-factor authentication turned on.

For a `strategy()` script, create one "Order fills only" alert per ticker. For an `indicator()` script, create one alert per side per ticker.

Paste your Nyria webhook URL into the Notifications tab: `https://trades.nyria.io/webhooks/<your-token>`.

## Examples

Copy-paste alert messages tested against a Tradier bot:
[examples/tradingview/tradier](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/tradier)

## Full guide

[TradingView to Tradier: step-by-step setup](https://nyria.io/automate/tradingview-to-tradier)
