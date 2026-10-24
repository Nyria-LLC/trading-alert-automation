# TradingView to Charles Schwab

To automate TradingView alerts to Charles Schwab, connect Schwab through its sign-in flow in Nyria, then add your webhook URL to a TradingView alert.

## Broker notes

Schwab access expires every 7 days. Reconnect from the Nyria broker page before the session ends or bots stop placing orders.

Schwab trades stocks and options only. No crypto.

Stock orders are in whole shares. Options support up to 4 legs on one expiration.

The alert message itself is the same regardless of which broker you use. Nyria reads the action, ticker and direction from it and places the order through Schwab.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert setup

TradingView webhook alerts require a paid plan with two-factor authentication turned on.

For a `strategy()` script, create one "Order fills only" alert per ticker. For an `indicator()` script, create one alert per side per ticker.

Paste your Nyria webhook URL into the Notifications tab: `https://trades.nyria.io/webhooks/<your-token>`.

## Examples

Copy-paste alert messages tested against a Schwab bot:
[examples/tradingview/schwab](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/schwab)

## Full guide

[TradingView to Schwab: step-by-step setup](https://nyria.io/automate/tradingview-to-schwab)
