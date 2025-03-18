# Start from a small Python 3 image
FROM python:3.11-slim-bullseye

# Create and switch to a working directory
WORKDIR /app

# Copy only the necessary files (app.py here).
# If you have additional dependencies or a requirements.txt,
# copy that and install via pip below.
COPY app.py /app/

# Install Flask (and any other dependencies)
RUN pip install --no-cache-dir flask

# Expose the port Flask will run on (5000 by default)
EXPOSE 5000

# Set the default command to run the Flask app
CMD ["python", "app.py"]

