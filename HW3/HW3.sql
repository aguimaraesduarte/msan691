--1
--a
SELECT COUNT(*) AS numrows
FROM stocks2016.d2010;
--b
SELECT count(distinct cusip) AS numcusips2010
FROM stocks2016.d2010;
--c
SELECT count(distinct cusip) AS numcusips2011
FROM stocks2016.d2011;
--d
SELECT cusip
FROM (
	SELECT cusip, COUNT(1) AS numobs
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A
WHERE numobs<50;
/*
SELECT cusip FROM stocks2016.d2010
GROUP BY cusip HAVING COUNT(1) < 50;
*/
--e
SELECT COUNT(*) AS numcusips
FROM (
	SELECT cusip, COUNT(1) AS numobs
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A
WHERE numobs<50;
/*
SELECT COUNT(1) AS ct FROM
(SELECT cusip FROM stocks2016.d2010
GROUP BY cusip HAVING COUNT(1) < 50) AS A;
*/
--f
SELECT SUM(CASE WHEN numobs<50 THEN 1 ELSE 0 END) AS less50,
       SUM(CASE WHEN numobs>100 THEN 1 ELSE 0 END) AS more100
FROM (
	SELECT cusip, COUNT(1) AS numobs
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A;
--g
SELECT CASE WHEN numobs<50 THEN 'less than 50'
	    WHEN numobs>100 THEN 'more than 100'
       END AS numtype,
       COUNT(1) AS numcusips
FROM (
	SELECT cusip, COUNT(1) AS numobs
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A
WHERE numobs<50 or numobs>100
GROUP BY numtype;
/*
SELECT numtype, COUNT(1) AS ct
FROM (SELECT cusip,
       CASE
         WHEN COUNT(1) < 50 THEN 'less than 50'
         WHEN COUNT(1) > 100 THEN 'more than 100'
         ELSE null
       END AS numtype
     FROM stocks2016.d2010
     GROUP BY cusip) AS A
WHERE numtype IS NOT null
GROUP BY numtype;
*/
--h
SELECT AVG(totvol) AS yearlyavgvol,
       CASE WHEN numdates<50 THEN 'less than 50'
            WHEN numdates>100 THEN 'more than 100'
            ELSE 'between 50 and 100'
       END AS numtype
FROM (
	SELECT cusip, SUM(vol) AS totvol, COUNT(1) AS numdates
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A
GROUP BY numtype;
--i
SELECT AVG(totvol/numdates) AS daylyavgvol,
       CASE WHEN numdates<50 THEN 'less than 50'
            WHEN numdates>100 THEN 'more than 100'
            ELSE 'between 50 and 100'
       END AS numtype
FROM (
	SELECT cusip, SUM(vol) AS totvol, COUNT(1) AS numdates
	FROM stocks2016.d2010
	GROUP BY cusip
) AS A
GROUP BY numtype;
/*
SELECT numType, AVG(sumvol) AS avgvol
FROM (SELECT cusip, SUM(vol) AS sumvol,
       CASE
         WHEN COUNT(1) < 50 THEN 'less than 50'
         WHEN COUNT(1) > 100 THEN 'more than 100'
         WHEN COUNT(1) BETWEEN 50 AND 100 THEN 'between 50 and 100'
         ELSE null
       END AS numType
     FROM stocks2016.d2010
     GROUP BY cusip) AS A
WHERE numType IS NOT null
GROUP BY numType;
*/
--j
SELECT COUNT(*) AS numpermnos
FROM (
	SELECT permno, max(vol*abs(prc)) AS maxdolvol
	FROM stocks2016.d2010
	GROUP BY permno
) AS A
WHERE maxdolvol>100000000;
/*
SELECT COUNT(DISTINCT permno) FROM stocks2016.d2010
WHERE vol*abs(prc) > 100000000;
*/
--k
SELECT COUNT(distinct CASE WHEN vol*abs(prc) > 100000000 THEN permno
                           ELSE null
                      END)*100.0 / COUNT(distinct permno) AS percentage
FROM stocks2016.d2010;

--2
--a
SELECT ROUND(ret::numeric, 3)*100 AS retpercent,
       ROUND(vol*abs(prc)::numeric, -3) AS dolvol
FROM stocks2016.d2010
WHERE ret != 'B' AND ret != 'C' AND vol*abs(prc) IS NOT null
AND md5( permno::varchar(100) ) LIKE '0%';
--b
--do in R
--c
SELECT ROUND(ret::numeric, 3)*100 AS retpercent,
       ROUND(vol*abs(prc)::numeric, -3) AS dolvol
FROM stocks2016.d2010
WHERE ret != 'B' AND ret != 'C' AND vol*abs(prc) IS NOT null
AND vol*abs(prc) > 250000000
AND ret::numeric BETWEEN -0.1 AND 0.1
AND md5(permno::varchar(100)) LIKE '0%';
--d
SELECT AVG(retpercent*retpercent)-AVG(retpercent)*AVG(retpercent) AS varretpercent,
       AVG(dolvol*dolvol)-AVG(dolvol)*AVG(dolvol) AS vardolvol
FROM(
SELECT ROUND(ret::numeric, 3)*100 AS retpercent,
       ROUND(vol*abs(prc)::numeric, -3) AS dolvol
FROM stocks2016.d2010
WHERE ret != 'B' AND ret != 'C' AND vol*abs(prc) IS NOT null
AND md5(permno::varchar(100)) LIKE '0%') AS A;
--e
SELECT (SUM(retpercent*dolvol)-COUNT(1)*AVG(retpercent)*AVG(dolvol))/(COUNT(1)-1) AS co_variance_BETWEEN_return_dollar_vol
FROM(
SELECT ROUND(ret::numeric, 3)*100 AS retpercent,
       ROUND(vol*abs(prc)::numeric, -3) AS dolvol
FROM stocks2016.d2010
WHERE ret != 'B' AND ret != 'C' AND vol*abs(prc) IS NOT null
AND md5(permno::varchar(100)) LIKE '0%') AS A;

--3
--a
SELECT data_type, COUNT(1) AS ct
FROM information_schema.columns
WHERE table_schema = 'stocks2016'
GROUP BY data_type;
--b
SELECT COUNT(distinct data_type)
FROM information_schema.columns;
--c
SELECT table_schema, data_type, COUNT(1) AS ct
FROM information_schema.columns
GROUP BY table_schema, data_type
ORDER BY table_schema; --not necessary
--d
SELECT table_schema, 
       SUM(CASE WHEN data_type = 'anyarray' THEN ct ELSE 0 END) AS anyarray,
       SUM(CASE WHEN data_type = 'inet' THEN ct ELSE 0 END) AS inet,
       SUM(CASE WHEN data_type = '"char"' THEN ct ELSE 0 END) AS char,
       SUM(CASE WHEN data_type = 'timestamp with time zone' THEN ct ELSE 0 END) AS timestamptz,
       SUM(CASE WHEN data_type = 'xid' THEN ct ELSE 0 END) AS xid,
       SUM(CASE WHEN data_type = 'name' THEN ct ELSE 0 END) AS name,
       SUM(CASE WHEN data_type = 'bytea' THEN ct ELSE 0 END) AS bytea,
       SUM(CASE WHEN data_type = 'date' THEN ct ELSE 0 END) AS date,
       SUM(CASE WHEN data_type = 'double precision' THEN ct ELSE 0 END) AS double,
       SUM(CASE WHEN data_type = 'pg_node_tree' THEN ct ELSE 0 END) AS pg_node_tree,
       SUM(CASE WHEN data_type = 'real' THEN ct ELSE 0 END) AS real,
       SUM(CASE WHEN data_type = 'interval' THEN ct ELSE 0 END) AS interval,
       SUM(CASE WHEN data_type = 'character varying' THEN ct ELSE 0 END) AS character_varying,
       SUM(CASE WHEN data_type = 'abstime' THEN ct ELSE 0 END) AS abstime,
       SUM(CASE WHEN data_type = 'bigint' THEN ct ELSE 0 END) AS bigint,
       SUM(CASE WHEN data_type = 'smallint' THEN ct ELSE 0 END) AS smallint,
       SUM(CASE WHEN data_type = 'boolean' THEN ct ELSE 0 END) AS boolean,
       SUM(CASE WHEN data_type = 'integer' THEN ct ELSE 0 END) AS integer,
       SUM(CASE WHEN data_type = 'ARRAY' THEN ct ELSE 0 END) AS ARRAY,
       SUM(CASE WHEN data_type = 'oid' THEN ct ELSE 0 END) AS oid,
       SUM(CASE WHEN data_type = 'pg_lsn' THEN ct ELSE 0 END) AS pg_lsn,
       SUM(CASE WHEN data_type = 'regproc' THEN ct ELSE 0 END) AS regproc,
       SUM(CASE WHEN data_type = 'text' THEN ct ELSE 0 END) AS text
FROM (
       SELECT table_schema, data_type, COUNT(1) AS ct
       FROM information_schema.columns
       GROUP BY table_schema, data_type
) AS A
GROUP BY table_schema;
--e
--do in R

--4
--a
SELECT dow
FROM(
SELECT CASE WHEN date_part('dow', retdate)=0 THEN 'Sunday'
            WHEN date_part('dow', retdate)=1 THEN 'Monday'
            WHEN date_part('dow', retdate)=2 THEN 'Tuesday'
            WHEN date_part('dow', retdate)=3 THEN 'Wednesday'
            WHEN date_part('dow', retdate)=4 THEN 'Thursday'
            WHEN date_part('dow', retdate)=5 THEN 'Friday'
            WHEN date_part('dow', retdate)=6 THEN 'Saturday'
       END AS dow, SUM(vol) AS sumvol
FROM stocks2016.d2010
GROUP BY dow
ORDER BY sumvol DESC LIMIT 1) AS A;
--b
SELECT dow
FROM(
SELECT CASE WHEN date_part('dow', retdate)=0 THEN 'Sunday'
            WHEN date_part('dow', retdate)=1 THEN 'Monday'
            WHEN date_part('dow', retdate)=2 THEN 'Tuesday'
            WHEN date_part('dow', retdate)=3 THEN 'Wednesday'
            WHEN date_part('dow', retdate)=4 THEN 'Thursday'
            WHEN date_part('dow', retdate)=5 THEN 'Friday'
            WHEN date_part('dow', retdate)=6 THEN 'Saturday'
       END AS dow, AVG(vol) AS avgvol
FROM stocks2016.d2010
GROUP BY dow
ORDER BY avgvol DESC LIMIT 1) AS A;
--c
SELECT dow, month
FROM(
SELECT CASE WHEN date_part('dow', retdate)=0 THEN 'Sunday'
            WHEN date_part('dow', retdate)=1 THEN 'Monday'
            WHEN date_part('dow', retdate)=2 THEN 'Tuesday'
            WHEN date_part('dow', retdate)=3 THEN 'Wednesday'
            WHEN date_part('dow', retdate)=4 THEN 'Thursday'
            WHEN date_part('dow', retdate)=5 THEN 'Friday'
            WHEN date_part('dow', retdate)=6 THEN 'Saturday'
       END AS dow,
       CASE WHEN date_part('month', retdate)=1 THEN 'January'
            WHEN date_part('month', retdate)=2 THEN 'February'
            WHEN date_part('month', retdate)=3 THEN 'March'
            WHEN date_part('month', retdate)=4 THEN 'April'
            WHEN date_part('month', retdate)=5 THEN 'May'
            WHEN date_part('month', retdate)=6 THEN 'June'
            WHEN date_part('month', retdate)=7 THEN 'July'
            WHEN date_part('month', retdate)=8 THEN 'August'
            WHEN date_part('month', retdate)=9 THEN 'September'
            WHEN date_part('month', retdate)=10 THEN 'October'
            WHEN date_part('month', retdate)=11 THEN 'November'
            WHEN date_part('month', retdate)=12 THEN 'December'
       END AS month,
       AVG(ret::FLOAT) AS avgret
FROM stocks2016.d2010
WHERE ret != 'B' AND ret != 'C'
GROUP BY dow, month
ORDER BY avgret DESC LIMIT 1) AS A;
--d
SELECT CASE WHEN date_part('dow', retdate)=0 THEN 'Sunday'
            WHEN date_part('dow', retdate)=1 THEN 'Monday'
            WHEN date_part('dow', retdate)=2 THEN 'Tuesday'
            WHEN date_part('dow', retdate)=3 THEN 'Wednesday'
            WHEN date_part('dow', retdate)=4 THEN 'Thursday'
            WHEN date_part('dow', retdate)=5 THEN 'Friday'
            WHEN date_part('dow', retdate)=6 THEN 'Saturday'
       END AS dow,
       AVG(CASE WHEN vol BETWEEN 1000000 AND 2000000 THEN vol ELSE null END) AS sum1,
       AVG(CASE WHEN vol < 1000000 or vol > 2000000 THEN vol ELSE null END) AS sum2
FROM stocks2016.d2010
GROUP BY dow