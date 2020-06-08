with story as (
    
    select *
    from {{ ref('asana_task_stories') }}

),

comments as (

    select * 
    from story
    where comment_content is not null

)

select * from comments

-- will probably delete this?