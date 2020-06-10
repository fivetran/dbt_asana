with task as (

    select * 
    from {{ ref('stg_asana_task') }}
),

task_assignee as (

    select * 
    from  {{ ref('asana_task_assignee') }}
),

task_assignee_join as (

    select 
        task.*,
        task_assignee.assignee_name
    from
    task left join task_assignee 
        on task.task_id = task_assignee.task_id

),

subtask as (

    select 
        task_id,
        parent_task_id

    from task_assignee_join

    where parent_task_id is not null

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

    from
    task_assignee_join as parent 
    join subtask on parent.task_id = subtask.parent_task_id
)

select * from subtask_parent