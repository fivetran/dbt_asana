with project_task as (
    
    select *
    from {{ ref('stg_asana_project_task') }}

),

project as (

    select *
    from {{ ref('stg_asana_project') }}

),

team_task as (
    
    select
        project.team_id,
        project.project_id,
        project_task.task_id
        
    from project_task
    join project 
        on project.project_id=project_task.project_id
    
)

select * from team_task