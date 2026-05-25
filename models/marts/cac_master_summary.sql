with source as (
    select * from {{ ref('cac_master') }}
),

summary as (
    select
        count(subscriber_id)                                    as total_contracts,
        sum(case when sch_status = 'Open' then 1 else 0 end)   as open_contracts,
        sum(case when sch_status = 'Closed' then 1 else 0 end) as closed_contracts,
        sum(case when event_type = 'FTC' then 1 else 0 end)    as ftc_contracts,
        sum(case when event_type = 'UPG' then 1 else 0 end)    as upg_contracts,
        sum(init_debt_value)                                    as total_init_debt,
        sum(upfront_payment)                                    as total_upfront_payment,
        sum(monthly_cac)                                        as total_monthly_cac,
        sum(case when hrs_exception is not null then 1 else 0 end) as exception_count
    from source
)

select * from summary