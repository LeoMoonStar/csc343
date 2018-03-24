set search_path to carschema;
drop table if exists q1 cascade;


create table q1(
  customer_email VARCHAR(50),
  res_to_cancel_ratio float
);

--Get table of customer reservations
create view cust_res as select customer.email, reservation.id as res_id,
   status, old_res_id
  from customer join customer_res on customer.email = customer_res.email
  join reservation on customer_res.res_num = reservation.id;

--Get table of customers that have Completed reservations
create view completed as select email, count(*) as completed_res
  from cust_res
  where status != 'Cancelled'
  group by email;

create view cancelled as select c2.email, count(*) as cancelled_res
  from cust_res c2
  -- need to not count changed reservations
  where status = 'Cancelled' and  not exists(
    select *
    from cust_res c1
    where c1.old_res_id = c2.res_id)
  group by c2.email;

create view cancel_ratio as
  select  email, case when (completed_res is null) then cancelled_res
  when (cancelled_res is null) then 0
  else cast(cancelled_res as float)/cast(completed_res as float) end as ratio
  from cancelled natural full join completed
  order by ratio desc;

create view all_cancel_ratio as 
  select customer.email, 
  case when(select count(*) from cancel_ratio where cancel_ratio.email = customer.email) = 0 
  then 0 else cancel_ratio.ratio end as ratio, row_number() over(order by ratio desc) as rank
  from customer natural full join cancel_ratio;

create view result as select email, ratio 
  from all_cancel_ratio where rank = 1 or rank = 2
  order by ratio desc, email;

-- Currently just taking #1 and #2 with row_number

-- create view max_ratio as
--   select email, ratio
--   from all_cancel_ratio r1
--   where not exists(
--     select *
--     from all_cancel_ratio r2
--     where r2.ratio > r1.ratio
--   );

-- create view left_overs as
--   select *
--   from (cancel_ratio) except (max_ratio)

-- create view number_two as
--   select email, ratio
--   from left_overs
--   where not exists(
--     select *
--     from left_overs l1
--     where l1.ratio > ratio
--   );

  -- create view result as
  --   select *
  --   from (max_ratio) union (number_two)
  --   order by ratio desc, email;

  insert into q1 select * from result;
