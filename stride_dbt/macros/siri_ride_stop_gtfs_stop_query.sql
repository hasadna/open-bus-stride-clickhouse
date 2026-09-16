{% macro siri_ride_stop_gtfs_stop_query(gtfs_where, siri_where) %}

select
    siri_ride_stop_id,
    gtfs.id as gtfs_stop_id,
    calculated_at
from postgresql(
    '{{ env_var("OPEN_BUS_POSTGRES_HOST") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_DB") }}',
    query($$
        select id, date, code
        from gtfs_stop
        where {{ gtfs_where }}
    $$),
    '{{ env_var("OPEN_BUS_POSTGRES_USER") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_PASSWORD") }}'
) as gtfs
inner join (
    select
        siri_ride_stop_id,
        any(stop_code) as stop_code,
        any(scheduled_start_time) as scheduled_start_time,
        now() as calculated_at
    from siri_vehicle_location
    where {{ siri_where }}
    group by siri_ride_stop_id
) siri
    on toStartOfDay(gtfs.date) = toStartOfDay(siri.scheduled_start_time)
    and toString(gtfs.code) = siri.stop_code

{% endmacro %}