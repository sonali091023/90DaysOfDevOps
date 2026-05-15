import os
import time
import redis
import psycopg2
from flask import Flask, jsonify, render_template

app = Flask(__name__)

# ── Redis ──────────────────────────────────────────────────────────────────────
REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")
cache = redis.from_url(REDIS_URL, decode_responses=True)

# ── Postgres ───────────────────────────────────────────────────────────────────
DB_DSN = (
    f"host={os.getenv('DB_HOST', 'db')} "
    f"port={os.getenv('DB_PORT', '5432')} "
    f"dbname={os.getenv('DB_NAME', 'appdb')} "
    f"user={os.getenv('DB_USER', 'appuser')} "
    f"password={os.getenv('DB_PASSWORD', 'apppassword')}"
)


def get_db():
    return psycopg2.connect(DB_DSN)


def init_db():
    """Create the visits table if it does not exist."""
    conn = get_db()
    with conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS visits (
                    id        SERIAL PRIMARY KEY,
                    visited_at TIMESTAMPTZ DEFAULT NOW()
                );
                """
            )
    conn.close()


# ── Routes ─────────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    # 1. Record visit in Postgres
    conn = get_db()
    with conn:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO visits DEFAULT VALUES;")
            cur.execute("SELECT COUNT(*) FROM visits;")
            total = cur.fetchone()[0]
    conn.close()

    # 2. Cache the count in Redis (TTL = 10 s)
    cache.set("visit_count", total, ex=10)

    return render_template("index.html", total_visits=total)


@app.route("/cached")
def cached():
    """Return the visit count from Redis if available, else hit Postgres."""
    count = cache.get("visit_count")
    hit = count is not None

    if not hit:
        conn = get_db()
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM visits;")
            count = cur.fetchone()[0]
        conn.close()
        cache.set("visit_count", count, ex=10)

    return jsonify(
        message="Cached endpoint",
        visit_count=int(count),
        cache_hit=hit,
    )


@app.route("/health")
def health():
    checks = {}

    # Redis ping
    try:
        cache.ping()
        checks["redis"] = "ok"
    except Exception as e:
        checks["redis"] = str(e)

    # Postgres ping
    try:
        conn = get_db()
        conn.close()
        checks["postgres"] = "ok"
    except Exception as e:
        checks["postgres"] = str(e)

    all_ok = all(v == "ok" for v in checks.values())
    return jsonify(status="healthy" if all_ok else "degraded", checks=checks), (200 if all_ok else 503)


# ── Startup ────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Retry DB init — the DB container may still be starting up
    for attempt in range(10):
        try:
            init_db()
            print("✅  Database initialised")
            break
        except Exception as e:
            print(f"⏳  Waiting for DB ({attempt + 1}/10): {e}")
            time.sleep(3)

    app.run(host="0.0.0.0", port=8000, debug=False)
