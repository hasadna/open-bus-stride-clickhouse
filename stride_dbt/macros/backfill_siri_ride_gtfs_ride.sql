{% macro backfill_siri_ride_gtfs_ride(from_date, to_date) %}

{% set gtfs_where %}

gtfs_route.date between '{{ from_date }}' and '{{ to_date }}'

{% endset %}

{% set siri_where %}

recorded_at_time >= toDateTime('{{ from_date }} 00:00:00', 'Asia/Jerusalem') - INTERVAL 1 DAY
and recorded_at_time < toDateTime('{{ to_date }} 00:00:00', 'Asia/Jerusalem') + INTERVAL 2 DAY

{% endset %}

{% set sql %}

insert into siri_ride_gtfs_ride
{{
    siri_ride_gtfs_ride_query(gtfs_where, siri_where)
}}

{% endset %}

{% do run_query(sql) %}

{% endmacro %}
