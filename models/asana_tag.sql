with tag as (

    select * 
    from {{ var('tag') }}
),

task_tag as (

    select * 
    from {{ var('task_tag') }}
),

task as (

    select *
    from {{ ref('asana_task') }}

    where is_completed and tags is not null

),

agg_tag as (

    select
        tag.tag_id,
        tag.tag_name,
        tag.created_at,
        sum(case when not task.is_completed then 1 else 0 end) as number_of_open_tasks,
        sum(case when not task.is_completed and task.assignee_user_id is not null then 1 else 0 end) as number_of_assigned_open_tasks,
        sum(case when task.is_completed then 1 else 0 end) as number_of_tasks_completed,
        sum(case when task.is_completed and task.assignee_user_id is not null then 1 else 0 end) as number_of_assigned_tasks_completed,
        avg(task.days_open) as avg_days_open,
        avg(task.days_since_last_assignment) as avg_days_assigned


    from tag 
    left join task_tag on tag.tag_id = task_tag.tag_id
    left join task on task.task_id = task_tag.task_id

    group by 1,2,3
)

select * from agg_tag
