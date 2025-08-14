{{ config(enabled=var('asana__using_tags', True)) }}

select * 
from {{ source('asana', 'tag') }}