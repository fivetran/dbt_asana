with user_task_metrics as (

    select * 
    from {{ ref('int_asana__user_task_metrics') }}
),

asana_user as (
    select * 
    from {{ var('user') }}
),

project_user as (
    
    select * 
    from {{ ref('int_asana__project_user') }}

    where currently_working_on or role = 'owner'
),

count_user_projects as (

    select 
        user_id,
        sum(case when role = 'owner' then 1
            else 0 end) as number_of_projects_owned,
         sum(case when currently_working_on = true then 1
            else 0 end) as number_of_projects_currently_assigned_to

    from project_user

    group by 1

),

unique_user_projects as (
    select
        user_id,
        project_id,
        project_name

    from project_user
    group by 1,2,3
),


agg_user_projects as (

    select 
    user_id,
    {{ fivetran_utils.string_agg( 'project_name', "', '" )}} as projects_working_on

    from unique_user_projects
    group by 1

),

user_join as (

    select 
        asana_user.*,
        coalesce(user_task_metrics.number_of_open_tasks, 0) as number_of_open_tasks,
        coalesce(user_task_metrics.number_of_tasks_completed, 0) as number_of_tasks_completed,
        round(user_task_metrics.avg_close_time_days, 0) as avg_close_time_days,

        coalesce(count_user_projects.number_of_projects_owned, 0) as number_of_projects_owned,
        coalesce(count_user_projects.number_of_projects_currently_assigned_to, 0) as number_of_projects_currently_assigned_to,
        agg_user_projects.projects_working_on
    
    from asana_user 

    left join user_task_metrics on asana_user.user_id = user_task_metrics.user_id
    left join count_user_projects on asana_user.user_id = count_user_projects.user_id
    left join agg_user_projects on asana_user.user_id = agg_user_projects.user_id
)

select * from user_join

