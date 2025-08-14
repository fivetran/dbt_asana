select * 
from {{ source('asana', 'story') }}