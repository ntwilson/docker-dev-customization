Select u.id, u.code, u.display_name, f.id, f.code, f.display_name
from utility u inner join forecast_point f on (u.id = f.utility) 
where u.code like '%$(util)%' or u.display_name like '%$(util)%'
