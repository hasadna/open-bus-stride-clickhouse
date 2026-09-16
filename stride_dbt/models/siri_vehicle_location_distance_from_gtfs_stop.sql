{{
    config(
        materialized='materialized_view',
        engine='ReplacingMergeTree(calculated_at)',
        order_by='siri_ride_stop_id,vehicle_location_latitude,vehicle_location_longitude',
        refreshable={
            'interval': 'EVERY 10 MINUTE',
            'append': True,
        }
    )
}}

{{
    siri_vehicle_location_distance_from_gtfs_stop_query("""
        date >= now() - interval '9 days'
    """, """
        recorded_at_time >= now() - interval '10 days'
    """)
}}
