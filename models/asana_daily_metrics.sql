with task as (

    select *
    from {{ ref('asana_task') }}
),

assignments as (

    select 
        {{ dbt_utils.date_trunc('day', 'created_at') }} as day,
        count(target_task_id) as number_of_tasks_assigned


    from {{ ref('asana_task_story') }}
    where action_taken = 'assigned'

    group by 1

),

creations as (
    select 
        {{ dbt_utils.date_trunc('day', 'created_at') }} as day, 
        count(task_id) as number_of_tasks_created,
        round(avg(days_open), 0) as avg_days_open, -- will be attached to the creation date, but this reflects the completion/current date
        round(avg(days_since_last_assignment), 0) as avg_days_assigned

    from task 
    group by 1
),

completions as (

    select 
        {{ dbt_utils.date_trunc('day', 'completed_at') }} as day, 
        count(task_id) as number_of_tasks_completed
        -- round(avg(days_open), 0) as avg_close_time_days, 
        -- round(avg(days_since_last_assignment), 0) as avg_assigned_close_time_days

    from task
    where is_completed

    group by 1

),


spine as (

    -- should this go in a macro?

    {% if execute %}
    
    {% set first_date_query %}
        select min( created_at) from {{ ref('asana_task') }}
    {% endset %}
    {% set first_date = run_query(first_date_query).columns[0].values() %}
    
    {% else %} {% set first_date = "'2016-01-01'" %}
    {% endif %}

    
    {{ dbt_utils.date_spine(
        datepart = "day", 
        start_date =  "'2016-01-01'", 
        end_date = dbt_utils.dateadd("week", 1, "current_date") ) 
    }} 

),


join_metrics as (

    select
        spine.date_day,
        -- coalesce(assignments.day, creations.day, completions.day) as day,
        coalesce(number_of_tasks_created, 0) as number_of_tasks_created,
        coalesce(number_of_tasks_assigned, 0) as number_of_tasks_assigned,
        coalesce(number_of_tasks_completed, 0) as number_of_tasks_completed,
        avg_days_open as avg_days_open_of_tasks_created,
        avg_days_assigned as avg_days_assigned_of_tasks_created

    from 
    spine
    left join creations on spine.date_day = cast(creations.day as datetime)
    left join assignments on cast(assignments.day as datetime) = spine.date_day -- this or a union distinct of dates?
    left join completions on cast(completions.day as datetime) = spine.date_day


)

select * from join_metrics
order by date_day desc