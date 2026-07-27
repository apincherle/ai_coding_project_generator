FROM python:3.13-slim
WORKDIR /app
RUN useradd --create-home app
COPY . .
RUN pip install --no-cache-dir .
USER app
EXPOSE 8000
CMD ["uvicorn", "customer_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
