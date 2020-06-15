with proj_task_history as (

    select * 
    from {{ ref('asana_project_history') }}

), 

agg_proj_tasks as (

    select 
    project_id,
    sum(case when not task_is_completed then 1 else 0 end) as number_of_open_tasks,
    sum(case when task_is_completed then 1 else 0 end) as number_of_tasks_completed,
    sum(case when task_is_completed and task_assignee_user_id is not null then 1 else 0 end) as number_of_assigned_tasks_completed,
    sum(case when task_is_completed then task_days_open else 0 end) as total_days_open,
    sum(case when task_is_completed then task_days_assigned_current_user else 0 end) as total_days_assigned_last_user -- will divde later for avg

    from  proj_task_history

    group by 1
),

order_proj_task_history as (

    {% set date_comparison = 'proj_task_history.task_completed_at desc' if 'proj_task_history.task_is_completed' is true
        else 'proj_task_history.task_due_date asc' %}

    select
        project_id,
        -- project_id,
        -- project_name,
        -- is_archived,
        -- created_at,
        task_id,
        task_name,
        task_assignee_user_id as task_assignee_user_id,
        task_assignee_name as task_assignee_name,
        -- task_created_at,
        task_projects,
        task_teams,
        task_tags,
        task_is_completed,
        task_completed_at,
        task_due_date,
        task_days_assigned_current_user,
        task_days_open,


        -- row number should be 1 for both
        row_number() over(partition by project_id, task_is_completed order by {{ date_comparison }}) as choose_one

    from proj_task_history
    where task_is_completed or task_due_date is not null
     
),

next_last_project_tasks as (

    select
        project_id,

        {% set fields = ['task_id', 'task_name', 'task_assignee_user_id', 'task_assignee_name',
                        'task_projects', 'task_teams', 'task_tags', 'task_due_date', 
                        'task_days_assigned_current_user', 'task_days_open'] %}

        {% for field in fields %} 
        
        -- Max feels like a not-great way to consolidate these, but we're comparing non-null and null value always
        max ( case when task_is_completed then 
        {{ field }} else null end) as last_completed_{{ field }},
        max ( case when not task_is_completed then 
        {{ field }} else null end) as next_due_{{ field }},

        {% endfor %}

        max(task_completed_at) as last_task_completed_at

    from order_proj_task_history

    where choose_one = 1
    group by 1

),

combine_proj_task_metrics as (

    select
        next_last_project_tasks.*,
        agg_proj_tasks.number_of_open_tasks,
        agg_proj_tasks.number_of_tasks_completed,
        nullif(agg_proj_tasks.total_days_open, 0) * 1.0 / nullif(agg_proj_tasks.number_of_tasks_completed, 0) as avg_close_time_days,
        nullif(agg_proj_tasks.total_days_assigned_last_user, 0) * 1.0 / nullif(agg_proj_tasks.number_of_assigned_tasks_completed, 0) as avg_close_time_assigned_days


    from 
    next_last_project_tasks
    join agg_proj_tasks on next_last_project_tasks.project_id = agg_proj_tasks.project_id
    
)

select * from combine_proj_task_metrics
