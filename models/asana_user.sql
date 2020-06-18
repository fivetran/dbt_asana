with user_task_metrics as (

    select * 
    from {{ ref('asana_user_task_metrics') }}
),

task_follower as (

    select *
    from {{ var('task_follower') }}

),

incomplete_tasks as (
    
    select *
    from {{ var('task') }}

    where not is_completed
),

current_tasks_followed as (
    select 
    task_follower.user_id,
    count(incomplete_tasks.task_id) as number_of_open_tasks_followed

    from task_follower join incomplete_tasks using (task_id)

    group by 1
),

project_user as (
    
    select * 
    from {{ ref('asana_project_user') }}

    where currently_working_on
),

agg_user_projects as (

    select 
        user_id,
        sum(case when role = 'owner' then 1
            else 0 end) as number_of_projects_owned,
         sum(case when currently_working_on then 1
            else 0 end) as number_of_projects_currently_assigned_to,
        string_agg(concat("'", project_name, "' as ", role), ', ') as projects

    from 
        project_user

    where role = 'owner' or currently_working_on
    group by 1

),

users as (

    select 
        user_task_metrics.*,
        current_tasks_followed.number_of_open_tasks_followed,
        agg_user_projects.number_of_projects_owned,
        agg_user_projects.number_of_projects_currently_assigned_to,
        agg_user_projects.projects as projects_working_on
    
    from
    user_task_metrics
    join current_tasks_followed on user_task_metrics.user_id = current_tasks_followed.user_id
    join agg_user_projects on user_task_metrics.user_id = agg_user_projects.user_id
)

select * from users

