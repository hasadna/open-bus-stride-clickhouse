{% macro ingest_siri_vehicle_location(year='2026', month='09', day='09', hour='{00..23}', minute='{00..59}') %}

{% set sql %}

insert into siri_vehicle_location
select
    replaceOne(replaceOne(trimLeft(_path, '/'), '.br', ''), 'stride-siri-requester/', '') as siri_snapshot_id,
    parseDateTime32BestEffort(MonitoredStopVisit.RecordedAtTime) as recorded_at_time,
    MonitoredStopVisit.MonitoredVehicleJourney.LineRef as line_ref,
    MonitoredStopVisit.MonitoredVehicleJourney.FramedVehicleJourneyRef.DataFrameRef as data_frame_ref,
    MonitoredStopVisit.MonitoredVehicleJourney.FramedVehicleJourneyRef.DatedVehicleJourneyRef as dated_vehicle_journey_ref,
    MonitoredStopVisit.MonitoredVehicleJourney.OperatorRef as operator_ref,
    parseDateTime32BestEffort(MonitoredStopVisit.MonitoredVehicleJourney.OriginAimedDepartureTime) as origin_aimed_departure_time,
    MonitoredStopVisit.MonitoredVehicleJourney.VehicleLocation.Longitude as vehicle_location_longitude,
    MonitoredStopVisit.MonitoredVehicleJourney.VehicleLocation.Latitude as vehicle_location_latitude,
    MonitoredStopVisit.MonitoredVehicleJourney.Bearing as bearing,
    MonitoredStopVisit.MonitoredVehicleJourney.Velocity as velocity,
    MonitoredStopVisit.MonitoredVehicleJourney.VehicleRef as vehicle_ref,
    MonitoredStopVisit.MonitoredVehicleJourney.MonitoredCall.StopPointRef as stop_point_ref,
    MonitoredStopVisit.MonitoredVehicleJourney.MonitoredCall.Order as stop_order,
    MonitoredStopVisit.MonitoredVehicleJourney.MonitoredCall.DistanceFromStop as distance_from_stop
from url(
    'https://openbus-stride-public.s3.eu-west-1.amazonaws.com/stride-siri-requester/{{ year }}/{{ month }}/{{ day }}/{{ hour }}/{{ minute }}.br',
    JSONEachRow,
    'Siri Tuple(
        ServiceDelivery Tuple(
            ResponseTimestamp String,
            StopMonitoringDelivery Array(
                Tuple(
                    MonitoredStopVisit Array(
                        Tuple(
                            RecordedAtTime String,
                            MonitoredVehicleJourney Tuple(
                                LineRef String,
                                FramedVehicleJourneyRef Tuple(
                                    DataFrameRef String,
                                    DatedVehicleJourneyRef String
                                ),
                                OperatorRef String,
                                OriginAimedDepartureTime String,
                                VehicleLocation Tuple(
                                    Longitude String,
                                    Latitude String
                                ),
                                Bearing String,
                                Velocity String,
                                VehicleRef String,
                                MonitoredCall Tuple(
                                    StopPointRef String,
                                    Order String,
                                    DistanceFromStop String
                                )
                            )
                        )
                    )
                )
            )
        )
    )'
)
array join Siri.ServiceDelivery.StopMonitoringDelivery as StopMonitoringDelivery
array join StopMonitoringDelivery.MonitoredStopVisit as MonitoredStopVisit
settings
    input_format_skip_unknown_fields = 1,
    glob_expansion_max_elements = 9999999
;

{% endset %}

{% do run_query(sql) %}

{% endmacro %}