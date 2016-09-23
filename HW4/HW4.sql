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









--1
--a
select retdate, avg(ret::FLOAT) as equal_weighted_return
from stocks2016.d2010
where ret not in ('B', 'C')
group by retdate
order by 1;

--b
SELECT avg((ret::FLOAT)*vol*abs(prc)) AS mrkt_ret, retdate
FROM stocks2016.d2010
WHERE ret NOT IN ('B', 'C')
GROUP BY retdate;

--c
SELECT mrkt_ret, retdate FROM
 (SELECT avg((ret::FLOAT)*vol*abs(prc)) AS mrkt_ret, retdate
 FROM stocks2016.d2010
 WHERE ret NOT IN ('B', 'C')
 GROUP BY retdate) AS A
WHERE retdate = '2010-01-21';

--d
SELECT avg((ret::FLOAT)) AS avgret,
 avg((ret::FLOAT)*vol*abs(prc)) AS mrkt_ret, retdate
FROM stocks2016.d2010
WHERE ret NOT IN ('B', 'C')
GROUP BY retdate;

--e
SELECT permno, permco FROM
 (SELECT permno, permco, ret, retdate
 FROM stocks2016.d2010) AS LHS
LEFT JOIN
 (SELECT avg((ret::FLOAT)) AS avgret, retdate
 FROM stocks2016.d2010
 WHERE ret NOT IN ('B', 'C')
 GROUP BY retdate) AS RHS
USING (retdate)
WHERE ret NOT IN ('B', 'C') AND (ret::FLOAT) > avgret
GROUP BY permno, permco
HAVING count(1) > 150;

--f
SELECT permno, permco, max((ret::FLOAT))-min((ret::FLOAT)) AS diff_ret
FROM stocks2016.d2010
WHERE ret NOT IN ('B', 'C')
GROUP BY permno, permco
ORDER BY 3 DESC
LIMIT 1;

--g
SELECT abs(avg((ret::FLOAT))-avg((ret::FLOAT)*vol*abs(prc))), retdate
FROM stocks2016.d2010
WHERE ret NOT IN ('B', 'C')
GROUP BY retdate
ORDER BY 1 DESC
LIMIT 1;

--2
select count(*)
from
(select date_part('MONTH', retdate) AS month, date_part('DAY', retdate) AS day, ret::float as ret_2010
from stocks2016.d2011
where ret not in ('B', 'C')) as LHS 
inner join
(select date_part('MONTH', retdate) AS month, date_part('DAY', retdate) AS day, avg(ret::float) as avg_ret_2011
from stocks2016.d2010
where ret not in ('B', 'C')
group by 1,2) as RHS
using(month, day)
where ret_2010 > avg_ret_2011;
--634986

select count(*)
from
(select date_part('MONTH', retdate) AS month, date_part('DAY', retdate) AS day, ret::float as ret_2011
from stocks2016.d2010
where ret not in ('B', 'C')) as LHS 
inner join
(select date_part('MONTH', retdate) AS month, date_part('DAY', retdate) AS day, avg(ret::float) as avg_ret_2010
from stocks2016.d2011
where ret not in ('B', 'C')
group by 1,2) as RHS
using(month, day)
where ret_2011 > avg_ret_2010;
--648775

--3
 SELECT ctinner::FLOAT/ctall as percentage FROM
(SELECT COUNT(DISTINCT retdate) as ctall FROM stocks2016.d2010)AS LHS1
CROSS JOIN
 (SELECT COUNT(1) as ctinner FROM
(SELECT DISTINCT(retdate)AS retdate FROM stocks2016.d2010 ORDER BY 1) AS LHS
INNER JOIN
 (SELECT retdate-365 AS retdate FROM
   (SELECT DISTINCT(retdate)FROM stocks2016.d2011 ORDER BY 1) AS TEMP)AS RHS
USING(retdate)) AS RHS;