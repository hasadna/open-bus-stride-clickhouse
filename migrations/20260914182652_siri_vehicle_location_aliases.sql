-- +goose Up
alter table siri_vehicle_location
    add column siri_route_id String alias concat(line_ref, ';', operator_ref),
    add column scheduled_start_time DateTime alias origin_aimed_departure_time,
    add column siri_ride_id String alias concat(siri_route_id, ';', journey_ref),
    add column stop_code String alias stop_point_ref,
    add column siri_stop_id String alias stop_code,
    add column siri_ride_stop_id String alias concat(siri_ride_id, ';', siri_stop_id, ';', stop_order);

-- +goose Down
alter table siri_vehicle_location
    drop column siri_route_id,
    drop column scheduled_start_time,
    drop column siri_ride_id,
    drop column stop_code,
    drop column siri_stop_id,
    drop column siri_ride_stop_id;
