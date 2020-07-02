with task_assignee_join as (

    select * 
    from  {{ ref('asana_task_assignee') }}

),


subtask_parent as (

    select
        subtask.task_id as subtask_id,
        parent.task_id as parent_task_id,
        parent.task_name as parent_name,
        parent.due_date as parent_due_date,
        parent.created_at as parent_created_at,
        parent.assignee_user_id as parent_assignee_user_id,
        parent.assignee_name as parent_assignee_name

    from task_assignee_join as parent 
    join task_assignee_join as subtask
        on parent.task_id = subtask.parent_task_id

)

select * from subtask_parent