with tasks as (

    select * 
    from {{ ref('asana_task') }}
    where assignee_user_id is not null

), 

agg_user_tasks as (

    select 
    assignee_user_id as user_id,
    sum(case when not is_completed then 1 else 0 end) as number_of_open_tasks,
    sum(case when is_completed then 1 else 0 end) as number_of_tasks_completed,
    sum(case when is_completed then days_since_last_assignment else 0 end) as days_assigned_this_user -- will divde later for avg

    from  tasks

    group by 1

),

order_user_task_history as (

    {% set date_comparison = 'tasks.completed_at desc' if 'tasks.is_completed' is true
        else 'tasks.due_date asc' %}

    select
        assignee_user_id as user_id,
        -- assignee_name as user_name,
        -- assignee_email as email,
        task_id,
        task_name,
        projects as task_projects,
        teams task_teams,
        tags as task_tags,
        is_completed,
        completed_at,
        due_date,
        days_since_last_assignment as days_assigned_this_user,

        -- row number should be 1 for both
        row_number() over(partition by assignee_user_id, is_completed order by {{ date_comparison }}) as choose_one

    from tasks
    where is_completed or due_date is not null
     
),

next_last_user_tasks as (

    select
        user_id,
        -- user_name,
        -- email,
        {% set fields = ['task_id', 'task_name', 'task_projects', 'task_teams', 
                        'task_tags', 'due_date', 'days_assigned_this_user'] %}
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
    group by 1

),

combine_task_metrics as (

    select
        agg_user_tasks.user_id,
        agg_user_tasks.number_of_open_tasks,
        agg_user_tasks.number_of_tasks_completed,
        nullif(agg_user_tasks.days_assigned_this_user, 0) * 1.0 / nullif(agg_user_tasks.number_of_tasks_completed, 0) as avg_close_time_days,
        
        next_last_user_tasks.last_completed_task_id,
        next_last_user_tasks.last_completed_task_name,
        next_last_user_tasks.last_completed_days_assigned_this_user,
        next_last_user_tasks.last_completed_at,
        next_last_user_tasks.next_due_task_id,
        next_last_user_tasks.next_due_task_name,
        next_last_user_tasks.next_due_due_date,
        next_last_user_tasks.next_due_days_assigned_this_user,
        next_last_user_tasks.last_completed_task_projects,
        next_last_user_tasks.next_due_task_projects,
        next_last_user_tasks.last_completed_task_teams,
        next_last_user_tasks.next_due_task_teams,
        next_last_user_tasks.last_completed_task_tags,
        next_last_user_tasks.next_due_task_tags

    from 
    agg_user_tasks 
    left join next_last_user_tasks on next_last_user_tasks.user_id = agg_user_tasks.user_id
    
)

select * from combine_task_metrics
