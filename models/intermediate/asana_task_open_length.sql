with task as (
    
    select *
    from {{ ref('stg_asana_task') }}

),

open_length as (

    select
        task_id,
        is_completed,
        case 
        when is_completed then {{ dbt_utils.datediff('created_at', 'completed_at', 'day') }}
        else {{ dbt_utils.datediff('created_at', dbt_utils.current_timestamp(), 'day') }} 
        end as days_open

    from task

),

final as (

    select
        task_id,
        is_completed,
        days_open
        -- cast(open_length as FLOAT64) / 60 / 60 / 24 as open_length_days

    from open_length
)

select * from final