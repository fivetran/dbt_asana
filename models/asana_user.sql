with user as (

    select * 
    from {{ var('user') }}
),

task as (
    
    select * 
    from {{ ref('asana_task') }}

),

project_user as (
    
    select * 
    from {{ ref('asana_project_user') }}
),

agg_user_projects as (

    select 
        user_id,
        sum(case when role = 'owner' then 1
            else 0 end) as number_projects_owned,
        currently_working_on,
        case when currently_working_on
        count(project_id) as number_of_projects

    from 
        project_user
),

-- team_task as (

--     select *
--     from {{ ref('asana_team_task_proj') }}
-- ),

-- task_open_length as (

--     select * 
--     from {{ ref('asana_task_open_length') }}
-- ),

task_follower as (

    select *
    from {{ var('task_follower') }}
),

user_join as (

    select
        user.*,
        task.task_id,
        task.task_name,
        task.due_date,
        task.due_date is not null as has_due_date,
        task.is_completed,
        task.completed_at,
        project_user.project_id,
        project_user.role,
        task_open_length.days_since_last_assignment,
        task.followers,
        task.projects,
        task.teams,
        task.tags,
        case when project_user.role = 'owner'

    from user
    left join task on user.user_id = task.asignee_user_id -- big join
    
    left join task_follower on user.user_id = task_follower.user_id,
    left join project_user on user.userid = project_user.user_id
    left join task_open_length on task_open_length.task_id = task.assignee_user_id

    left join team_task

),

agg_user_tasks as (

    select
        user_id,
        user_name,
        email,
        count(task_id) as number_of_tasks,
        case when 
    from user_tasks

)

