# Python lightweight image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of the app files
COPY . .

# Expose app port
EXPOSE 8000

# Start the app
#CMD ["python", "app.py"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
