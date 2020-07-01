with comments as (
    
    select *
    from {{ ref('asana_task_story') }}
    where comment_content is not null

),

task_conversation as (

    select
        target_task_id as task_id,
        -- creates a chronologically ordered conversation about the task
        -- need to use string agg macro here
        string_agg(concat(cast(created_at as string), '  -  ', created_by_name, ':  ', comment_content), '\n' order by created_at asc) as conversation,
        count(*) as number_of_comments,
        count(distinct created_by_user_id) as number_of_authors 

    from comments        
    group by 1
)

select * from task_conversation
