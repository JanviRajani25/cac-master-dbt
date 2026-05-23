with source as (
select * from {{ source('raw', 'device_prices') }}
),

cleaned as (
select device_oracle_code,
        device_name,
        device_average_price,
        reporting_period
    from source
)

select * from cleaned