with team_task_proj as (

    select *
    from {{ ref('asana_team_task_proj') }}

    group by 1,2,3,4
),

team_task as (

    select
        task_id,
        team_id,
        team_name

    from team_task_proj

    group by 1,2,3

),

agg_task_teams as (

    select 
        task_id,
        string_agg( concat("'", team_name, "'"), ", " ) as teams,
        count(*) as number_of_teams
    
    from team_task
    group by 1
)

select * from agg_task_teams
group by 1,2,3 
