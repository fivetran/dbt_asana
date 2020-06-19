with team as (

    select * from {{ var('team') }}
),

project as (

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

team_users as (
    -- need to de-dupe users here, as they can appear twice in a project as owner + assignee

    select 
        project_team.team_id,
        user.user_id,
        user.user_name

    from 
    project_users 
    join user on project_users.user_id = user.user_id
    join project_team on project_team.project_id = project_users.project_id

    group by 1,2,3
),

agg_team_users as (

    select
        team_id,
        string_agg( concat("'", user_name, "'"), ", " ) as users_involved,
        count(user_id) as number_of_users_invovled
    
    from team_users
    group by 1

),

team_join as (

    select
        team.team_id,
        team.team_name,
        agg_team_users.users_involved,
        coalesce(agg_team_users.number_of_users_invovled, 0) as number_of_users_invovled,

        coalesce( sum(project.number_of_open_tasks), 0) as number_of_open_tasks,
        coalesce( sum( project.number_of_assigned_open_tasks), 0) as number_of_assigned_open_tasks,
        coalesce( sum(project.number_of_tasks_completed), 0) as number_of_tasks_completed,
        round(avg(project.avg_close_time_days), 0) as avg_close_time_days,
        round(avg(project.avg_close_time_assigned_days), 0) as avg_close_time_assigned_days,

        coalesce( sum(case when not project.is_archived then 1 else 0 end), 0) as number_of_active_projects,
        string_agg( case when not project.is_archived then concat("'", project.project_name, "'") 
                    else null end, ", ") as active_projects,
        coalesce( sum(case when project.is_archived then 1 else 0 end), 0) as number_of_archived_projects

        

    from team 
    left join project on project.team_id = team.team_id
    left join agg_team_users on project.team_id = agg_team_users.team_id

    group by 1,2,3,4

)

select * from team_join