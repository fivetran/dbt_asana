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
        else 'comment' end as action_description
    
    from story

),

-- the next CTE uses this dictionary to parse the type of action out of the event descfription
{% set actions = {
    'added the name%': 'added name',
    'changed the name%': 'changed name',
    'removed the name': 'removed name',
    'added the description%': 'added description',
    'changed the description%': 'changed description',
    'removed the description': 'removed description',
    'added to%': 'added to project',
    'removed from%': 'removed from project',
    'assigned%': 'assigned',
    'unassigned%': 'unassigned',
    'changed the due date%': 'changed due date', 
    'changed the start date%due date%': 'changed due date',
    'changed the start date%': 'changed start date',
    'removed the due date%': 'removed due date',
    'removed the date range%': 'removed due date',
    'removed the start date': 'removed start date',
    'added subtask%': 'added subtask',
    'added%collaborator%': 'added collaborator',
    'moved%': 'moved to section',
    'duplicated task from%': 'duplicated this from other task',
    'marked%as a duplicate of this': 'marked other task as duplicate of this',
    'marked this a duplicate of%': 'marked as duplicate',
    'marked this task complete': 'completed',
    'completed this task': 'completed',
    'marked incomplete': 'marked incomplete',
    'marked this task as a milestone': 'marked as milestone',
    'unmarked this task as a milestone': 'unmarked as milestone',
    'marked this milestone complete': 'completed milestone',
    'completed this milestone': 'completed milestone',
    'attached%': 'attachment',
    'liked your comment': 'liked comment',
    'liked this task': 'liked task',
    'liked your attachment': 'liked attachment',
    'liked that you completed this task': 'liked completion',
    'completed the last task you were waiting on%': 'completed dependency',
    'added feedback to%': 'added feedback',
    'changed%to%': 'changed tag',
    'cleared%': 'cleared tag',
    'comment': 'comment',
    "have a task due on%": null 

} %}

parse_events as (
    select
    story_id,
    created_at,
    created_by_user_id,
    target_task_id,
    comment_content,
    case 
    {%- for key, value in actions.items() %} 
    when action_description like '{{key}}' then '{{value}}' 
    {% endfor -%}
    else action_description end as action_taken
    
    from split_comments

)

select * from parse_events
where action_taken is not null -- remove ones we don't care about, here "have a task due on%"