#!/usr/bin/env python3
# ~/github/raspberry-projects/webserver/server.py

import os
import sys
import logging
from logging.handlers import RotatingFileHandler
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer

PORT = int(os.getenv("PORT", "8080"))
WEBROOT = os.getenv("WEBROOT", os.path.expanduser("~/github/web/startpage"))
LOGDIR = os.getenv("LOGDIR", os.path.expanduser("~/github/raspberry-projects/webserver/logs"))
os.makedirs(LOGDIR, exist_ok=True)

# Logging
logger = logging.getLogger("startpage")
logger.setLevel(logging.INFO)
handler = RotatingFileHandler(os.path.join(LOGDIR, "server.log"), maxBytes=2_000_000, backupCount=3)
fmt = logging.Formatter("%(asctime)s  %(levelname)s  %(message)s")
handler.setFormatter(fmt)
logger.addHandler(handler)

# Riktig mime for .js-filer
import mimetypes
mimetypes.add_type("application/javascript", ".js")

class Handler(SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        logger.info("%s - %s" % (self.address_string(), fmt % args))

def main():
    if not os.path.isdir(WEBROOT):
        print(f"WEBROOT doesn't exist: {WEBROOT}", file=sys.stderr)
        sys.exit(1)

    os.chdir(WEBROOT)
    with TCPServer(("0.0.0.0", PORT), Handler) as httpd:
        logger.info(f"Serving {WEBROOT} on port {PORT}")
        print(f"Serving {WEBROOT} on port {PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass
        finally:
            logger.info("Shutting down...")
            httpd.server_close()

if __name__ == "__main__":
    main()
