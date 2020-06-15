with project_history as (

    select *
    from {{ ref('asana_project_history') }}
),

project_users as (
    
    select *
    from {{ ref('asana_project_user') }}
),

project as (
    
    select *
    from {{ var('project') }}
)

select * from project_users