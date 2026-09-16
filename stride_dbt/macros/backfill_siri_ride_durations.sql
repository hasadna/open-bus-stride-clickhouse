{% macro backfill_siri_ride_durations(from_date, to_date) %}

{% set where %}

recorded_at_time >= toDateTime('{{ from_date }} 00:00:00', 'Asia/Jerusalem') - INTERVAL 1 DAY
and recorded_at_time < toDateTime('{{ to_date }} 00:00:00', 'Asia/Jerusalem') + INTERVAL 2 DAY
and scheduled_start_time >= toDateTime('{{ from_date }} 00:00:00', 'Asia/Jerusalem')
and scheduled_start_time < toDateTime('{{ to_date }} 00:00:00', 'Asia/Jerusalem') + INTERVAL 1 DAY

{% endset %}

{% set sql %}

insert into siri_ride_durations
{{
    siri_ride_durations_query(where)
}}

{% endset %}

{% do run_query(sql) %}

{% endmacro %}
