--1 
select rev, netinc, cash
from stocks2016.fnd
where conm = 'APPLE INC'
and fyear = 2010;

--2
--Mikaela

--3
SELECT *
FROM stocks2016.d2010
WHERE lpad(cusip,8,'0') = (SELECT distinct lpad(cusip,8,'0')
  FROM stocks2016.fnd
  WHERE conm = 'APPLE INC');

--4
select *
from stocks2016.lnk
where lpad(gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')
and linktype in ('LU', 'LC')
and linkprim in ('P', 'C');

--5
SELECT *
FROM stocks2016.d2010 AS lhs
LEFT JOIN (SELECT gvkey,liid, linkdt, CASE WHEN linkenddt = 'E' THEN now()::TEXT ELSE linkenddt END, linkprim, linktype, lpermco, lpermno, usedflag FROM stocks2016.lnk) AS rhs
   ON lhs.permno = rhs.lpermno AND lhs.permco = rhs.lpermco
       AND date_part('epoch',lhs.retdate) BETWEEN date_part('epoch',linkdt) AND date_part('epoch', linkenddt::DATE)
WHERE lpad(RHS.gvkey,6,'0') = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC');

--6
--same number of rows

--7
SELECT count(1) FROM
(SELECT * FROM
  stocks2016.d2010
  LEFT JOIN
  (SELECT lpad(gvkey,6,'0') AS gvkey2,liid, linkdt, CASE WHEN linkenddt = 'E' THEN now()::TEXT ELSE linkenddt END, linkprim, linktype, lpermco, lpermno, usedflag FROM stocks2016.lnk) AS RHS
  ON stocks2016.d2010.permno = RHS.lpermno
    AND stocks2016.d2010.permco = RHS.lpermco
    AND date_part('epoch',retdate) BETWEEN date_part('epoch',linkdt) AND date_part('epoch', linkenddt::DATE)
WHERE  RHS.gvkey2 = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')) AS LHS
LEFT JOIN
stocks2016.fnd
ON LHS.gvkey2 = stocks2016.fnd.gvkey;

--8
SELECT count(1) FROM
(SELECT * FROM
  stocks2016.d2010
  LEFT JOIN
  (SELECT lpad(gvkey,6,'0') AS gvkey2,liid, linkdt, CASE WHEN linkenddt = 'E' THEN now()::TEXT ELSE linkenddt END, linkprim, linktype, lpermco, lpermno, usedflag FROM stocks2016.lnk) AS RHS
  ON stocks2016.d2010.permno = RHS.lpermno
    AND stocks2016.d2010.permco = RHS.lpermco
    AND date_part('epoch',retdate) BETWEEN date_part('epoch',linkdt) AND date_part('epoch', linkenddt::DATE)
WHERE  RHS.gvkey2 = (select distinct gvkey from stocks2016.fnd where conm = 'APPLE INC')) AS LHS
LEFT JOIN
stocks2016.fnd
ON LHS.gvkey2 = stocks2016.fnd.gvkey
 AND date_part('epoch', LHS.retdate)
 BETWEEN date_part('epoch', stocks2016.fnd.datadate) AND date_part('epoch', stocks2016.fnd.datadate)+31536000-86400;



















--7
SELECT gvkey2 AS gvkey, permno, permco, cash, emp, netinc, rev,
       fnddt, tic, conm, prc, ret, vol, shrout
FROM
 (SELECT * FROM
 (SELECT * FROM
 stocks2016.d2010
       LEFT JOIN
 (SELECT *, lpad(gvkey, 6, '0') AS gvkey2 FROM stocks2016.lnk
 WHERE linktype IN ('LU', 'LC') AND linkprim IN ('P', 'C')
 AND date_part('year', linkdt) <= 2010
 AND (linkenddt = 'E' OR ((LEFT(linkenddt, 4))::FLOAT >= 2010 AND linkenddt != 'E'))) AS RHS
 ON stocks2016.d2010.permno = RHS.lpermno AND stocks2016.d2010.permco = RHS.lpermco) AS LHS2
     LEFT JOIN
 (SELECT gvkey AS gvkey3, datadate, min(nextret) AS nextret FROM
   (SELECT gvkey, datadate FROM stocks2016.fnd) AS LHS
       LEFT JOIN
   (SELECT gvkey, datadate AS nextret FROM stocks2016.fnd) AS RHS
   USING (gvkey)
   WHERE LHS.datadate < RHS.nextret
   GROUP BY gvkey, datadate) AS RHS2
 ON LHS2.gvkey2 = RHS2.gvkey3) AS LHS3
   LEFT JOIN
 (SELECT cash, emp, netinc, rev, datadate AS fnddt, tic, conm, gvkey AS gvkey4
 FROM stocks2016.fnd) AS RHS3
ON LHS3.gvkey2 = RHS3.gvkey4;
