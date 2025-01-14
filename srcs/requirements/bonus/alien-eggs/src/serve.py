#!/usr/bin/env python3

import argparse
import contextlib
import os
import socket
import subprocess
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from prometheus_client import start_http_server, Counter, Gauge, Histogram

# See cpython GH-17851 and GH-17864.
class DualStackServer(HTTPServer):
    def server_bind(self):
        # Suppress exception when protocol is IPv4.
        with contextlib.suppress(Exception):
            self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
        return super().server_bind()


class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()


def shell_open(url):
    if sys.platform == "win32":
        os.startfile(url)
    else:
        opener = "open" if sys.platform == "darwin" else "xdg-open"
        subprocess.call([opener, url])


# Prometheus metrics
REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests served")
ACTIVE_REQUESTS = Gauge("active_http_requests", "Number of active HTTP requests")
GAME_STARTS = Counter('game_starts_total', 'Total number of game starts')
GAME_COMPLETION = Counter('game_completions_total', 'Total number of game completions')
PLAYER_SCORE = Histogram('player_score', 'Distribution of player scores',
    buckets=[10, 20, 50, 100, 200, 500, 1000])

class MetricsRequestHandler(CORSRequestHandler):
    def do_GET(self):
        # Increment request count
        REQUEST_COUNT.inc()
        ACTIVE_REQUESTS.inc()  # Increment active requests gauge

        try:
            super().do_GET()
        finally:
            ACTIVE_REQUESTS.dec()  # Decrement active requests gauge


def serve(root, port, metrics_port, run_browser):
    # Move directory change here
    os.chdir(os.path.abspath(root))

    # Bind to all interfaces explicitly
    address = ("0.0.0.0", port)
    httpd = DualStackServer(address, MetricsRequestHandler)

    # Start the Prometheus metrics server on all interfaces
    start_http_server(metrics_port, addr='0.0.0.0')
    print(f"Prometheus metrics available at: http://0.0.0.0:{metrics_port}/metrics")

    print(f"Serving application at: http://0.0.0.0:{port}")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nKeyboard interrupt received, stopping server.")
    finally:
        httpd.server_close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--port", help="port to listen on", default=8060, type=int)
    parser.add_argument("-m", "--metrics-port", help="port for Prometheus metrics", default=8000, type=int)
    parser.add_argument(
        "-r", "--root", help="path to serve as root (relative to `platform/web/`)", default="../../bin", type=Path
    )
    browser_parser = parser.add_mutually_exclusive_group(required=False)
    browser_parser.add_argument(
        "-n", "--no-browser", help="don't open default web browser automatically", dest="browser", action="store_false"
    )
    parser.set_defaults(browser=True)
    args = parser.parse_args()

    # Change to the directory where the script is located,
    # so that the script can be run from any location.
    os.chdir(Path(__file__).resolve().parent)

    serve(args.root, args.port, args.metrics_port, args.browser)
