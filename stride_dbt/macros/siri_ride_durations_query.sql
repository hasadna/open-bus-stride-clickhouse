{% macro siri_ride_durations_query(where=None) %}

SELECT
    siri_ride_id,
    argMin(id, tuple(recorded_at_time, id)) AS first_vehicle_location_id,
    argMax(id, tuple(recorded_at_time, id)) AS last_vehicle_location_id,
    min(recorded_at_time) AS first_recorded_at_time,
    max(recorded_at_time) AS last_recorded_at_time,
    if(
        first_recorded_at_time < last_recorded_at_time
        AND last_recorded_at_time < now() - INTERVAL 6 HOUR,
        toNullable(
            toInt32(
                round(
                    dateDiff(
                        'second',
                        first_recorded_at_time,
                        last_recorded_at_time
                    ) / 60.0
                )
            )
        ),
        NULL
    ) AS duration_minutes,
    now() AS calculated_at
FROM siri_vehicle_location
WHERE {{ where }}
GROUP BY siri_ride_id

{% endmacro %}