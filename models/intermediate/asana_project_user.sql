with project_tasks as (
    
    select *
    from {{ var('project_task') }}
),

assigned_tasks as (
    
    select * 
    from {{ var('task') }}

    where assignee_user_id is not null
    
),

project as (
    
    select *
    from {{ var('project') }}

    where not is_archived

),

project_assignee as (

    select
        project_tasks.project_id,
        project_tasks.task_id,
        assigned_tasks.assignee_user_id,
        not assigned_tasks.is_completed as currently_working_on

    from project_tasks 
    join assigned_tasks 
        on assigned_tasks.task_id = project_tasks.task_id

),

project_owner as (

    select 
        project_id,
        project_name,
        owner_user_id

    from project
    
    -- where owner_user_id is not null
),

project_user as (
    select
        project_id,
        project_name,
        owner_user_id as user_id,
        'owner' as role,
        null as currently_working_on
    
    from project_owner
    where owner_user_id is not null

    union all

    select
        project_owner.project_id,
        project_owner.project_name,
        project_assignee.assignee_user_id as user_id,
        'task assignee' as role,
        project_assignee.currently_working_on
    
    from project_owner join project_assignee 
        on project_owner.project_id = project_assignee.project_id

)


select * from project_user