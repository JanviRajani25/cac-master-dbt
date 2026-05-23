with source as (
    select * from {{ source('raw', 'subscriber_events') }}
),

cleaned as (
    select
        subscriber_id,
        customer_id,
        event_date,
        event_type,
        customer_type,
        oracle_product_code,
        contract_end_date,
        dealer_id,
        sales_channel,
        rr_price,
        equipment_actual_charge,
        bto_selling_price
    from source
    where event_type in ('FTC', 'UPG')
    and customer_type != 'PPD'
)

select * from cleaned