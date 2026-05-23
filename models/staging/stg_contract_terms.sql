with source as (
select * from {{ source('raw', 'contract_terms') }}
),

cleaned as (
select
        subscriber_id,
        customer_id,
        contract_term
    from source
)

select * from cleaned