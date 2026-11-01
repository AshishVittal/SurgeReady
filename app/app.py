from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <html>
        <head>
            <title>SurgeReady</title>
        </head>
        <body style="font-family: Arial; text-align: center; padding: 60px;">
            <h1>SurgeReady</h1>
            <h2>Application Status: Healthy</h2>
            <p>Running on AWS ECS Fargate</p>
            <p>Cloud Infrastructure | DevOps | Reliability</p>
        </body>
    </html>
    """

@app.route("/health")
def health():
    return jsonify(status="healthy"), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)