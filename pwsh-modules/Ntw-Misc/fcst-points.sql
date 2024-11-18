Select u.id as utilID, u.code as utilCode, u.display_name as utilName, f.id as fpID, f.code as fpCode, f.display_name as fpName
from utility u inner join forecast_point f on (u.id = f.utility) 
where u.code like '%$(util)%' or u.display_name like '%$(util)%'
