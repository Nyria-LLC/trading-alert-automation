# TradingView examples

Alert messages and a Pine Script v6 template for sending TradingView alerts to a Nyria webhook.

Webhook alerts need a paid TradingView plan with two-factor authentication turned on. Test on a paper bot first.

## Files

| File | What it is |
|---|---|
| [`default-strategy-message.json`](default-strategy-message.json) | The message for a `strategy()` script. One "Order fills only" alert per ticker covers every entry, exit and reversal. |
| [`indicator/`](indicator) | Four messages for an `indicator()` script: long entry, long exit, short entry, short exit. An indicator needs one alert per side. |
| [`limit-order.json`](limit-order.json) | Names the side and asks for a limit order at the alert's price. |
| [`unique-message-id.json`](unique-message-id.json) | Makes each body different so a second entry on the same bar is not dropped as a duplicate. |
| [`plain-text-messages.txt`](plain-text-messages.txt) | Plain text alerts such as `long entry spy`. |
| [`nyria-alert-builder.pine`](nyria-alert-builder.pine) | Open-source Pine Script v6 strategy that writes the webhook message for each order it places. |

## Placeholders

TradingView replaces these in the alert dialog's **Message** box when the alert fires.

| Placeholder | Becomes | Used by |
|---|---|---|
| `{{ticker}}` | The chart symbol, for example `SPY` | both |
| `{{close}}` | Confirmed bar close | both |
| `{{strategy.order.action}}` | `buy` or `sell` | strategy |
| `{{strategy.market_position}}` | `long`, `short` or `flat` after the fill | strategy |
| `{{strategy.prev_market_position}}` | The position before the fill | strategy |
| `{{strategy.order.contracts}}` | Order size, for reference only | strategy |
| `{{interval}}` | Chart timeframe | either |
| `{{time}}` / `{{timenow}}` | Bar open time / alert fire time, UTC | either |
| `{{exchange}}` | Data source, for example `NASDAQ` | either |
| `{{plot_0}}` to `{{plot_19}}` | Numbered plot values from the script | indicator |

TradingView replaces only the placeholders it publishes. A Pine variable such as `{{syminfo.ticker}}` reaches the webhook exactly as typed, with the braces, and nothing trades. In the Message box use `{{ticker}}`. Inside a Pine `alert()` string, join the value in instead: `'{"instrument":"' + syminfo.ticker + '"}'`.

The size of an entry always comes from the bot, so these messages carry no order size.

## Create the alert

1. Open the symbol you trade at the timeframe you trade and add your script.
2. Press `Alt+A` (`Option+A` on Mac) to open a new alert.
3. Set **Condition** to your strategy and choose **Order fills only**. For an indicator, pick its alert and set **Trigger** to **Once Per Bar Close**.
4. Set **Expiration** to open-ended if your plan offers it. An expired alert stops firing without warning.
5. Open **Message** and paste one of the messages from this folder.
6. Open **Notifications**, select **Webhook URL** and paste your webhook URL: `https://trades.nyria.io/webhooks/<your-token>`.
7. Select **Create**.

Keep the URL private. Anyone who has it can send orders to your strategy.

## Nyria Alert Builder

[`nyria-alert-builder.pine`](nyria-alert-builder.pine) places the orders of an example EMA crossover and attaches a JSON message to each one with `alert_message`. One TradingView alert on **Order fills only**, with `{{strategy.order.alert_message}}` as its message, then sends the message of whichever order filled.

TradingView does not fill in `{{placeholders}}` inside `alert_message`, so the script computes every value in Pine. It reads the strategy position before and after each fill, so one order that closes a long and opens a short is sent as one message that says exactly that. No order size is sent.

A long entry from a flat position sends:

```json
{"action":"buy","instrument":"SPY","marketPosition":"long","prevMarketPosition":"flat","price":669.21,"metadata":{"message_id":"SPY-20261006133000-open-long"}}
```

| Field | Meaning |
|---|---|
| `action` | The side of the order that filled: `buy` or `sell`. |
| `instrument` | The chart's ticker, or the ticker typed into the inputs. |
| `prevMarketPosition`, `marketPosition` | The strategy position before and after the fill: `long`, `short` or `flat`. Entry, exit and reversal are read from that change. |
| `price` | The bar close, or the stop or target level when a stop loss or take profit in the script fills. Used only when the receiving strategy places limit orders at the alert price. |
| `metadata.message_id` | Ticker, bar time in UTC and order type. A second copy of the same order's message is dropped as a duplicate. |

### Messages it sends

Examples on SPY, 1 hour, default inputs.

| Event | Message |
|---|---|
| Long entry | `{"action":"buy","instrument":"SPY","marketPosition":"long","prevMarketPosition":"flat","price":669.21,"metadata":{"message_id":"SPY-20261006133000-open-long"}}` |
| Long exit (Long only) | `{"action":"sell","instrument":"SPY","marketPosition":"flat","prevMarketPosition":"long","price":664.87,"metadata":{"message_id":"SPY-20261007173000-close-long"}}` |
| Short entry | `{"action":"sell","instrument":"SPY","marketPosition":"short","prevMarketPosition":"flat","price":664.87,"metadata":{"message_id":"SPY-20261007173000-open-short"}}` |
| Short exit (Short only) | `{"action":"buy","instrument":"SPY","marketPosition":"flat","prevMarketPosition":"short","price":671.43,"metadata":{"message_id":"SPY-20261008153000-close-short"}}` |
| Long to short in one order | `{"action":"sell","instrument":"SPY","marketPosition":"short","prevMarketPosition":"long","price":664.87,"metadata":{"message_id":"SPY-20261007173000-open-short"}}` |
| Short to long in one order | `{"action":"buy","instrument":"SPY","marketPosition":"long","prevMarketPosition":"short","price":671.43,"metadata":{"message_id":"SPY-20261008153000-open-long"}}` |

