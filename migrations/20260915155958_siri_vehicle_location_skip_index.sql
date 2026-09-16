-- +goose Up
alter table default.siri_vehicle_location
    add index scheduled_start_time_idx scheduled_start_time TYPE minmax;
alter table default.siri_vehicle_location MATERIALIZE INDEX scheduled_start_time_idx;

-- +goose Down
alter table default.siri_vehicle_location drop index scheduled_start_time_idx;
