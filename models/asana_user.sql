with user as (

    select * 
    from {{ var('user') }}
),

tasks as (
    
    select * 
    from {{ ref('asana_task') }}

),

user_tasks as (

    select
        user.user_id,
        user.user_name,
        task_id

    from user
    left join task on user.user_id = task.asignee_id

),