### Set it up

1. Add the script to a standard candle chart of the symbol you trade, at the timeframe you trade. In its settings, set **Asset class** to match the receiving strategy and check that the ticker in the message preview at the bottom right is one the strategy lists.
2. Open a new alert. Set **Condition** to the script and choose **Order fills only**.
3. Leave the **Message** box as it is. The script fills it with `{{strategy.order.alert_message}}`.
4. Under **Notifications**, turn on **Webhook URL** and paste your webhook URL.
5. Set **Expiration** to open-ended if your plan offers it, then select **Create**.

Do not paste `{{strategy.order.alert_message}}` into a format check on the receiving side. The check does not know what that placeholder holds. Use the default strategy message from this folder there instead; it has the same fields the script sends.

### Use it with your own strategy

The EMA crossover is only an example signal. Replace `goLong` and `goShort` with your conditions and keep the rest. To add the messages to a strategy you already have, copy the "Message builder" section into it, add `process_orders_on_close = true` to its `strategy()` declaration, and pass `buildMessage()` to the `alert_message` argument of each `strategy.entry()`, `strategy.close()` and `strategy.exit()` call, as the "Orders and their messages" section does.

### Inputs

| Input | Effect |
|---|---|
| Asset class | Stock or ETF and Crypto send the bar close as the price. Option sends no price, because the strategy's leg rules pick the contract and its price. Crypto also removes the `.P` suffix from perpetual chart tickers such as `BTCUSDT.P`. |
| Ticker to send | Blank sends the chart's ticker. Fill it in when the chart symbol differs from the ticker the receiving strategy lists. |
| Limit price offset % | Moves the price toward a fill: up for buys, down for sells. Use it only when the receiving strategy places limit orders at the alert price. |
| Add a message id | On by default. |
| Show the last message on the chart | A preview of the message of the last signal order. |
| Trade direction | Long and short reverses in one order on an opposite signal. Long only and Short only close the position instead. |
| Fast and slow EMA lengths, Stop loss %, Take profit % | Belong to the example signal. Stop loss and take profit are off at 0 and are measured from the average entry price. They exit inside the script; the fill is sent as an exit alert and no stop or target order is placed at your broker. |

### Options and crypto

For options, chart the underlying, for example `SPY`, and set **Asset class** to Option. The message names only the underlying and the position change. Strike, expiration and call or put come from the receiving strategy's leg rules: a long signal opens its long legs and a short signal opens its short legs.

For crypto, charts that quote in USD, such as `BTCUSD`, match a USDT or USDC pair when the receiving strategy lists only one pair for that coin. If it lists both, type the exact pair in **Ticker to send**.

### Limitations

- The message sets no order size. Size always comes from the receiving bot's settings.
- Option strikes, expirations and call or put are not in the message.
- The price is the bar close, or the stop or target level, not the price your broker fills at.
- Two orders of the same type on the same bar share a message id, so the second is dropped as a duplicate. If your strategy adds to a position more than once on one bar, turn off **Add a message id**.
- Reversals in one message need the receiving strategy to open both long and short positions.
- Alerts are sent only for orders filled after the alert is created. Orders on past bars send nothing.
- The preview shows the last order placed by a signal. It does not show stop loss or take profit exits.
- Use standard candles. Heikin Ashi, Renko and other synthetic chart types produce fills at prices that never traded.

### Strategy properties

The script declares initial capital 10,000 USD, order size 10% of equity per trade, commission 0.02% per order, slippage of 2 ticks, 100% margin and pyramiding 0. Orders fill at the close of the bar that placed them. These settings exist so the Strategy Tester runs with explicit costs. The EMA crossover is an example signal, not a recommended trading system, and says nothing about future results.

## Repainting

A strategy that repaints shows different entries and exits on past bars than it fired live. Fire alerts only on confirmed bars (`barstate.isconfirmed`), read higher-timeframe data from the last closed bar (`close[1]`), and watch the script live on paper before you automate it. See [TradingView's guide to repainting](https://www.tradingview.com/pine-script-docs/concepts/repainting/).

TradingView decides when to send each alert, and some arrive late, sometimes by a minute. If a few seconds change your fill, avoid sub-minute timeframes.

## Convert an indicator to a strategy

An indicator traded on 4 sides across 5 tickers means 20 alerts to keep in step. As a strategy, the same script needs 5, one per ticker. Swap `indicator(...)` for `strategy(...)` with `process_orders_on_close=true` and `calc_on_every_tick=false`, replace each arrow or `alertcondition()` with `strategy.entry()` or `strategy.close()`, and delete the old alert calls. The full walkthrough is in the [docs](https://docs.nyria.io/alerts/tradingview/indicator-to-strategy).

```pine
//@version=6
strategy("EMA Cross", overlay=true, process_orders_on_close=true, calc_on_every_tick=false)

fast = ta.ema(close, 9)
slow = ta.ema(close, 21)

if ta.crossover(fast, slow)
    strategy.entry("Long", strategy.long)
if ta.crossunder(fast, slow)
    strategy.entry("Short", strategy.short)   // entering short closes the long
```

## Docs

- [Connect TradingView alerts](https://docs.nyria.io/alerts/tradingview)
- [TradingView alert messages](https://docs.nyria.io/alerts/tradingview/messages)
- [Webhook payload reference](https://docs.nyria.io/webhook-reference)
