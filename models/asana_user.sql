with user_task_metrics as (

    select * 
    from {{ ref('asana_user_task_metrics') }}
),

user as (
    select * 
    from {{ var('user') }}
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

    where currently_working_on or role = 'owner'
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

    -- where role = 'owner' or currently_working_on
    group by 1

),

user_join as (

    select 
        user.*,
        coalesce(user_task_metrics.number_of_open_tasks, 0) as number_of_open_tasks,
        coalesce(user_task_metrics.number_of_tasks_completed, 0) as number_of_tasks_completed,
        user_task_metrics.avg_close_time_days,
        user_task_metrics.last_completed_task_id,
        user_task_metrics.last_completed_task_name,
        user_task_metrics.last_completed_days_assigned_this_user,
        user_task_metrics.last_completed_at,
        user_task_metrics.next_due_task_id,
        user_task_metrics.next_due_task_name,
        user_task_metrics.next_due_due_date as next_due_task_due_date,
        user_task_metrics.next_due_days_assigned_this_user,
        user_task_metrics.last_completed_task_projects,
        user_task_metrics.next_due_task_projects,
        user_task_metrics.last_completed_task_teams,
        user_task_metrics.next_due_task_teams,
        user_task_metrics.last_completed_task_tags,
        user_task_metrics.next_due_task_tags,

        coalesce(current_tasks_followed.number_of_open_tasks_followed, 0) as number_of_open_tasks_followed,
        agg_user_projects.number_of_projects_owned,
        agg_user_projects.number_of_projects_currently_assigned_to,
        agg_user_projects.projects as projects_working_on
    
    from
    user 
    left join user_task_metrics on user.user_id = user_task_metrics.user_id
    left join current_tasks_followed on user.user_id = current_tasks_followed.user_id
    left join agg_user_projects on user.user_id = agg_user_projects.user_id
)

select * from user_join

