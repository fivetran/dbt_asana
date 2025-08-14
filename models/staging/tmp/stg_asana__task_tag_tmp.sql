{{ config(enabled=var('asana__using_task_tags', True)) }}

select * 
from {{ source('asana', 'task_tag') }}