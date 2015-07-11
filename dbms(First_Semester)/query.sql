Create Temp
------------

create view temp
as
  SELECT event_id,wedding_id,service_code,event_date,if(vegiterian is null,1,vegiterian) Vegiterian,if(non_vegiterian is null,1,non_vegiterian) Non_Vegiterian
  FROM event_booking e
  where wedding_id=
                  (select wedding_id from master_wed where wedding_id='W1');


see All Services which were used in a particular wedding
___________________________________________

select t.wedding_id,em.event_name,s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
order by t.event_date asc,em.event_name;


Engagement Ceremony Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E1';

Mehendi Celebration Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E2';


Sengeet Party Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E3';


Tilak Ceremony Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E4';


Mandap Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E5';



Var Mala Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E6';

Vidaai Ceremony Services and Charges
-----------------------------------------

select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E7';


Dinner Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E9';




Reception Services and Charges
-----------------------------------------
select s.service_name,t.vegiterian*t.non_vegiterian*(s.charges) charges
from temp t
join service_list s
on(s.service_code=t.service_code)
join event_master em
on (em.event_id=t.event_id)
where em.event_id='E8';




Total Estimated Cost
---------------------
SELECT  ifnull(Event_Name,'TOTAL') as "Event NAME",sum(charges) CHARGES
FROM estimated_cost
group by (Event_Name) with rollup;









