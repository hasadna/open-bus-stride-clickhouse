-- +goose Up
CREATE TABLE siri_vehicle_location
(
    siri_snapshot_id String,
    recorded_at_time DateTime,
    line_ref String,
    data_frame_ref String,
    dated_vehicle_journey_ref String,
    operator_ref String,
    origin_aimed_departure_time DateTime,
    vehicle_location_longitude String,
    vehicle_location_latitude String,
    bearing String,
    velocity String,
    vehicle_ref String,
    stop_point_ref String,
    stop_order String,
    distance_from_stop String
)
ENGINE = MergeTree
PARTITION BY format('{0}/{1}', splitByChar('/', siri_snapshot_id)[1], splitByChar('/', siri_snapshot_id)[2])
PRIMARY KEY (recorded_at_time);

-- +goose Down
DROP TABLE siri_vehicle_location;
