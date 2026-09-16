# Open Bus Stride ClickHouse Plan

This documents the high-level plan for implementing this project.

It should be updated as the project progresses and more details are known.

## Goal

Move data off the PostgreSQL database and into Clickhouse for better performance and scalability.

## Tasks

- [x] Setup ClickHouse for local development and handle SIRI data.
  - [x] dbt macro handles ingestion of vehicle locations directly from the S3 siri snapshots
  - [x] related ETL tasks are handled by clickhouse materialized views refreshed every 10 minutes
  - [x] dbt backfill macros allow to backfill historical data for the related ETL tasks
- [ ] connect to the stride api
  - [x] dbt model `siri_ride` is a view that serves the relevant data for the stride api /siri_rides api endpoint
  - [x] siri_vehicle_locations table has a scheduled_start_time skip index that should allow efficient querying as long as the query is filtered by limited scheduled_start_time ranges
  - [ ] implement required changes in stride API to allow it to query the `siri_ride` view from clickhouse
  - [ ] continue implementation of additional views and stride API endpoints as needed to support the full stride API SIRI functionality.
- [ ] Handle live siri data ingestion and automated backfill of historical data (probably via Airflow)
  - [ ] Need to keep track of ingested siri snapshots to avoid re-ingesting the same data
  - [ ] Ingest new snapshots as they arrive from siri requester
  - [ ] Backfill historical / missed snapshots periodically
- [ ] Setup for production
  - [ ] Prepare migration plan
  - [ ] Implement production deployment
