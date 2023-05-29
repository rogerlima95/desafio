FROM amd64/python:3.9-alpine
WORKDIR /app
COPY . .
RUN apk add --no-cache gcc musl-dev && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del gcc musl-dev
EXPOSE 80
CMD ["python", "app.py"]