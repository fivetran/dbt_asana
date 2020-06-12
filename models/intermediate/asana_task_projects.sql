with task_project as (

    select * 
    from {{ var('project_task') }}

),

project as (
    
    select * 
    from {{ var ('project') }}
),

agg_projects as (
    select 
        task_project.task_id,
        string_agg( concat("'", project.project_name, "': ", project.project_id), ", " ) as projects,
        count(*) as number_of_projects

    from task_project 
    join project 
        on project.project_id = task_project.project_id
    group by 1
)

select * from agg_projects