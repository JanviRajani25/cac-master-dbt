with source as (
select * from {{ref('cac_master')}}
),


bank_offer as (
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
	sch_status,
	monthly_cac,
	case
    	  when sch_status = 'Open' 
    	       and contract_term = 24 
    	       and hrs_exception is null
          then monthly_cac * contract_term
    	  else null
	end as face_value,
	case
	  when sch_status='Open'
               and contract_term=24
               and hrs_exception is NULL
          then 'Y'
	  else 'N'
	end as bank_offer_flag,
	case 
	 when sch_status = 'Open' 
    	       and contract_term = 24 
    	       and hrs_exception is null
          then 
	  concat('CN', cast(extract(year from event_date) as string), 
		cast(extract(month from event_date) as string), 
		cast(row_number() over (order by event_date) as string)) 
	  else NULL
	end as contract_number

from source

)

select * from bank_offer

