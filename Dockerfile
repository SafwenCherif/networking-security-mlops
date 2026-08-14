FROM python:3.12-slim-bookworm
WORKDIR /app

COPY requirements.txt setup.py ./
COPY networksecurity/ ./networksecurity/
COPY app.py main.py train.py ./
COPY data_schema/ ./data_schema/
COPY templates/ ./templates/

RUN apt-get update -y && apt-get install -y --no-install-recommends awscli \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
