with team as (

    select * from {{ ref('stg_asana__team') }}
),

project as (

    select * 
    from {{ ref('asana__project') }}
),

team_join as (

    select
        team.source_relation,
        team.team_id,
        team.team_name,

        coalesce( sum(project.number_of_open_tasks), 0) as number_of_open_tasks, -- will double-count tasks in multiple projects
        coalesce( sum( project.number_of_assigned_open_tasks), 0) as number_of_assigned_open_tasks,
        coalesce( sum(project.number_of_tasks_completed), 0) as number_of_tasks_completed,
        round(avg(project.avg_close_time_days), 0) as avg_close_time_days, -- avg of project's avg
        round(avg(project.avg_close_time_assigned_days), 0) as avg_close_time_assigned_days,

        coalesce( sum(case when not project.is_archived then 1 else 0 end), 0) as number_of_active_projects,
        {{ fivetran_utils.string_agg('case when not project.is_archived then project.project_name else null end', "', '") }} as active_projects,
        coalesce( sum(case when project.is_archived then 1 else 0 end), 0) as number_of_archived_projects

    from team
    left join project on project.team_id = team.team_id
        and project.source_relation = team.source_relation

    group by 1,2,3

)

select * from team_join