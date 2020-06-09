with story as (
    
    select *
    from {{ ref('asana_task_story') }}

),

comments as (

    select * 
    from story
    where comment_content is not null

)
-- ,

-- -- maybe call this something different...
-- agg_comments as (

--     select
--     target_task_id as task_id,

--     from

)

select * from comments

-- will probably delete this?