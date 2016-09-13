--1
--a
SELECT DISTINCT retdate
FROM stocks2016.d2010;
--b
SELECT cusip FROM stocks2016.d2010
WHERE retdate = '2010-01-11' AND cusip IN
(SELECT cusip FROM stocks2016.d2010
WHERE retdate = '2010-12-01')
ORDER BY vol ASC
LIMIT 1;
--c
SELECT cusip FROM stocks2016.d2010
WHERE retdate = '2010-01-11' AND cusip IN
(SELECT cusip FROM stocks2016.d2011
WHERE retdate = '2011-12-01' AND vol BETWEEN 1000000 and 10000000)
ORDER BY vol ASC
LIMIT 5;
--d
SELECT DISTINCT permco FROM stocks2016.d2011
WHERE permco NOT IN
(SELECT DISTINCT permco FROM stocks2016.d2010);
--e
SELECT permco FROM stocks2016.d2011
WHERE vol*abs(prc) IS NOT null AND permco NOT IN
(SELECT DISTINCT permco FROM stocks2016.d2010)
ORDER BY vol*abs(prc) DESC
LIMIT 1;
--f
/*
select cusip from
(select distinct cusip, max(vol*abs(prc)) as max_dollar_volume from
(select * from stocks2016.d2011 where vol is not null and prc is not null) as A
group by cusip order by max(vol*abs(prc)) desc limit 50) as A;
*/
SELECT DISTINCT cusip FROM
(SELECT cusip FROM stocks2016.d2011
WHERE vol*abs(prc) IS NOT null
ORDER BY vol*abs(prc) DESC LIMIT 50) AS A;
--g
/*
select cusip from
(select distinct cusip, max(vol*abs(prc)) as max_dollar_volume from
(select * from stocks2016.d2011 where vol is not null and prc is not null) as A
group by cusip order by max(vol*abs(prc)) desc limit 50) as top502011
where cusip in
(select cusip from
(select distinct cusip, max(vol*abs(prc)) as max_dollar_volume from
(select * from stocks2016.d2010 where vol is not null and prc is not null) as A
group by cusip order by max(vol*abs(prc)) desc limit 100) as top1002010);
*/
SELECT DISTINCT cusip FROM
(SELECT cusip FROM stocks2016.d2010
WHERE vol*abs(prc) IS NOT null
ORDER BY vol*abs(prc) DESC LIMIT 100) AS A WHERE cusip IN
(SELECT DISTINCT cusip FROM
(SELECT cusip FROM stocks2016.d2011
WHERE vol*abs(prc) IS NOT null
ORDER BY vol*abs(prc) DESC LIMIT 50) AS B);
--h
SELECT DISTINCT permco FROM stocks2016.d2011 WHERE permco IN
(SELECT permco FROM stocks2016.d2011 WHERE vol IS NOT null AND
prc IS NOT null AND retdate = '2011-02-02' ORDER BY vol*abs(prc) DESC LIMIT 500)
AND permco IN
(SELECT permco FROM stocks2016.d2011 WHERE vol IS NOT null AND
prc IS NOT null AND retdate = '2011-02-03' ORDER BY vol*abs(prc) DESC LIMIT 500)
AND permco IN
(SELECT permco FROM stocks2016.d2011 WHERE vol IS NOT null AND
prc IS NOT null AND retdate = '2011-02-04' ORDER BY vol*abs(prc) DESC LIMIT 500);
--i
SELECT DISTINCT permco FROM stocks2016.d2011 WHERE permco IN
(SELECT permco FROM stocks2016.d2011
WHERE vol BETWEEN 100000 AND 1000000 AND retdate = '2011-02-02')
AND permco IN
(SELECT permco FROM stocks2016.d2011
WHERE vol BETWEEN 100000 AND 1000000 AND retdate = '2011-02-03')
AND permco IN
(SELECT permco FROM stocks2016.d2011
WHERE vol > 5000000 AND retdate = '2011-02-04');

