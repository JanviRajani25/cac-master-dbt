with source as (
select * from {{ source('raw', 'vat_rates') }}
),

cleaned as (
select vat_code,
        vat_rate,
        effective_date,
        expiration_date
    from source
)

select * from cleaned