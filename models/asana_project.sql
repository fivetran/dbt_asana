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

asana_user as (
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
    {{ string_agg( "concat(asana_user.user_name, ' as ', project_user.role)" , "', '" ) }} as users,
    count(distinct user.user_id) as number_of_users_involved

    from project_user join asana_user using(user_id)

    group by 1

),

project_join as (

    select
        project.project_id,
        project_name,

        coalesce(project_task_metrics.number_of_open_tasks, 0) as number_of_open_tasks,
        coalesce(project_task_metrics.number_of_assigned_open_tasks, 0) as number_of_assigned_open_tasks,
        coalesce(project_task_metrics.number_of_tasks_completed, 0) as number_of_tasks_completed,
        round(project_task_metrics.avg_close_time_days, 0) as avg_close_time_days,
        round(project_task_metrics.avg_close_time_assigned_days, 0) as avg_close_time_assigned_days,

        concat('https://app.asana.com/0/', project.project_id, '/', project.project_id) as project_link,

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
    left join project_task_metrics on project.project_id = project_task_metrics.project_id -- this should include all
    left join agg_project_users on project.project_id = agg_project_users.project_id  
    join team on team.team_id = project.team_id -- every project needs a team

)

select * from project_join