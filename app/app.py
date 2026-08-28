import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")
APP_ENV = os.environ.get("APP_ENV", "unknown")


@app.route("/")
def index():
    # Le hostname change à chaque pod/tâche : utile pour prouver visuellement
    # le scaling (plusieurs hostnames différents en répétant les requêtes)
    # et l'auto-réparation (le hostname change après un kill).
    return jsonify(
        status="ok",
        message="TP orchestration ECS + Kubernetes",
        hostname=socket.gethostname(),
        version=APP_VERSION,
        environment=APP_ENV,
    )


@app.route("/health")
def health():
    # Endpoint dédié pour les health checks ALB / readiness probes.
    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
