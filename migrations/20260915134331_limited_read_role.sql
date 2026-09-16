-- +goose envsub on
-- +goose Up
CREATE ROLE limited_reader;
GRANT SELECT ON default.* TO limited_reader;
ALTER ROLE limited_reader SETTINGS
    readonly = 1,
    max_execution_time = 30 READONLY,
    max_memory_usage = '4G' READONLY,
    max_rows_to_read = 100_000_000 READONLY,
    max_bytes_to_read = '20G' READONLY,
    max_threads = 4 READONLY;

CREATE USER '${STRIDE_API_READER_USERNAME}'
IDENTIFIED WITH sha256_password BY '${STRIDE_API_READER_PASSWORD}';
GRANT limited_reader TO '${STRIDE_API_READER_USERNAME}';
ALTER USER '${STRIDE_API_READER_USERNAME}' DEFAULT ROLE limited_reader;

-- +goose Down
drop user '${STRIDE_API_READER_USERNAME}';
drop role limited_reader;
