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

task_section as (

    select * 
    from {{ ref('stg_asana_task_section') }}
),


-- task_story as ( -- TODO: aggregate this someplace else (or just use it in task history table)

--     select *
--     from {{ ref('asana_task_story') }}
-- ),

task_team as (

    select *
    from {{ ref('asana_team_task') }}
),

task_project as (

    select *
    from {{ ref('stg_asana_project_task') }}
),

user as (

    select *
    from {{ ref('stg_asana_user') }}
),

project as (

    select *
    from {{ ref('stg_asana_project') }}
),

section as (
    
    select * 
    from {{ ref('stg_asana_section') }}
),

task_join as (

    select
        task.task_id,
        task.task_name,
        task.assignee_user_id,
        user.user_name as assignee_name,
        user.email as assignee_email,
        task.assignee_status,
        task.created_at,
        task.due_date,
        task.is_completed,
        task.completed_at,
        task.completed_by_user_id,
        task.modified_at,
        task.parent_task_id,
        task.start_date,
        task.task_description,
        coalesce(task_comments.number_of_comments, 0) as number_of_comments,
        task_comments.conversation, -- eh should we include/even have this?
        task_followers.followers,
        coalesce(task_followers.number_of_followers, 0) as number_of_followers,
        task_open_length.days_open, 
        task_open_length.days_assigned,
        task_open_length.last_assigned_at as assigned_at, -- to this current user
        task_tags.tags, 
        coalesce(task_tags.number_of_tags, 0) as number_of_tags, -- not sure this is helpful
        task_team.team_id,
        task_team.team_name,
        project.project_name,
        section.section_name


    from
    task
    left join task_comments on task.task_id = task_comments.task_id
    left join task_followers on task.task_id = task_followers.task_id
    left join task_open_length on task.task_id = task_open_length.task_id
    left join task_tags on task.task_id = task_tags.task_id
   -- left join task_story on task.task_id = task_story.target_task_id
    left join task_team on task.task_id = task_team.task_id

    -- should these kinds of joins live in another model?
    left join task_project on task.task_id = task_project.task_id
    left join project on task_project.project_id = project.project_id

    left join task_section on task.task_id = task_section.task_id
    left join section on task_section.section_id = section.section_id

    left join user on task.assignee_user_id = user.user_id

)

select * from task_join