--2
--a
SELECT tic FROM stocks2016.fnd
WHERE fyear = 2011 AND netinc BETWEEN 20 AND 30 AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2010);
--b
SELECT tic FROM stocks2016.fnd
WHERE fyear = 2011 AND emp > 25 AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/rev > .2 AND rev <> 0);
--c
SELECT tic FROM stocks2016.fnd
WHERE netinc/rev > .3 AND rev <> 0 AND fyear = 2011 AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/rev > .2 AND rev <> 0 AND fyear = 2010);
--d
SELECT tic, netinc/rev AS profit_margin FROM stocks2016.fnd
WHERE emp > 1 AND fyear = 2011 AND rev <> 0
AND netinc/rev IS NOT null AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2010)
ORDER BY profit_margin DESC LIMIT 1;
--e
SELECT netinc/rev AS profit_margin FROM stocks2016.fnd
WHERE fyear = 2011 AND emp > 1 AND rev <> 0
AND netinc/rev IS NOT null AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2010)
ORDER BY profit_margin ASC LIMIT 1;
--f
SELECT tic, netinc/rev AS profit_margin FROM stocks2016.fnd
WHERE fyear = 2011 AND emp BETWEEN 1 AND 2 AND rev <> 0
AND netinc/emp IS NOT null AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2010)
ORDER BY profit_margin DESC LIMIT 1;
--g
SELECT tic FROM stocks2016.fnd
WHERE fyear = 2011 AND invt > 0 AND rev/invt IS NOT null AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE rev BETWEEN 1 AND 2 AND fyear = 2010)
ORDER BY rev/invt DESC LIMIT 1;
--h
SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2010
AND rev/invt BETWEEN 1 AND 2 AND invt > 0;
--i
SELECT tic FROM stocks2016.fnd
WHERE netinc/emp > 1 AND emp > 0 AND fyear = 2011 AND tic IN
(SELECT tic FROM stocks2016.fnd
WHERE rev/invt BETWEEN 1 AND 2 AND invt > 0 AND fyear = 2010);
--j
SELECT conm FROM stocks2016.fnd
WHERE fyear = 2010 AND netinc/rev > .2 AND rev <> 0
AND rev/invt > 2 AND invt > 0 AND emp > 10;

--3
--a
SELECT conm, tic, rev, invt, emp,
CASE
  WHEN invt > 0 AND rev/invt > 2 THEN 1
  ELSE 0
END AS turnflag
FROM stocks2016.fnd
WHERE fyear = 2010 AND rev > 0 AND invt > 0 AND emp > 0 AND conm IN
(SELECT conm FROM stocks2016.fnd
WHERE rev > 0 AND invt > 0 AND emp > 0 AND fyear = 2011);
--b
SELECT conm, tic, rev, invt, emp,
CASE
  WHEN invt > 0 AND rev/invt BETWEEN 2 AND 3 THEN 1
  WHEN invt > 0 AND rev/invt BETWEEN 3 AND 4 THEN 2
  WHEN invt > 0 AND rev/invt > 4 THEN 5
  ELSE 0
END AS invtflag,
CASE
  WHEN rev <> 0 AND netinc/rev < .2 AND invt > 0 AND rev/invt > 2 THEN 1
  WHEN rev <> 0 AND netinc/rev > .4 AND invt > 0 AND rev/invt > 2 THEN 2
  ELSE 0
END AS invtProfit,
CASE
  WHEN rev <> 0 AND netinc/rev BETWEEN .2 AND .4 AND emp > 10 THEN 0
  WHEN rev <> 0 AND netinc/rev < .2 THEN netinc/rev
  WHEN rev <> 0 AND netinc/rev > .4 AND emp IS NOT null THEN 2*emp
  ELSE -1
END AS EmployeeProfit
FROM stocks2016.fnd
WHERE fyear = 2010 OR fyear = 2011;
