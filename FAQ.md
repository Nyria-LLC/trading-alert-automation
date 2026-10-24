# FAQ

Short answers about turning alerts into broker orders. Each links to the longer nyria.io page.

## Can TradingView place orders by itself?

Not from an alert. TradingView's trading panel places orders you click, and an alert can notify you or call a webhook URL, but an alert never places an order on its own. To turn an alert into an order, point its webhook at something that reads it and sends the order to your broker. Nyria is that receiver for Charles Schwab, Tradier, tastytrade and Alpaca. More: [Trade directly from TradingView](https://nyria.io/guides/trade-directly-from-tradingview) and the [README](README.md#how-does-a-webhook-alert-become-an-order).

## How do I set up automated trades?

An automated trade has three parts: a signal that says what to trade, a receiver that turns it into an order, and a broker with an API that accepts the order. Set them up in that order, test on paper, then check every fill in the broker's own history. More: [How do I set up automated trades?](https://nyria.io/guides/how-to-set-up-automated-trading).

## Can I automate trading without coding?

Yes, for the trading side. Set an alert on a chart, paste a Nyria webhook URL into its notifications, and a bot places the order at your broker. The message can be plain text such as `SPY long entry`. Placing orders needs no code; writing the strategy logic is up to you. More: [TradingView auto trade without code](https://nyria.io/guides/tradingview-auto-trade-without-code) and [No-code trading bot](https://nyria.io/guides/no-code-trading-bot-stocks-options).

## Can I automate trading at Robinhood?

Not directly. Robinhood publishes no API for stocks and options, so no tool can place those orders in a Robinhood account. Its official Crypto Trading API covers crypto only. The honest choice is to automate at a broker with an API and keep Robinhood for everything else. More: [Robinhood automated trading](https://nyria.io/guides/robinhood-automated-trading).

## Can thinkorswim auto trade?

Only inside its own conditional orders. thinkScript builds studies, scans, strategies you can backtest and alerts, but an alert notifies you and a person still sends the order. To automate more, something outside thinkorswim has to read the signal and place the order in your Schwab account. More: [Automate thinkorswim trading](https://nyria.io/guides/thinkorswim-automated-trading) and [TradingView alerts to Schwab](https://nyria.io/automate/tradingview-to-schwab).

## Which brokers can alerts trade at?

Charles Schwab, Tradier, tastytrade, Alpaca and Nyria Paper, the free simulated broker. Interactive Brokers is not among them. Stocks, options up to 4 legs and, at Alpaca and on Nyria Paper, crypto spot. More: [Which brokers TradingView alerts can trade](https://nyria.io/guides/which-brokers-tradingview-alerts-can-trade).

## How do I automate Alpaca from alerts?

Generate an API key in Alpaca's dashboard (paper or live), paste it into Nyria, create a strategy for your alert source and deploy a bot on the account. Alpaca trades stocks in whole shares, options up to 4 legs and crypto spot. More: [Alpaca automated trading](https://nyria.io/guides/alpaca-automated-trading) and [TradingView alerts to Alpaca](https://nyria.io/automate/tradingview-to-alpaca).

## How do I automate tastytrade from alerts?

Connect tastytrade through its own sign-in, create a strategy for your alert source and deploy a bot on the account. tastytrade connects live accounts only, so test on Nyria Paper first. Crypto has been disabled through tastytrade's API since 29 June 2026. More: [tastytrade automated trading](https://nyria.io/guides/tastytrade-automated-trading).

## Can I send alerts from my own Python script?

Yes. `POST` a JSON body such as `{"ticker": "AAPL", "action": "OPEN", "direction": "LONG"}` to the strategy's webhook URL with `requests`. Your script holds no broker keys. Check the `status` in the answer, because a `200` can also mean rejected or duplicate. More: [Send alerts from your Python script to your broker](https://nyria.io/guides/python-webhook-alerts-to-broker).

## Can I automate Discord or Telegram trade calls?

Yes, from a server or chat you run. Nyria reads one Discord channel or one Telegram group or channel, works out the ticker, side and action from the message, and each bot places the order in its own account. Messages are read as written, so `BTO SPY 12/18 780C` and `Close SPY long` both work. More: [Discord alerts to broker orders](https://nyria.io/guides/discord-alerts-to-broker) and [Telegram alerts to broker orders](https://nyria.io/guides/telegram-alerts-to-broker).
