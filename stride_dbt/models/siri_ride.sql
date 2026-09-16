{{
    config(
        materialized='view',
    )
}}

select
    siri_vehicle_location.siri_ride_id as id,
    any(siri_route_id) as siri_route_id,
    any(journey_ref) as journey_ref,
    any(scheduled_start_time) as scheduled_start_time,
    any(vehicle_ref) as vehicle_ref,
    argMax(first_vehicle_location_id, siri_ride_durations.calculated_at) as first_vehicle_location_id,
    argMax(last_vehicle_location_id, siri_ride_durations.calculated_at) as last_vehicle_location_id,
    argMax(duration_minutes, siri_ride_durations.calculated_at) as duration_minutes,
    argMax(gtfs_ride_id, siri_ride_gtfs_ride.calculated_at) as gtfs_ride_id
from siri_vehicle_location
left outer join {{ ref('siri_ride_durations') }}
    on siri_ride_durations.siri_ride_id = siri_vehicle_location.siri_ride_id
left outer join {{ ref('siri_ride_gtfs_ride') }}
    on siri_ride_gtfs_ride.siri_ride_id = siri_vehicle_location.siri_ride_id
group by siri_vehicle_location.siri_ride_id
