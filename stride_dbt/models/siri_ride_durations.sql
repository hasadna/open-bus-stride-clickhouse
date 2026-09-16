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
    siri_ride_durations_query("""
        recorded_at_time > now() - INTERVAL 10 DAY
        and scheduled_start_time > now() - INTERVAL 9 DAY
    """)
}}
