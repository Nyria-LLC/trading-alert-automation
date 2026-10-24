# TradingView to tastytrade

To automate TradingView alerts to tastytrade, connect tastytrade through its sign-in flow in Nyria, then add your webhook URL to a TradingView alert.

## Broker notes

tastytrade connects with your tastytrade account login. Live accounts only. There is no paper account through this connection.

Crypto is not available through tastytrade's API as of 29 June 2026.

The alert message itself is the same regardless of which broker you use. Nyria reads the action, ticker and direction from it and places the order through tastytrade.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert setup

TradingView webhook alerts require a paid plan with two-factor authentication turned on.

For a `strategy()` script, create one "Order fills only" alert per ticker. For an `indicator()` script, create one alert per side per ticker.

Paste your Nyria webhook URL into the Notifications tab: `https://trades.nyria.io/webhooks/<your-token>`.

## Examples

Copy-paste alert messages tested against a tastytrade bot:
[examples/tradingview/tastytrade](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/tastytrade)

## Full guide

[TradingView to tastytrade: step-by-step setup](https://nyria.io/automate/tradingview-to-tastytrade)
