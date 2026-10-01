# courier

Delivers webhooks for the platform. Producers enqueue a delivery (endpoint, event name, JSON
payload); `bin/worker` posts pending deliveries and records the outcome.

Every request is signed: `Courier-Signature: t=<unix time>,v1=<hex HMAC-SHA256 of "t.body">`,
using `COURIER_SIGNING_SECRET`. Receivers should reject signatures older than five minutes.

| Variable | Default | What |
| --- | --- | --- |
| `COURIER_DB` | `courier.db` | SQLite file holding the delivery queue |
| `COURIER_SIGNING_SECRET` | (required) | Shared secret for request signatures |

Run the worker with `bundle exec bin/worker`, the tests with `bundle exec rake test`.
