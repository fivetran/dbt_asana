with task as (

    select * 
    from {{ ref('stg_asana_task') }}
),

-- user as (

--     select *
--     from {{ }}
-- )

subtask as (

    select 
        task_id,
        parent_id

    from task
),

subtask_parent as (

    select
        parent.task_id as parent_task_id,
        parent.task_name as parent_name,
        parent.due_date as parent_due_date,
        parent.created_at as parent_created_at,
        parent.assignee_user_id as parent_assignee_user_id,

        -- parent.assignee_name as 
    from
    task as parent 
    join subtask on parent.task_id = subtask.parent_task_id
)