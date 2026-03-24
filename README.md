<div align="center">

  ![Loggd Banner](https://raw.githubusercontent.com/loggdme/.github/refs/heads/main/.github/assets/header.webp)
  
  # DBZip
  A minimal Docker utility to backup and restore SQLite databases using SQL dumps compressed with zstd. Optionally supports custom zstd dictionaries for improved compression ratios across similar databases.
</div>

<br>

## How it works

**Compress**: Dumps the database to SQL (schema + data) and compresses it with zstd. Indexes are recreated on restore, so you get clean, compact backups.

**Decompress**: Decompresses the archive and replays the SQL into a fresh SQLite database.

**Train**: Generates a zstd dictionary from a set of sample databases. Use this once, then reference the dictionary in all future compress/decompress runs for better ratios.

## Usage

### Train a dictionary

```bash
docker run --rm \
  -v /your/path:/data \
  -e MODE=train \
  -e SAMPLE_DIR=/data/samples \
  -e OUTPUT_FILE=/data/db.dict \
  ghcr.io/loggdme/dbzip:latest
```

### Compress

```bash
docker run --rm \
  -v /your/path:/data \
  -e MODE=compress \
  -e ZSTD_LEVEL=9 \
  -e INPUT_FILE=/data/mydb.db \
  -e OUTPUT_FILE=/data/mydb.sql.zst \
  ghcr.io/loggdme/dbzip:latest
```

### Decompress

```bash
docker run --rm \
  -v /your/path:/data \
  -e MODE=decompress \
  -e INPUT_FILE=/data/mydb.sql.zst \
  -e OUTPUT_FILE=/data/restored.db \
  ghcr.io/loggdme/dbzip:latest
```

## Environment variables

| Variable      | Default                | Description                                                             |
|---------------|------------------------|-------------------------------------------------------------------------|
| `MODE`        | `compress`             | `compress` or `decompress`                                              |
| `INPUT_FILE`  | `/data/input.db`       | Path to the source file                                                 |
| `OUTPUT_FILE` | `/data/output.sql.zst` | Path to the output file                                                 |
| `ZSTD_LEVEL`  | `9`                    | zstd compression level (1–19). Higher = smaller but slower.             |
| `DICT_FILE`   | *(none)*               | Optional path to a zstd dictionary file                                 |
| `SAMPLE_DIR`  | `/data`                | Directory of `.db` files to train a dictionary from (`train` mode only) |

## Compression levels

You should test different levels for your specific needs. The repository uses 9 as default, because it is pretty fast and the size difference between anything above it is relatively small. But here are some general level breakpoints.

| Level | Speed     | Ratio     | Use case                   |
|-------|-----------|-----------|----------------------------|
| `3`   | Very fast | Moderate  | Frequent automated backups |
| `9`   | Fast      | Good      | Daily backups *(default)*  |
| `12`  | Medium    | Very good | Weekly backups             |
| `19`  | Slow      | Best      | Cold / archival storage    |

## Example output (Apple M1 Max)

### Compress

```bash
SQLite Backup - Compress
────────────────────────────────────
  Source:      /data/mydb.db
  Destination: /data/mydb.sql.zst
  zstd level:  9

→ Dumping schema and rows to SQL...
  Input size: 1.8G
✓ Compressed: 1.8G → 177M

────────────────────────────────────
Done! 15s - output: /data/mydb.sql.zst
```

### Decompress

```bash
SQLite Backup - Decompress
────────────────────────────────────
  Source:      /data/mydb.sql.zst
  Destination: /data/mydb_restored.db

→ Decompressing archive...
  Compressed size: 177M
→ Importing SQL into SQLite...
✓ Restored: 177M → 1.8G

────────────────────────────────────
Done! 13s - output: /data/mydb_restored.db
```

## License

This project and each package it provides is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details.