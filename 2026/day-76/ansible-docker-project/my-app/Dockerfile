#FROM python:3.12-slim

#WORKDIR /app

#COPY requirements.txt .

#RUN pip install -r requirements.txt

#COPY . .

#EXPOSE 5000

#CMD ["python", "app.py"]

#===========================================================

FROM python:3.12-slim

# Install PostgreSQL client libraries (needed for psycopg2)
RUN apt-get update && apt-get install -y \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
