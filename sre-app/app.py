import os
import socket
import time
from flask import Flask, jsonify

app = Flask(__name__)
START_TIME = time.time()

@app.route("/")
def index():
    return jsonify({
        "service": "sre-core-workload",
        "hostname": socket.gethostname(),
        "status": "operational",
        "environment": os.getenv("APP_ENV", "production")
    }), 200

@app.route("/healthz")
def healthz():
    # Production SRE Liveness Probe
    return jsonify({
        "status": "healthy",
        "timestamp": int(time.time())
    }), 200

@app.route("/metrics")
def metrics():
    # Production SRE Telemetry Endpoint
    uptime_seconds = int(time.time() - START_TIME)
    return jsonify({
        "uptime_seconds": uptime_seconds,
        "active_threads": 1
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
