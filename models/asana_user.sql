with user_task_metrics as (

    select * 
    from {{ ref('asana_user_task_metrics') }}
),

user as (
    select * 
    from {{ var('user') }}
),

project_user as (
    
    select * 
    from {{ ref('asana_project_user') }}

    where currently_working_on or role = 'owner'
),

agg_user_projects as (

    select 
        user_id,
        sum(case when role = 'owner' then 1
            else 0 end) as number_of_projects_owned,
         sum(case when currently_working_on then 1
            else 0 end) as number_of_projects_currently_assigned_to,
        {{ string_agg( 'project_name', "', '" )}} as projects_working_on

    from 
        project_user

    group by 1

),

user_join as (

    select 
        user.*,
        coalesce(user_task_metrics.number_of_open_tasks, 0) as number_of_open_tasks,
        coalesce(user_task_metrics.number_of_tasks_completed, 0) as number_of_tasks_completed,
        round(user_task_metrics.avg_close_time_days, 0) as avg_close_time_days,

        agg_user_projects.number_of_projects_owned,
        agg_user_projects.number_of_projects_currently_assigned_to,
        agg_user_projects.projects_working_on
    
    from user 

    left join user_task_metrics on user.user_id = user_task_metrics.user_id
    left join agg_user_projects on user.user_id = agg_user_projects.user_id
)

select * from user_join

