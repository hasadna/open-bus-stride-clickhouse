set positional-arguments

default:
    @just --list

goose *args:
    #!/usr/bin/env bash
    export GOOSE_DRIVER=clickhouse
    export GOOSE_DBSTRING="tcp://localhost:19000?username=openbus&password=stride&database=default"
    export GOOSE_MIGRATION_DIR=migrations
    source .goose.env
    exec goose "$@"

dbt *args:
    #!/usr/bin/env bash
    set -euo pipefail
    source .open-bus-postgres.env
    cd stride_dbt
    export DBT_PROFILES_DIR=.
    exec uv run dbt "$@"

clickhouse-client *args:
    #!/usr/bin/env bash
    docker compose exec -it clickhouse clickhouse-client "$@"

clickhouse-start-from-scratch:
    #!/usr/bin/env bash
    set -euo pipefail
    docker compose down -v || true
    docker compose up -d clickhouse
    sleep 1
    while ! just clickhouse-client --query "SELECT 1"; do
        echo "Waiting for ClickHouse to be ready..."
        sleep 1
    done
    just goose up
    just dbt run -f

data-refresh:
    #!/usr/bin/env bash
    set -euo pipefail
    just clickhouse-client --query "SYSTEM REFRESH VIEW default.siri_ride_durations_mv"
    just clickhouse-client --query "SYSTEM REFRESH VIEW default.siri_ride_gtfs_ride_mv"

data-backfill *args:
    #!/usr/bin/env bash
    set -euo pipefail
    echo Backfill siri ride durations
    just dbt run-operation backfill_siri_ride_durations --args '{"from_date": "'$1'", "to_date": "'$2'"}'
    echo Backfill siri ride gtfs ride
    just dbt run-operation backfill_siri_ride_gtfs_ride --args '{"from_date": "'$1'", "to_date": "'$2'"}'
    echo Backfill siri ride stop gtfs stop
    just dbt run-operation backfill_siri_ride_stop_gtfs_stop --args '{"from_date": "'$1'", "to_date": "'$2'"}'
    echo Backfill siri vehicle location distance from gtfs stop
    just dbt run-operation backfill_siri_vehicle_location_distance_from_gtfs_stop --args '{"from_date": "'$1'", "to_date": "'$2'"}'

data-ingest-backfill *args:
    #!/usr/bin/env bash
    set -euo pipefail
    echo Ingesting SIRI vehicle location data for $1-$2-$3 to $1-$2-$4
    just dbt run-operation ingest_siri_vehicle_location --args '{"year": '$1', "month": "'$2'", "day": "{'$3'..'$4'}"}'
    echo Backfilling related data for $1-$2-$3 to $1-$2-$4
    just data-backfill $1-$2-$3 $1-$2-$4
