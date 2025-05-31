FROM python:3.9-slim

WORKDIR /app

# Install dependencies first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Copy only necessary files
COPY app.py .
COPY test_app.py .

EXPOSE 5000

CMD ["python", "app.py"]