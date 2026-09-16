-- +goose Up
alter table siri_vehicle_location add column journey_ref String alias concat(data_frame_ref, '-', dated_vehicle_journey_ref);

-- +goose Down
alter table siri_vehicle_location drop column journey_ref;
