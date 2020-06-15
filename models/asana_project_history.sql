with task as (

    select *
    from {{ ref('asana_task') }}

),

project as (

    select * 
    from {{ var('project') }}

),

project_task as (

    select * 
    from {{ ref('asana_team_task_proj') }}
),

project_task_history as (

    select
        project.*,
        project_task.team_name,

        task.task_id,
        task.task_name,
        task.created_at as task_created_at,
        task.is_completed as task_is_completed,
        task.completed_at as task_completed_at,
        task.due_date as task_due_date,
        task.completed_at <= task.due_date as task_completed_on_time, -- null if incomplete or without a due date
        task.days_since_last_assignment as days_assigned_this_user,
        task.last_assigned_at as task_last_assigned_at,
        task.followers as task_followers,
        task.projects as task_projects,
        task.teams as task_teams,
        task.tags as task_tags,
        task.sections as task_sections,
        task.first_modifier_name as task_first_modifier_name,
        task.first_modifier_user_id as task_first_modifier_user_id,
        task.conversation as task_conversation,
        task.task_description

    from project
    join project_task 
        on project.project_id = project_task.project_id
    join task 
        on project_task.task_id = task.task_id

    order by project_id, task_created_at asc

)

select * from project_task_history