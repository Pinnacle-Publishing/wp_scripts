FROM debian:bullseye
RUN mkdir app
COPY . /app
WORKDIR /app
