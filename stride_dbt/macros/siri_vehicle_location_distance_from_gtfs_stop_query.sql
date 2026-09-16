{% macro siri_vehicle_location_distance_from_gtfs_stop_query(gtfs_where, siri_where) %}

select
    siri_ride_stop_id,
    vehicle_location_latitude,
    vehicle_location_longitude,
    round(geoDistance(toDecimal32(vehicle_location_latitude, 6), toDecimal32(vehicle_location_longitude, 6), toDecimal32(lat, 6), toDecimal32(lon, 6))) as distance_from_gtfs_stop_meters,
    now() as calculated_at
from postgresql(
    '{{ env_var("OPEN_BUS_POSTGRES_HOST") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_DB") }}',
    query($$
        select id, lat, lon
        from gtfs_stop
        where {{ gtfs_where }}
        and lat is not null and lon is not null
        and lat between 30 and 34 and lon between 32 and 36
    $$),
    '{{ env_var("OPEN_BUS_POSTGRES_USER") }}',
    '{{ env_var("OPEN_BUS_POSTGRES_PASSWORD") }}'
) as gtfs
inner join (
    select
        siri_vehicle_location.siri_ride_stop_id,
        gtfs_stop_id,
        vehicle_location_latitude,
        vehicle_location_longitude
    from siri_vehicle_location
    inner join (
        select gtfs_stop_id, siri_ride_stop_id
        from siri_ride_stop_gtfs_stop
    ) as siri_ride_stop_gtfs_stop on siri_vehicle_location.siri_ride_stop_id = siri_ride_stop_gtfs_stop.siri_ride_stop_id
    where
        toDecimal32OrZero(vehicle_location_latitude, 6) between 30 and 34 and toDecimal32OrZero(vehicle_location_longitude, 6) between 32 and 36
        and {{ siri_where }}
    group by
        siri_vehicle_location.siri_ride_stop_id,
        gtfs_stop_id,
        vehicle_location_longitude, vehicle_location_latitude
) siri
on gtfs.id = siri.gtfs_stop_id

{% endmacro %}