FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy local Flask application into image
COPY minimal-flask-example/ /app/

# Install Python requirements
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; else pip install --no-cache-dir flask; fi

# Expose Flask port
EXPOSE 5000

# Run Flask application directly to avoid Flask CLI import issues
# Use -u for unbuffered output so logs appear promptly
CMD ["python", "-u", "app.py"]
