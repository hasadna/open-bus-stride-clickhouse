# Open Bus Stride ClickHouse

Using ClickHouse for Open Bus Stride project.

## Local Development

Prerequisites:

* [Just](https://just.systems/) - a command runner for automation
* [Goose](https://pressly.github.io/goose/) - a database migration tool
* [uv](https://docs.astral.sh/uv/)
* Docker and Docker Compose

Create env files and set values (see files with .example suffix for reference):

* `.open-bus-postgres.env`
* `.goose.env`

Following commands can be used to install the prerequisites on Linux / Mac:

```
curl -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin --force
curl -fsSL https://raw.githubusercontent.com/pressly/goose/master/install.sh | sudo sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Initialize the Python virtualenv:

```
uv sync
```

Start the ClickHouse server from scratch (this will remove all data in existing server):

```
just clickhouse-start-from-scratch
```

Ingest and backfill data for range of days in a month.
Following example ingests and backfills data for 1-2 of August 2026:

```
just data-ingest-backfill 2026 08 01 02
```

## Loading Data

### Ingesting SIRI Vehicle Locations

Pay attention that it always inserts new rows, so don't ingest the same dates multiple times.
Start from scratch if you want to re-ingest the same data.

Load a single default day:

```
just dbt run-operation ingest_siri_vehicle_location
```

Ingest a specific day:

```
just dbt run-operation ingest_siri_vehicle_location --args '{"year": 2026, "month": "09", "day": "09"}'
```

Ingest a full month (may take a while):

```
just dbt run-operation ingest_siri_vehicle_location --args '{"year": 2026, "month": "08", "day": "{01..31}"}'
```

Ingest several months:

```
just dbt run-operation ingest_siri_vehicle_location --args '{"year": 2026, "month": "{03..05}", "day": "{01..31}"}'
```

### Backfilling Related Data

Recent data (typically for last 10 days) is automatically updated, you can force a refresh now:

```
just data-refresh
```

For historical data, you can backfill a date range (make sure you ingested the SIRI vehicle locations for that date range first):

```
just data-backfill 2026-08-01 2026-08-02
```

## Migrations

Migrations define the table schemas and are stored under the `migrations` directory.

Migrations are managed using [Goose](https://pressly.github.io/goose/).

You should run goose via `just goose` command, which will set the correct environment variables for the ClickHouse server.

Create a new migration:

```
just goose create <migration_name> sql
```

Run all migrations:

```
just goose up
```

## Data Management / Ingestion

This is managed via [dbt](https://www.getdbt.com/). The dbt project is located in the `stride_dbt` directory.

You should run dbt via `just dbt` command, which will set the correct environment variables.
