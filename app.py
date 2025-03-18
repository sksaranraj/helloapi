from flask import Flask

# Create a Flask application instance
app = Flask(__name__)

# Define a route for the root URL ("/")
@app.route("/")
def hello_world():
    return "Hello, World!"

if __name__ == "__main__":
    # Start the Flask development server
    app.run(debug=True)

