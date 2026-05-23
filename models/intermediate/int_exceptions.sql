with upfront_payments as (
    select * from {{ ref('int_upfront_payments') }}
),

contract_terms as (
    select * from {{ ref('stg_contract_terms') }}
),

exceptions as (
    select
        u.subscriber_id,
        u.customer_id,
        u.event_date,
        u.event_type,
        u.oracle_product_code,
        u.device_average_price,
        u.upfront_payment,
        u.sales_channel,
        u.contract_end_date,
        c.contract_term,
        -- Exception flags
        -- Same logic as CAC Master exception checks
        case 
            when u.oracle_product_code is null 
            then 'Y' else 'N' 
        end as invalid_handset,
        case 
            when u.device_average_price is null 
            then 'Y' else 'N' 
        end as invalid_device_cost,
        case 
            when u.upfront_payment is null 
            or u.upfront_payment < 0 
            then 'Y' else 'N' 
        end as invalid_upfront_payment,
        case 
            when c.contract_term not in (12, 18, 24) 
            then 'Y' else 'N' 
        end as invalid_contract_term,
        -- Determine exception reason
        -- Priority order same as CAC Master
        case
            when u.oracle_product_code is null 
                then 'Invalid Handset'
            when u.device_average_price is null 
                then 'Device Cost'
            when u.upfront_payment is null 
                or u.upfront_payment < 0 
                then 'Upfront Payment'
            when c.contract_term not in (12, 18, 24) 
                then 'Contract Term'
            else null
        end as hrs_exception
    from upfront_payments u
    left join contract_terms c
        on u.subscriber_id = c.subscriber_id
        and u.customer_id = c.customer_id
)

select * from exceptions