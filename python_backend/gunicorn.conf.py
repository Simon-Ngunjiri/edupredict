"""
gunicorn.conf.py
────────────────
Gunicorn configuration for the EduPredict API.

Start the server with:
    gunicorn --config gunicorn.conf.py app:app

Or using the start script:
    ./start.sh        (Linux / macOS)
    start.bat         (Windows — via waitress)
"""

import os
import multiprocessing

# ── Binding ───────────────────────────────────────────────────────────────────
# 0.0.0.0 makes the API reachable from your phone / emulator on the same network
host = os.getenv('HOST', '0.0.0.0')
port = os.getenv('PORT', '5000')
bind = f'{host}:{port}'

# ── Workers ───────────────────────────────────────────────────────────────────
# Rule of thumb: (2 × CPU cores) + 1
# For a dev machine you can set this to 2 or 4 manually
workers = int(os.getenv('WEB_CONCURRENCY', (2 * multiprocessing.cpu_count()) + 1))

# Worker class — sync is fine for a CPU-bound ML model
worker_class = 'sync'

# Max requests per worker before it is restarted (prevents memory leaks)
max_requests          = 1000
max_requests_jitter   = 50

# ── Timeouts ──────────────────────────────────────────────────────────────────
timeout      = 60   # kill worker if it doesn't respond in 60 s
keepalive    = 5    # seconds to wait for the next request on a keep-alive conn
graceful_timeout = 30

# ── Logging ───────────────────────────────────────────────────────────────────
loglevel      = os.getenv('LOG_LEVEL', 'info')
accesslog     = '-'   # stdout
errorlog      = '-'   # stderr
access_log_format = '%(h)s  %(r)s  %(s)s  %(b)s bytes  %(D)sµs'

# ── Process name ─────────────────────────────────────────────────────────────
proc_name = 'edupredict-api'

# ── Hooks (optional) ─────────────────────────────────────────────────────────
def on_starting(server):
    server.log.info("EduPredict API starting…")

def on_exit(server):
    server.log.info("EduPredict API shut down.")
