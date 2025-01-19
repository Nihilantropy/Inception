#!/usr/bin/env python3

import argparse
import contextlib
import os
import signal
import socket
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from prometheus_client import start_http_server, Counter, Gauge

class DualStackServer(HTTPServer):
    def server_bind(self):
        # Suppress exception when protocol is IPv4
        with contextlib.suppress(Exception):
            self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
        return super().server_bind()

class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

# Prometheus metrics
REQUEST_COUNT = Counter("http_requests_total", "Total HTTP requests served")
ACTIVE_REQUESTS = Gauge("active_http_requests", "Number of active HTTP requests")

class MetricsRequestHandler(CORSRequestHandler):
    def do_GET(self):
        REQUEST_COUNT.inc()
        ACTIVE_REQUESTS.inc()
        try:
            super().do_GET()
        finally:
            ACTIVE_REQUESTS.dec()

def signal_handler(signum, frame):
    print(f"\nReceived signal {signum}. Shutting down gracefully...")
    sys.exit(0)

def serve(root, port, metrics_port):
    # Register signal handlers
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    # Change to the specified root directory
    os.chdir(os.path.abspath(root))
    
    # Start Prometheus metrics server
    try:
        start_http_server(metrics_port, addr='0.0.0.0')
        print(f"Prometheus metrics available at: http://0.0.0.0:{metrics_port}/metrics")
    except Exception as e:
        print(f"Failed to start metrics server: {e}")
        sys.exit(1)

    # Start the main HTTP server
    try:
        httpd = DualStackServer(('0.0.0.0', port), MetricsRequestHandler)
        print(f"Serving application at: http://0.0.0.0:{port}")
        httpd.serve_forever()
    except Exception as e:
        print(f"Failed to start HTTP server: {e}")
        sys.exit(1)
    finally:
        httpd.server_close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--port", help="port to listen on", default=8060, type=int)
    parser.add_argument("-m", "--metrics-port", help="port for Prometheus metrics", default=8000, type=int)
    parser.add_argument("-r", "--root", help="path to serve as root", default=".", type=str)
    parser.add_argument("-n", "--no-browser", help="don't open browser", action="store_true")
    
    args = parser.parse_args()
    serve(args.root, args.port, args.metrics_port)
    
def display_art():
    print(r"""

    """)