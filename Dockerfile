# Use the official Python image as the base
FROM python:3.13-slim

# Install system dependencies required by Poetry, build tools, and messaging libraries
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    librdkafka-dev && \
    apt-get clean

# Install Poetry using the official installation script
RUN curl -sSL https://install.python-poetry.org | python3 -

# Ensure Poetry is added to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set the working directory inside the container
WORKDIR /agent

# Disable Poetry's virtual environment management (optional for Docker)
ENV POETRY_VIRTUALENVS_CREATE=false

# Copy only Poetry's configuration files to optimize Docker build caching
COPY pyproject.toml poetry.lock ./

# Install dependencies with Poetry, including messaging clients
RUN poetry install --without dev

# Copy the rest of the application code into the container
COPY . .

# Expose port for your agent's API or health check
EXPOSE 8080

# Define environment variables for Kafka and RabbitMQ (Optional: placeholders can be overridden at runtime)
ENV KAFKA_BROKER=kafka:9092
ENV RABBITMQ_HOST=rabbitmq
ENV RABBITMQ_PORT=5672
ENV RABBITMQ_USER=admin
ENV RABBITMQ_PASS=admin

# Define the command to run your agent
CMD ["poetry", "run", "python", "main.py"]
