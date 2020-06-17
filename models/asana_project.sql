with project_task_metrics as (

    select *
    from {{ ref('asana_project_task_metrics') }}
),

project as (
    
    select *
    from {{ var('project') }}
),

project_user as (
    
    select *
    from {{ ref('asana_project_user') }}
),

user as (
    select *
    from {{ var('user') }}
),

team as (
    select *
    from {{ var('team') }}
),

agg_project_users as (

    select 
    project_user.project_id,
    string_agg(concat("'", user.user_name, "' as ", role), ', ') as users,
    count(distinct user_id) as number_of_users_involved

    from project_user join user using(user_id)

    group by 1

),

project_join as (

    select
        -- prect.project_id,
        project_name,
        project_task_metrics.*, -- first col is project_id, quicker to write out project than metrics columns
        project.team_id,
        team.team_name,
        project.is_archived,
        created_at,
        current_status,
        due_date,
        modified_at as last_modified_at,
        owner_user_id,
        agg_project_users.users as users_involved,
        agg_project_users.number_of_users_involved,
        is_public
        -- TODO: maybe add list of sections that are in the project?
    from
    project 
    join project_task_metrics on project.project_id = project_task_metrics.project_id -- this should include all
    join agg_project_users on project.project_id = agg_project_users.project_id  -- needs owner so can do join
    join team on team.team_id = project.team_id -- every project needs a team

)

select * from project_join