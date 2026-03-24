FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y sqlite3 zstd && rm -rf /var/lib/apt/lists/*

WORKDIR /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]