{{
    config(
        materialized='materialized_view',
        engine='ReplacingMergeTree(calculated_at)',
        order_by='siri_ride_id',
        refreshable={
            'interval': 'EVERY 10 MINUTE',
            'append': True,
        }
    )
}}

{{
    siri_ride_gtfs_ride_query("""
        gtfs_route.date >= now() - interval '9 days'
    """, """
        recorded_at_time >= now() - interval '10 days'
    """)
}}
