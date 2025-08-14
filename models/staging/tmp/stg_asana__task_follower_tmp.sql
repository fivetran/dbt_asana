select * 
from {{ source('asana', 'task_follower') }}