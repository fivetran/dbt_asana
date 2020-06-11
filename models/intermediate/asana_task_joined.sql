with task as (
    select *
    from {{ ref('stg_asana_task') }}
),

task_comments as (

    select * 
    from {{ref('asana_task_comments')}}
),

task_followers as (

    select *
    from {{ ref('asana_task_followers') }}
),

task_open_length as (

    select *
    from {{ ref('asana_task_open_length') }}
),

task_tags as (

    select *
    from {{ ref('asana_task_tags') }}
),

task_team as (

    select *
    from {{ ref('asana_team_task') }}
),

task_assignee as (

    select * 
    from  {{ ref('asana_task_assignee') }}
),

task_project as (

    select *
    from {{ ref('stg_asana_project_task') }}
),

project as (

    select *
    from {{ ref('stg_asana_project') }}
),

task_section as (

    select * 
    from {{ ref('stg_asana_task_section') }}
),

section as (
    
    select * 
    from {{ ref('stg_asana_section') }}
),

subtask_parent as (

    select * 
    from {{ ref('asana_subtask_parent') }}

),

task_join as (

    select
        task.*,
        task_assignee.assignee_name,
        task_assignee.assignee_email,
        coalesce(task_comments.number_of_comments, 0) as number_of_comments,
        task_comments.conversation, -- eh should we include/even have this?
        task_followers.followers,
        coalesce(task_followers.number_of_followers, 0) as number_of_followers,
        task_open_length.days_open, 
        coalesce(task_open_length.days_assigned, 0) as days_assigned, -- unassigned tasks will = 0
        task_open_length.last_assigned_at as assigned_at, -- to this current user
        task_tags.tags, 
        coalesce(task_tags.number_of_tags, 0) as number_of_tags, -- not sure this is helpful
        task_team.team_id,
        task_team.team_name,
        project.project_name,
        section.section_name,
        subtask_parent.subtask_id is not null as is_subtask, -- parent id is in task.*
        subtask_parent.parent_name,
        subtask_parent.parent_assignee_user_id,
        subtask_parent.parent_assignee_name,
        subtask_parent.parent_due_date,
        subtask_parent.parent_created_at

    from
    task
    left join task_comments on task.task_id = task_comments.task_id
    left join task_followers on task.task_id = task_followers.task_id
    left join task_open_length on task.task_id = task_open_length.task_id
    left join task_tags on task.task_id = task_tags.task_id
    left join task_team on task.task_id = task_team.task_id
    left join task_assignee on task.assignee_user_id = task_assignee.assignee_user_id
    left join subtask_parent on task.task_id = subtask_parent.subtask_id

    left join task_project on task.task_id = task_project.task_id
    left join project on task_project.project_id = project.project_id

    left join task_section on task.task_id = task_section.task_id
    left join section on task_section.section_id = section.section_id

)

select * from task_join