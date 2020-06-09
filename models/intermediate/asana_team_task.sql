with project_task as (
    
    select *
    from {{ ref('stg_asana_project_task') }}

),

project as (

    select *
    from {{ ref('stg_asana_project') }}

),

team as (

    select *
    from {{ ref('stg_asana_team') }}

),

team_task as (
    
    select
        project.team_id,
        team.team_name,
        project.project_id,
        project_task.task_id
        
    from project_task
    join project 
        on project.project_id = project_task.project_id
    join team on project.team_id = team.team_id
    
)

select * from team_task