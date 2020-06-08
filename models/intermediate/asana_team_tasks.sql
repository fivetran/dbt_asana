with project_tasks as (
    
    select *
    from {{ ref('stg_asana_project_task') }}

),

project as (

    select *
    from {{ ref('stg_asana_project') }}

),

team_tasks as (
    
    select
        project.team_id,
        project.project_id,
        project_tasks.task_id
        
    from project_tasks
    join project 
        on project.project_id=project_tasks.project_id
    
)

select * from team_tasks