with task as (
    
    select *
    from {{ ref('stg_asana_task') }}

),

story as (

    select * 
    from {{ ref('asana_task_story') }}

),

assignments as (
    
    select 
    story_id,
    target_task_id as task_id,
    max(created_at) as last_assigned_at -- current assignment, tasks can get passed around

    from story
    where action_taken = 'assigned'

    group by 1,2

),


open_assigned_length as (

    {% set open_until = 'task.completed_at' if 'task.is_completed' is true else dbt_utils.current_timestamp() %}

    select
        task.task_id,
        task.is_completed,
        task.completed_at,
        assignments.last_assigned_at as last_assigned_at,
        {{ dbt_utils.datediff('task.created_at', open_until, 'day') }} as days_open,
        {{ dbt_utils.datediff('assignments.last_assigned_at', open_until, 'day') }} as days_assigned

    from task
    left join assignments 
        on task.task_id=assignments.task_id

)


select * from open_assigned_length