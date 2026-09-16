{% macro siri_ride_gtfs_ride_query(gtfs_where, siri_where) %}

select
    siri_ride_id,
    gtfs_ride_id,
    calculated_at
from postgresql(
    '{{ env_var("OPEN_BUS_POSTGRES_HOST") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_DB") }}',
    query($$
        select
            gtfs_ride.id gtfs_ride_id,
            gtfs_ride.start_time,
            gtfs_route.line_ref,
            gtfs_route.operator_ref
        from gtfs_ride, gtfs_route
        where gtfs_route.id = gtfs_ride.gtfs_route_id
        and {{ gtfs_where }}
    $$),
    '{{ env_var("OPEN_BUS_POSTGRES_USER") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_PASSWORD") }}'
) as gtfs
inner join (
    select
        siri_ride_id, any(line_ref) as line_ref,
        any(operator_ref) as operator_ref,
        any(scheduled_start_time) as scheduled_start_time,
        now() as calculated_at
    from siri_vehicle_location
    where {{ siri_where }}
    group by siri_ride_id
) siri
    on gtfs.start_time = siri.scheduled_start_time
    and toString(gtfs.line_ref) = siri.line_ref
    and toString(gtfs.operator_ref) = siri.operator_ref

{% endmacro %}