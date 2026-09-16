-- +goose Up
alter table siri_vehicle_location add column id String
alias concat(
    replaceOne(toString(recorded_at_time), ' ', ';'), ';',
    line_ref, ';',
    operator_ref, ';',
    journey_ref, ';',
    vehicle_ref
);

-- +goose Down
alter table siri_vehicle_location drop column id;
