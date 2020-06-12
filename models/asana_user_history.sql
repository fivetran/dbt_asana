with task as (

    select *
    from {{ ref('asana_task') }}

    -- where is_completed is true
),

user as (

    select * 
    from {{ var('user') }}

),

user_task_history as (

    select
        user.*,
        task.task_id,
        task.task_name,
        task.is_completed,
        task.completed_at,
        task.due_date,
        task.completed_at <= task.due_date as completed_on_time, -- null if incomplete or without a due date
        task.days_since_last_assignment as days_assigned_this_user,
        task.last_assigned_at as assigned_this_user_at,
        task.followers as task_followers,
        task.projects as task_projects,
        task.teams as task_teams,
        task.tags as task_tags,
        task.sections as task_sections,
        task.first_modifier_name as task_first_modifier_name,
        task.first_modifier_user_id as task_first_modifier_user_id,
        task.conversation as task_conversation,
        task.task_description

    from user
    left join task 
        on user.user_id = task.assignee_user_id

    order by user_id, assigned_this_user_at asc

)

select * from user_task_history