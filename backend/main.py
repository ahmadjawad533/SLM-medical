#!/usr/bin/env python3
"""
LIGHTWEIGHT FASTAPI TELEMETRY INGESTION SERVER
-------------------------------------------------------------------------------
Serves POST /api/v1/telemetry endpoint for receiving anonymized batch logs
from deployed field devices when intermittent connectivity is restored.
"""

import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class TelemetryRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/api/v1/telemetry":
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            try:
                payload = json.loads(post_data.decode('utf-8'))
                records = payload.get('records', [])
                print(f"[🌐 FASTAPI ENDPOINT RECEIVED] Batched payload with {len(records)} anonymized telemetry records.")
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {"status": "SUCCESS", "received_count": len(records)}
                self.wfile.write(json.dumps(response).encode('utf-8'))
            except Exception as e:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(str(e).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def run_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, TelemetryRequestHandler)
    print(f"[*] Lightweight Telemetry Endpoint listening on http://localhost:{port}/api/v1/telemetry")
    httpd.handle_request() # Single request handler for test

if __name__ == "__main__":
    run_server()
