from flask import Flask
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route("/")
def home():
    logger.info("Home endpoint accessed")
    return "Hello from your containerized Flask app!"

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    logger.info("Starting Flask application")
    app.run(host="0.0.0.0", port=5000)