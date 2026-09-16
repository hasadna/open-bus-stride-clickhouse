{{
    config(
        materialized='materialized_view',
        engine='ReplacingMergeTree(calculated_at)',
        order_by='siri_ride_stop_id',
        refreshable={
            'interval': 'EVERY 10 MINUTE',
            'append': True,
        }
    )
}}

{{
    siri_ride_stop_gtfs_stop_query("""
        gtfs_stop.date >= now() - interval '9 days'
    """, """
        recorded_at_time >= now() - interval '10 days'
    """)
}}
