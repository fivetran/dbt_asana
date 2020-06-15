with user_task_history as (

    select * 
    from {{ ref('asana_user_history') }}

), 

agg_user_tasks as (

    select 
    user_id,
    sum(case when not is_completed then 1 else 0 end) as number_of_open_tasks,
    sum(case when is_completed then 1 else 0 end) as number_of_tasks_completed,
    sum(case when is_completed then days_assigned_this_user else 0 end) as total_days_assigned -- will divde later for avg

    from  user_task_history

    group by 1
),

order_user_task_history as (

    {% set date_comparison = 'user_task_history.completed_at desc' if 'user_task.is_completed' is true
        else 'user_task_history.due_date asc' %}

    select
        user_id,
        user_name,
        email,
        task_id,
        task_name,
        task_projects,
        task_tags,
        is_completed,
        completed_at,
        due_date,

        -- row number should be 1 for both
        row_number() over(partition by user_id, is_completed order by {{ date_comparison }}) as choose_one

    from user_task_history
    where is_completed or due_date is not null
     
),

next_last_user_tasks as (

    select
        user_id,
        user_name,
        email,
        {% set fields = ['task_id', 'task_name', 'task_projects', 'task_tags', 'due_date'] %}
        {% for field in fields %} 
        
        -- Max feels like a not-great way to consolidate these, but we're comparing non-null and null value always
        max ( case when is_completed then 
        {{ field }} else null end) as last_completed_{{ field }},
        max ( case when not is_completed then 
        {{ field }} else null end) as next_due_{{ field }},

        {% endfor %}

        max(completed_at) as last_completed_at

    from order_user_task_history

    where choose_one = 1
    group by 1,2,3

),

combine_task_metrics as (

    select
        next_last_user_tasks.*,
        agg_user_tasks.number_of_open_tasks,
        agg_user_tasks.number_of_tasks_completed,
        nullif(agg_user_tasks.total_days_assigned, 0) * 1.0 / nullif(agg_user_tasks.number_of_tasks_completed, 0) as avg_close_time_days

    from 
    next_last_user_tasks
    join agg_user_tasks on next_last_user_tasks.user_id = agg_user_tasks.user_id
    
)

select * from combine_task_metrics
