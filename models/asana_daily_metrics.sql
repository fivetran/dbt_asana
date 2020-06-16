with task as (

    select *
    from {{ ref('asana_task') }}
),

assignments as (

    select 
        {{ dbt_utils.date_trunc('day', 'happened_at') }} as day,
        count(task_id) as number_of_tasks_assigned


    from {{ ref('asana_task_history') }}
    where action_taken = 'assigned'

    group by 1

),

creations as (
    select 
        {{ dbt_utils.date_trunc('day', 'created_at') }} as day, 
        count(task_id) as number_of_tasks_created

    from task 
    group by 1
),

completions as (

    select 
        {{ dbt_utils.date_trunc('day', 'created_at') }} as day, 
        count(task_id) as number_of_tasks_completed,
        avg(days_open) as avg_days_open,
        avg(days_since_last_assignment) as avg_days_assigned

    from task
    where is_completed

    group by 1

),

join_metrics as (

    select
        coalesce(assignments.day, creations.day, completions.day) as day,
        coalesce(number_of_tasks_created, 0) as number_of_tasks_created,
        coalesce(number_of_tasks_assigned, 0) as number_of_tasks_assigned,
        coalesce(number_of_tasks_completed, 0) as number_of_tasks_completed,
        avg_days_open,
        avg_days_assigned

    from creations
    full outer join assignments on assignments.day = creations.day -- this or a union distinct of dates?
    full outer join completions on completions.day = creations.day

)

select * from join_metrics
order by day desc