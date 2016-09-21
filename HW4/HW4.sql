--1 
select rev, netinc, cash
from stocks2016.fnd
where conm = 'APPLE INC'
and fyear = 2010;

--2
--Mikaela

--3
SELECT * FROM stocks2016.d2010 WHERE lpad(cusip,8,'0') = (SELECT distinct lpad(cusip,8,'0') FROM stocks2016.fnd where conm = 'APPLE INC');

--4
select *
from stocks2016.lnk
where lpad(gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')
and linktype in ('LU', 'LC')
and linkprim in ('P', 'C');

--5
select * from
(select * from stocks2016.d2010) as LHS
left join
(select * from stocks2016.lnk) as RHS
on LHS.permco = RHS.lpermco
and LHS.permno = RHS.lpermno
and LHS.retdate > RHS.linkdt
where lpad(RHS.gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')
and RHS.linkenddt = 'E';

--6
--same number of rows

--7
select count(1) from
(
select * from
(select * from stocks2016.d2010) as LHS
left join
(select *, lpad(gvkey,6,'0') as gvkey2 from stocks2016.lnk) as RHS
on LHS.permco = RHS.lpermco
and LHS.permno = RHS.lpermno
and LHS.retdate > RHS.linkdt
where lpad(RHS.gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')
and RHS.linkenddt = 'E'
) as LHS2
left join
(select * from stocks2016.fnd) as RHS2
on LHS2.gvkey2 = RHS2.gvkey;

--8
select count(1) from
(
select * from
(select * from stocks2016.d2010) as LHS
left join
(select *, lpad(gvkey,6,'0') as gvkey2 from stocks2016.lnk) as RHS
on LHS.permco = RHS.lpermco
and LHS.permno = RHS.lpermno
and LHS.retdate > RHS.linkdt
where lpad(RHS.gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')
and RHS.linkenddt = 'E'
) as LHS2
left join
(select * from stocks2016.fnd) as RHS2
on LHS2.gvkey2 = RHS2.gvkey
and LHS2.retdate between RHS2.datadate and (RHS2.datadate + interval '1 year' - interval '1 day');

--1
select count(1) from stocks2016.lnk;
select count(1) from stocks2016.fnd;
select count(1) from stocks2016.d2010;
select count(1) from stocks2016.d2011;

--2
select count(*) from stocks2016.lnk where linktype in ('LC', 'LU') and linkprim in ('P', 'C');

SELECT COUNT(*) FROM
(SELECT lpad(gvkey,6,'00') AS gvkey FROM stocks2016.lnk WHERE linktype IN ('LU','LC') AND linkprim IN ('P','C')) AS LHS
INNER JOIN
(SELECT * FROM stocks2016.fnd) AS RHS
 USING (gvkey);

SELECT COUNT(*) FROM
(SELECT * FROM stocks2016.lnk WHERE linktype IN ('LU','LC') AND linkprim IN ('P','C')) AS LHS
 INNER JOIN
(SELECT * FROM stocks2016.d2010) AS RHS
ON LHS.lpermno=RHS.permno AND LHS.lpermco=RHS.permco;

SELECT COUNT(*) FROM
(SELECT * FROM stocks2016.lnk WHERE linktype IN ('LU','LC') AND linkprim IN ('P','C')) AS LHS
 INNER JOIN
(SELECT * FROM stocks2016.d2011) AS RHS
ON LHS.lpermno=RHS.permno AND LHS.lpermco=RHS.permco;

--3
select count(*)
from stocks2016.d2010
where permno is null;

select count(1)
from
  (select count(1) as ct from
    (select permco
    from stocks2016.d2010
    group by permco, permno) as A
  group by permco) as B
where ct>1;

--4
select count(1) from stocks2016.fnd where gvkey is null;
select count(1) from stocks2016.fnd where datadate is null;

--5
select count(1), gvkey, date_part('year', datadate::date)
from stocks2016.fnd
group by 2,3
having count(1) > 1;
-- not unique anymore!

--6
select gvkey, datadate, min(nextret) as nextret from
(select gvkey, datadate from stocks2016.fnd) as LHS
left join
(select gvkey, datadate as nextret from stocks2016.fnd) as RHS
using (gvkey)
where LHS.datadate < RHS.nextret
and gvkey = '180599'
group by gvkey, datadate;

--7
create table stocks2016.gvkeyDateCrossjoin as (
select gvkey, datadate, min(nextret) as nextret from
(select gvkey, datadate from stocks2016.fnd) as LHS
left join
(select gvkey, datadate as nextret from stocks2016.fnd) as RHS
using (gvkey)
where LHS.datadate < RHS.nextret
group by gvkey, datadate
);

select * from
(select * from
(select * from 
(select * from stocks2016.d2010) as LHS
left join
(select *, lpad(gvkey,6,'0') as gvkey2 from stocks2016.lnk) as RHS
on LHS.permco = RHS.lpermco
and LHS.permno = RHS.lpermno
and LHS.retdate > RHS.linkdt
and RHS.linkenddt = 'E'
) as LHS2
left join
(
select gvkey, datadate, min(nextret) as nextret from
(select gvkey, datadate from stocks2016.fnd) as LHS
left join
(select gvkey, datadate as nextret from stocks2016.fnd) as RHS
using (gvkey)
where LHS.datadate < RHS.nextret
group by gvkey, datadate
) as RHS2
on LHS2.gvkey2 = RHS2.gvkey
) as LHS3
left join
(select * from stocks2016.fnd) as RHS3
on LHS3.gvkey2 = RHS3.gvkey;















