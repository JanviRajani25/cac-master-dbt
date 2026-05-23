with subscriber_events as (
    select * from {{ ref('stg_subscriber_events') }}
),

device_prices as (
    select * from {{ ref('stg_device_prices') }}
),

vat_rates as (
    select * from {{ ref('stg_vat_rates') }}
),

upfront_payments as (
    select
        s.subscriber_id,
        s.customer_id,
        s.event_date,
        s.event_type,
        s.oracle_product_code,
        s.contract_end_date,
        s.sales_channel,
        d.device_average_price,
        v.vat_rate,
        -- Calculate upfront payment by channel
        -- Same logic as CAC Master
        case
            when s.sales_channel = 'CON' 
                and s.equipment_actual_charge is not null
                then s.equipment_actual_charge
            when s.sales_channel in ('MS', 'SFDC')
                and s.bto_selling_price is not null
                then s.bto_selling_price
            else s.rr_price / (1 + v.vat_rate)
        end as upfront_payment
    from subscriber_events s
    left join device_prices d
        on s.oracle_product_code = d.device_oracle_code
    left join vat_rates v
        on v.vat_code = 1
)

select * from upfront_payments