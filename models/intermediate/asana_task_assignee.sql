with task as (

    select * 
    from {{ var('task') }}

),

user as (

    select *
    from {{ var('user') }}
),

task_assignee as (

    select
        task.*,
        assignee_user_id is not null as has_assignee,
        user.user_name as assignee_name,
        user.email as assignee_email

    from task 
    left join user 
        on task.assignee_user_id = user.user_id
)

select * from task_assignee