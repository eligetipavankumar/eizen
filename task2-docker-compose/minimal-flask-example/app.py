from flask import Flask, jsonify
import time

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"status": "ok", "time": time.time()})

@app.route('/metrics')
def metrics():
    # simple placeholder metrics
    return "# HELP app_requests_total Total requests\napp_requests_total 1\n", 200, {'Content-Type': 'text/plain; version=0.0.4; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
