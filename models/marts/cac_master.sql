with exceptions as (
    select * from {{ ref('int_exceptions') }}
),

cac_master as (
    select
        subscriber_id,
        customer_id,
        event_date,
        event_type,
        oracle_product_code,
        device_average_price,
        upfront_payment,
        contract_term,
        contract_end_date,
        sales_channel,
        hrs_exception,

        -- Schedule status
        -- Same logic as CAC Master SCH_STATUS
        case
            when hrs_exception is not null then 'Closed'
            else 'Open'
        end as sch_status,

        -- Initial debt value
        -- Same logic as CAC Master INIT_DEBT_VALUE
        case
            when device_average_price is null 
                or upfront_payment is null 
                or upfront_payment < 0 
                then 0
            when device_average_price - upfront_payment < 0 
                then 0
            else device_average_price - upfront_payment
        end as init_debt_value,

        -- Monthly CAC
        -- Same logic as CAC Master MONTHLY_CAC
        case
            when contract_term is null 
                or contract_term = 0 
                then null
            when device_average_price is null 
                or upfront_payment is null 
                then null
            else (device_average_price - upfront_payment) / contract_term
        end as monthly_cac,

        current_date as loaded_date

    from exceptions
)

select * from cac_master