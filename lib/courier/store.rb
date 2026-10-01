require "json"
require "sqlite3"

module Courier
  # The durable queue of webhook deliveries.
  class Store
    def initialize(path)
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true
      @db.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS deliveries (
          id INTEGER PRIMARY KEY,
          endpoint TEXT NOT NULL,
          event TEXT NOT NULL,
          payload TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      SQL
    end

    def enqueue(endpoint:, event:, payload:)
      @db.execute(
        "INSERT INTO deliveries (endpoint, event, payload) VALUES (?, ?, ?)",
        [endpoint, event, JSON.generate(payload)]
      )
      @db.last_insert_row_id
    end

    def next_pending(limit = 10)
      @db.execute("SELECT * FROM deliveries WHERE status = 'pending' ORDER BY id LIMIT ?", [limit])
    end

    def mark(id, status:, error: nil)
      @db.execute(
        "UPDATE deliveries SET status = ?, attempts = attempts + 1, last_error = ? WHERE id = ?",
        [status, error, id]
      )
    end
  end
end
