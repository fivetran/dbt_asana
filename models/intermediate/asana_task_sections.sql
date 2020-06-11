with task_section as (

    select * 
    from {{ var('task_section') }}

),

section as (
    
    select * 
    from {{ var ('section') }}
),

agg_sections as (
    select 
        task_section.task_id,
        string_agg( concat("'", section.section_name, "'"), ", " ) as sections,
        count(*) as number_of_sections

    from task_section 
    join section 
        on section.section_id = task_section.section_id
    group by 1
)

select * from agg_sections