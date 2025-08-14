select * 
from {{ source('asana', 'user') }}
