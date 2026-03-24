<div align="center">

  ![Loggd Banner](https://raw.githubusercontent.com/loggdme/.github/refs/heads/main/.github/assets/header.webp)
  
  # DBZip
  A minimal Docker utility to backup and restore SQLite databases using SQL dumps compressed with zstd.
</div>

<br>

## How it works

**Compress**: Dumps the database to SQL (schema + data) and compresses it with zstd. Indexes are recreated on restore, so you get clean, compact backups.

**Decompress**: Decompresses the archive and replays the SQL into a fresh SQLite database.

## Usage

### Compress

```bash
docker run --rm \
  -v /your/path:/data \
  -e MODE=compress \
  -e ZSTD_LEVEL=9 \
  -e INPUT_FILE=/data/mydb.db \
  -e OUTPUT_FILE=/data/mydb.sql.zst \
  ghcr.io/loggdme/sqlite-compress
```

### Decompress

```bash
docker run --rm \
  -v /your/path:/data \
  -e MODE=decompress \
  -e INPUT_FILE=/data/mydb.sql.zst \
  -e OUTPUT_FILE=/data/restored.db \
  ghcr.io/loggdme/sqlite-compress
```

## Environment variables

| Variable      | Default                | Description                                                 |
|---------------|------------------------|-------------------------------------------------------------|
| `MODE`        | `compress`             | `compress` or `decompress`                                  |
| `INPUT_FILE`  | `/data/input.db`       | Path to the source file                                     |
| `OUTPUT_FILE` | `/data/output.sql.zst` | Path to the output file                                     |
| `ZSTD_LEVEL`  | `9`                    | zstd compression level (1–19). Higher = smaller but slower. |

## Compression levels

You should test different levels for your specific needs. The repository uses 9 as default, because it is pretty fast and the size difference between anything above it is relatively small. But here are some general level breakpoints.

| Level | Speed     | Ratio     | Use case                   |
|-------|-----------|-----------|----------------------------|
| `3`   | Very fast | Moderate  | Frequent automated backups |
| `9`   | Fast      | Good      | Daily backups *(default)*  |
| `12`  | Medium    | Very good | Weekly backups             |
| `19`  | Slow      | Best      | Cold / archival storage    |

## License

This project and each package it provides is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details.