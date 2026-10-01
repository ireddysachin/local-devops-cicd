from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <h1>🚀 Local DevOps CI/CD Platform</h1>
    <p>Application: Running</p>
    <p>Environment: Floci</p>
    <p>Version: 2.0</p>
    <p>Status: Healthy</p>
    """


@app.route("/health")
def health():
    return {
        "status": "healthy",
        "application": "local-devops-cicd",
        "version": "2.0"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)