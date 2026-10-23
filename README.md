# Trading alert automation

Turn TradingView, TrendSpider, Discord and Telegram alerts into broker orders: alert message examples, Pine Script templates and webhook formats.

This repository collects working examples for one job: getting an alert you already produce to place an order in a brokerage account, without writing a broker integration yourself. Everything here is checked against the [Nyria docs](https://docs.nyria.io), which stay the source of truth for field names and behavior.

## What alert-to-order automation is

A trading alert is a message: a TradingView alert firing, a caller posting `SPY long entry` in a Discord channel, a script of your own sending an HTTP request. On its own it only tells you something happened. Alert-to-order automation adds the missing steps in the middle:

1. **Receive** the alert from where it is produced.
2. **Read** it: work out the ticker, the direction and the action (open or close).
3. **Decide the order** from settings you chose in advance: order type, size, and for options the contract.
4. **Send the order** to your broker account and keep a log of what happened.

The parts you write are the alert and its wording. The parts you configure once are the rules that turn it into an order.

## Supported alert sources

| Source | How the alert arrives | Message format |
|---|---|---|
| TradingView | Webhook URL in the alert's Notifications tab | Plain text or JSON |
| TrendSpider | Webhook from an Alert or a Strategy Bot | JSON |
| Discord | Nyria reads one channel of a server you run | Plain text, embeds |
| Telegram | Nyria reads one group or channel you run | Plain text |
| Your own code | HTTPS `POST` to the webhook URL | Plain text or JSON |

A strategy reads alerts from one source. TradingView webhooks need a paid TradingView plan with two-factor authentication turned on.

## How a webhook alert becomes an order

```text
 alert source                webhook                      bot                       broker
 ------------      ------------------------      ---------------------      ---------------------
 TradingView   -->  POST trades.nyria.io     -->  reads ticker, side,  -->  order placed in your
 TrendSpider        /webhooks/<your-token>        and action; sizes it       account (Charles Schwab,
 your script                                      from the bot's budget      Tradier, tastytrade,
                                                  per entry                  Alpaca) or Nyria Paper
```

- The token at the end of the URL is the only authentication. Treat the URL like a password and rotate the token if it leaks.
- The alert does not set the size of an entry. Size comes from the bot's settings, so a `quantity` key on an entry alert is ignored.
- Duplicate bodies are dropped: the same body again within 30 seconds, or within 5 minutes with no other alert in between, answers `200` with `{"status": "duplicate"}`. To scale into a position, make each body different, for example with a unique `metadata.message_id`.
- A `200` means the alert was read and handed to the bots. It does not mean the broker filled anything; the bot's log shows what the broker did.
- Rate limit per webhook: 10 alerts at once, then 1 a second. Over that, the webhook answers `429` with a `Retry-After` header.

## Alert formats Nyria reads

There is no fixed template. A ticker, a direction and an action are enough.

| Format | Example | Where it is used |
|---|---|---|
| Plain text | `long SPY here`, `SPY long entry`, `Close short BTC` | Every source |
| Plain text, option | `BTO SPY 12/18 780C`, `SPY 780C buy to open` | Discord, Telegram, TradingView, custom webhook |
| Minimal JSON | `{"ticker": "SPY", "action": "buy"}` | TradingView, TrendSpider, custom webhook |
| TradingView default strategy message | `{"action": "{{strategy.order.action}}", "instrument": "{{ticker}}", "marketPosition": "{{strategy.market_position}}", "prevMarketPosition": "{{strategy.prev_market_position}}", "contracts": "{{strategy.order.contracts}}", "price": {{close}}}` | TradingView strategies |
| Explicit JSON | `{"instrument": "SPY", "action": "OPEN", "direction": "LONG", "order_type": "limit", "price": 771.20}` | Custom webhook, TradingView indicators |
| JSON with option legs | `{"ticker": "SPY", "action": "OPEN", "direction": "LONG", "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-11-20"}]}` | Strategies set to "Provided in alert" |
| Discord embed | Title, description and fields are read in that order | Discord |

How `buy` and `sell` are read depends on the strategy. On a long-only strategy, `buy` opens a long and `sell` closes it. On a strategy that trades both sides, `buy` covers an open short and otherwise opens a long, and `sell` closes an open long and otherwise opens a short. To state the side explicitly, send `action` (`OPEN` or `CLOSE`) with `direction` (`LONG` or `SHORT`).

The `ticker`, `instrument` and `symbol` keys all mean the same thing. Field-by-field detail is in the [webhook payload reference](https://docs.nyria.io/webhook-reference).

## Options

Options strategies can hold up to 4 legs, all on one expiration, which covers single calls and puts, verticals and iron condors. Contracts come from one of two places:

- **From my rules**: the alert only says the direction, and the strategy's leg rules pick strikes and expiration (by delta, by a number of strikes from at-the-money, or as an offset from another leg). TradingView options strategies always work this way.
- **Provided in alert**: the alert carries a `legs` array with one entry per leg. See [examples/webhook](examples/webhook).

Calendars, diagonals and ratio spreads cannot be built, because every leg shares one expiration and one quantity.

## Paper first

Run every new alert through a paper bot before any live account sees it. Nyria Paper is a free simulated broker with no card and no time limit. Let the alerts fire for a few sessions and compare each order on the bot's log with the alert that caused it. Look for doubled alerts, missed alerts and readings that differ from what you meant. Move to a live bot only when they match, and start with a small budget per entry.

A paper fill shows that your alert was read and routed. It does not predict how a live fill would have gone.

## What is in this repository

| Path | Contents |
|---|---|
| [examples/tradingview](examples/tradingview) | Alert message templates and the open-source Pine Script v6 "Nyria Alert Builder" |
| [examples/webhook](examples/webhook) | `curl` and Python examples, including option legs, closes and order management |
| [examples/discord-telegram](examples/discord-telegram) | Message shapes Nyria reads in Discord and Telegram |

## Limits

- Brokers: Charles Schwab, Tradier, tastytrade, Alpaca and Nyria Paper.
- Stocks, crypto spot and options up to 4 legs on one expiration. No futures or forex.
- Market and limit orders only. Nyria places no stop or target order at your broker; exits come from your exit alerts.
- `MODIFY` works on Tradier and Alpaca. Schwab and tastytrade refuse it.
- No daily-loss cap: a bot keeps taking alerts until you pause it.
- Nothing here is financial advice, and an automated order can lose money. Read the [risk disclosure](https://docs.nyria.io/risk-disclosure).

## Docs

- [Automate TradingView alerts to your broker](https://docs.nyria.io/guides/automate-tradingview-alerts)
- [TradingView alert messages](https://docs.nyria.io/alerts/tradingview/messages)
- [Webhook payload reference](https://docs.nyria.io/webhook-reference)
- [Send alerts from your own bot](https://docs.nyria.io/alerts/custom-webhook)
- [Choose an alert source](https://docs.nyria.io/alert-sources)
- [Multi-leg options strategies](https://docs.nyria.io/strategies/multi-leg-options)
- [TrendSpider](https://docs.nyria.io/alerts/trendspider), [Discord](https://docs.nyria.io/alerts/discord) and [Telegram](https://docs.nyria.io/alerts/telegram)
- [Paper trading](https://docs.nyria.io/paper-trading)

More examples, each one run through Nyria's alert tester by a script: [Nyria-LLC/trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples).

## Built for Nyria

The examples in this repository target [Nyria](https://nyria.io), a service that reads alerts from these sources and places the orders in your broker account. The message shapes follow its docs, so they will not match other tools unchanged. The examples are MIT licensed, and issues and pull requests are welcome.

## License

[MIT](LICENSE)
