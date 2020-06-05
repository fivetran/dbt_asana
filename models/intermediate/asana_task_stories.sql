with story as (
    
    select * 
    from {{ ref('stg_asana_story') }}

)
,
split_comments as (

        select
        story_id,
        created_at,
        created_by_user_id,
        target_task_id,
            
        case when event_type = 'comment' then event_description 
        else null end as comment_content,

        case when event_type = 'system' then event_description 
        else null end as action_description
    
    from story

)

select * from split_comments
