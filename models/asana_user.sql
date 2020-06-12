with user_task_metrics as (

    select * 
    from {{ ref('asana_user_task_metrics') }}
),


-- for # of tasks they follow
tasks_followed as (

    select 
        user_id,
        count(task_id) as number_of_tasks_followed

    from {{ var('task_follower') }}

    group by 1
),

-- for the current projects being worked on and projects they own
project_user as (
    
    select * 
    from {{ ref('asana_project_user') }}

    where currently_working_on
),

agg_user_projects as (

    select 
        user_id,
        sum(case when role = 'owner' then 1
            else 0 end) as number_projects_owned,
         sum(case when currently_working_on then 1
            else 0 end) as number_projects_currently_assigned_to,
        string_agg(concat("'", project_name, "' as ", role), ', ') as projects

    from 
        project_user

    where role = 'owner' or currently_working_on
    group by 1

),

users as (

    select 
        user_task_metrics.*,
        tasks_followed.number_of_tasks_followed, -- total, not ones just currently open. TODO: change this?
        agg_user_projects.number_projects_owned,
        agg_user_projects.number_projects_currently_assigned_to,
        agg_user_projects.projects as projects_working_on
    from
    user_task_metrics
    join tasks_followed on user_task_metrics.user_id = tasks_followed.user_id
    join agg_user_projects on user_task_metrics.user_id = agg_user_projects.user_id
)

select * from users

