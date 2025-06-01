from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

# Bytt til html-mappen
os.chdir("html")

PORT = 8080

class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Slå av logg i terminalen

print(f"🚀 Python-server kjører på http://localhost:{PORT}")
HTTPServer(("", PORT), QuietHandler).serve_forever()
