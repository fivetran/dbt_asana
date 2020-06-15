with project as (

    select * 
    from {{ ref('asana_project') }}
),

project_users as (

    select * 
    from {{ ref('asana_project_user') }}
),

project_team as (

    select *
    from {{ ref('asana_team_task_proj') }}
),

user as (

    select * 
    from {{ var('user') }}
),

consolidate_project_users as (

    select 
        user.user_id,
        user.user_name,
        project_users.role,
        project_team.team_id

    from 
    project_users 
    join user on project_users.user_id = user.user_id
    join project_team on project_team.project_id = project_users.project_id

    group by 1,2,3,4
),

team_user_roles as (

    select
        team_id,
        string_agg(concat("'", user_name, "' as ", role), ", ") as users_involved,
        count(user_id) as number_of_users_invovled
    
    from consolidate_project_users

    group by 1
),

team_join as (

    select
        project.team_id,
        project.team_name,
        team_user_roles.users_involved,
        team_user_roles.number_of_users_invovled,
        sum(project.number_of_open_tasks) as number_of_open_tasks,
        sum(project.number_of_assigned_open_tasks) as number_of_assigned_open_tasks,
        sum(project.number_of_tasks_completed) as number_of_tasks_completed,
        avg(project.avg_close_time_days) as avg_close_time_days,
        avg(project.avg_close_time_assigned_days) as avg_close_time_assigned_days,

        string_agg( case when not project.is_archived then concat("'", project.project_name, "'") 
                    else null end, ", ") as active_projects,
        sum(case when not project.is_archived then 1 else 0 end) as number_of_active_projects,
        sum(case when project.is_archived then 1 else 0 end) as number_of_archived_projects
        

    from project
    left join team_user_roles on project.team_id = team_user_roles.team_id

    group by 1,2,3,4

)

select * from team_join