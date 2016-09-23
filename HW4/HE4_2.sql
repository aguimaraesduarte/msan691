--4
select permno, permco, abs(yearly_return_2010-yearly_return_2011) as reversechange
from
(SELECT permno, permco, abs((lstdayprc-frtdayprc)/frtdayprc) AS yearly_return_2010
FROM(
SELECT
 permno, permco,
 SUM(CASE WHEN frtday=retdate THEN prc ELSE 0 END) AS frtdayprc,
 SUM(CASE WHEN lstday=retdate THEN prc ELSE 0 END) AS lstdayprc
FROM(
SELECT * FROM
(SELECT permno, permco, min(retdate) as frtday, max(retdate) as lstday from stocks2016.d2010
where prc is not null
GROUP BY 1,2) AS LLHS
LEFT JOIN
(SELECT permno, permco, prc, retdate from stocks2016.d2010) AS LRHS
USING(permno, permco)
WHERE(LRHS.retdate=LLHS.frtday OR LRHS.retdate=LLHS.lstday)
) AS TEMP
GROUP BY 1,2
) AS TEMP2
WHERE frtdayprc!=0) AS LLLHS
inner join
(SELECT permno, permco, abs((lstdayprc-frtdayprc)/frtdayprc) AS yearly_return_2011
FROM(
SELECT
 permno, permco,
 SUM(CASE WHEN frtday=retdate THEN prc ELSE 0 END) AS frtdayprc,
 SUM(CASE WHEN lstday=retdate THEN prc ELSE 0 END) AS lstdayprc
FROM(
SELECT * FROM
(SELECT permno, permco, min(retdate) as frtday, max(retdate) as lstday from stocks2016.d2011
where prc is not null
GROUP BY 1,2) AS RLHS
LEFT JOIN
(SELECT permno, permco, prc, retdate from stocks2016.d2011) AS RRHS
USING(permno, permco)
WHERE(RRHS.retdate=RLHS.frtday OR RRHS.retdate=RLHS.lstday)
) AS TEMP
GROUP BY 1,2
) AS TEMP2
WHERE frtdayprc!=0) AS RRRHS
using (permno, permco)
order by 3 desc
limit 5;

--5
SELECT LHS_tic AS tic,
 sum(CASE
   WHEN RHS_tic < LHS_tic THEN 1
   ELSE 0
 END) AS num_before
FROM
 (SELECT * FROM
   (SELECT DISTINCT tic AS LHS_tic FROM stocks2016.fnd
   WHERE tic IS NOT null AND fyear = 2010) AS LHS
 CROSS JOIN
   (SELECT DISTINCT tic AS RHS_tic FROM stocks2016.fnd
   WHERE tic IS NOT null AND fyear = 2010) AS RHS) AS A
GROUP BY 1
ORDER BY 1;

--6
SELECT count(1) FROM
 (SELECT permno, permco, retdate_month,
     (max(prc_last)-max(prc_first))/max(prc_first) AS monthly_ret
 FROM
   (SELECT *,
     CASE
       WHEN retdate_epoch = month_first THEN prc
     END AS prc_first,
     CASE
       WHEN retdate_epoch = month_last THEN prc
     END AS prc_last
   FROM
     (SELECT permno AS permno1, permco AS permco1, prc,
       date_part('epoch', retdate) AS retdate_epoch
     FROM stocks2016.d2010) AS LHS
   LEFT JOIN
     (SELECT permno, permco, date_part('month', retdate) AS retdate_month,
       min(date_part('epoch', retdate)) AS month_first,
       max(date_part('epoch', retdate)) AS month_last
     FROM stocks2016.d2010
     GROUP BY 1,2,3) AS RHS
   ON LHS.permco1 = RHS.permco AND LHS.permno1 = RHS.permno
   WHERE retdate_epoch = month_first OR retdate_epoch = month_last) AS A
 GROUP BY 1,2,3) AS LHS2
LEFT JOIN
 (SELECT permno, permco, max(monthly_ret) AS monthly_ret, count(1) AS ct
 FROM
   (SELECT permno, permco, retdate_month,
     (max(prc_last)-max(prc_first))/max(prc_first) AS monthly_ret
   FROM
     (SELECT *,
       CASE
         WHEN retdate_epoch = month_first THEN prc
       END AS prc_first,
       CASE
         WHEN retdate_epoch = month_last THEN prc
       END AS prc_last
     FROM
       (SELECT permno AS permno1, permco AS permco1, prc,
         date_part('epoch', retdate) AS retdate_epoch
       FROM stocks2016.d2010) AS LHS
     LEFT JOIN
       (SELECT permno, permco, date_part('month', retdate) AS retdate_month,
         min(date_part('epoch', retdate)) AS month_first,
         max(date_part('epoch', retdate)) AS month_last
       FROM stocks2016.d2010
       GROUP BY 1,2,3) AS RHS
     ON LHS.permco1 = RHS.permco AND LHS.permno1 = RHS.permno
     WHERE retdate_epoch = month_first OR retdate_epoch = month_last) AS A
   GROUP BY 1,2,3) AS B
 GROUP BY permno, permco) AS RHS2
USING (permno, permco, monthly_ret)
WHERE ct IS NOT null AND retdate_month = 1;

--7
SELECT
 sum(CASE
   WHEN monthly_ret2 > monthly_ret AND monthly_ret2 IS NOT null THEN 1
   ELSE 0
 END)*1.0/count(1) AS probability
FROM
 (SELECT permno, permco, retdate_month,
       (max(prc_last)-max(prc_first))/max(prc_first) AS monthly_ret
 FROM
   (SELECT *,
     CASE
       WHEN retdate_epoch = month_first THEN prc
     END AS prc_first,
     CASE
       WHEN retdate_epoch = month_last THEN prc
     END AS prc_last
   FROM
     (SELECT permno AS permno1, permco AS permco1, prc,
       date_part('epoch', retdate) AS retdate_epoch
     FROM stocks2016.d2010) AS LHS
   LEFT JOIN
     (SELECT permno, permco, date_part('month', retdate) AS retdate_month,
       min(date_part('epoch', retdate)) AS month_first,
       max(date_part('epoch', retdate)) AS month_last
     FROM stocks2016.d2010
     GROUP BY 1,2,3) AS RHS
   ON LHS.permco1 = RHS.permco AND LHS.permno1 = RHS.permno
   WHERE retdate_epoch = month_first OR retdate_epoch = month_last) AS A
 GROUP BY 1,2,3) AS LHS
LEFT JOIN
 (SELECT permno, permco, retdate_month-1 AS retdate_month,
       (max(prc_last)-max(prc_first))/max(prc_first) AS monthly_ret2
 FROM
   (SELECT *,
     CASE
       WHEN retdate_epoch = month_first THEN prc
     END AS prc_first,
     CASE
       WHEN retdate_epoch = month_last THEN prc
     END AS prc_last
   FROM
     (SELECT permno AS permno1, permco AS permco1, prc,
       date_part('epoch', retdate) AS retdate_epoch
     FROM stocks2016.d2010) AS LHS
   LEFT JOIN
     (SELECT permno, permco, date_part('month', retdate) AS retdate_month,
       min(date_part('epoch', retdate)) AS month_first,
       max(date_part('epoch', retdate)) AS month_last
     FROM stocks2016.d2010
     GROUP BY 1,2,3) AS RHS
   ON LHS.permco1 = RHS.permco AND LHS.permno1 = RHS.permno
   WHERE retdate_epoch = month_first OR retdate_epoch = month_last) AS A
 GROUP BY 1,2,3) AS RHS
USING (permno, permco, retdate_month);


--8
SELECT permno, permco, 365-days_before-numdays AS missing_numdays
FROM
 (SELECT *,
   (first_date-date_part('epoch', '2010-01-01'::date))/86400 AS days_before
 FROM
   (SELECT permno, permco, count(1) AS numdays
   FROM stocks2016.d2010
   GROUP BY permno, permco) AS LHS
 LEFT JOIN
   (SELECT permno, permco, min(date_part('epoch', retdate)) AS first_date
   FROM stocks2016.d2010
   GROUP BY permno, permco) AS RHS
 USING (permno, permco)) AS A;

--9
--a
SELECT avg((ret::FLOAT)) AS avgret, retdate
FROM stocks2016.d2010
WHERE ret NOT IN ('B', 'C')
GROUP BY retdate
HAVING sum(vol) > 0;

SELECT avg((ret::FLOAT)) AS avgret, retdate
FROM stocks2016.d2011
WHERE ret NOT IN ('B', 'C')
GROUP BY retdate
HAVING sum(vol) > 0;

--b
SELECT permno, permco,
(avg(ret*avgret)-(avg(ret)*avg(avgret)))/(sqrt(avg(ret^2)-(avg(ret)*avg(ret)))*sqrt(avg(avgret^2)-(avg(avgret)*avg(avgret)))) AS correlation
FROM
 (SELECT * FROM
   (SELECT permno, permco, (ret::FLOAT) AS ret, retdate
   FROM stocks2016.d2010
   WHERE ret NOT IN ('B', 'C')) AS LHS
 LEFT JOIN
   (SELECT avg((ret::FLOAT)) AS avgret, retdate
   FROM stocks2016.d2010
   WHERE ret NOT IN ('B', 'C')
   GROUP BY retdate
   HAVING sum(vol) > 0) AS RHS
 USING (retdate)
 ORDER BY permno, permco) AS A
GROUP BY permno, permco;

SELECT permno, permco,
 (avg(ret*avgret)-(avg(ret)*avg(avgret)))/(sqrt(avg(ret^2)-(avg(ret)*avg(ret)))*sqrt(avg(avgret^2)-(avg(avgret)*avg(avgret)))) AS correlation
FROM
 (SELECT * FROM
   (SELECT permno, permco, (ret::FLOAT) AS ret, retdate
   FROM stocks2016.d2011
   WHERE ret NOT IN ('B', 'C')) AS LHS
 LEFT JOIN
   (SELECT avg((ret::FLOAT)) AS avgret, retdate
   FROM stocks2016.d2011
   WHERE ret NOT IN ('B', 'C')
   GROUP BY retdate
   HAVING sum(vol) > 0) AS RHS
 USING (retdate)
 ORDER BY permno, permco) AS A
GROUP BY permno, permco;

--c
SELECT permno, permco,
 (max(prc_last)-max(prc_first))/max(prc_first) AS yearly_ret2010
FROM
 (SELECT *,
   CASE
     WHEN retdate_epoch = retdate_first THEN prc
   END AS prc_first,
   CASE
     WHEN retdate_epoch = retdate_last THEN prc
   END AS prc_last
 FROM
   (SELECT permno, permco, prc,
     date_part('epoch', retdate) AS retdate_epoch
   FROM stocks2016.d2010) AS LHS
 LEFT JOIN
   (SELECT permno, permco,
     min(date_part('epoch', retdate)) AS retdate_first,
     max(date_part('epoch', retdate)) AS retdate_last
   FROM stocks2016.d2010
   WHERE prc IS NOT null --gets the first and last dates that are not null
   GROUP BY permno, permco) AS RHS
 USING (permno, permco)
 WHERE retdate_epoch = retdate_first OR retdate_epoch = retdate_last) AS A
GROUP BY permno, permco;

SELECT permno, permco,
 (max(prc_last)-max(prc_first))/max(prc_first) AS yearly_ret2011
FROM
 (SELECT *,
   CASE
     WHEN retdate_epoch = retdate_first THEN prc
   END AS prc_first,
   CASE
     WHEN retdate_epoch = retdate_last THEN prc
   END AS prc_last
 FROM
   (SELECT permno, permco, prc,
     date_part('epoch', retdate) AS retdate_epoch
   FROM stocks2016.d2011) AS LHS
 LEFT JOIN
   (SELECT permno, permco,
     min(date_part('epoch', retdate)) AS retdate_first,
     max(date_part('epoch', retdate)) AS retdate_last
   FROM stocks2016.d2011
   WHERE prc IS NOT null --gets the first and last dates that are not null
   GROUP BY permno, permco) AS RHS
 USING (permno, permco)
 WHERE retdate_epoch = retdate_first OR retdate_epoch = retdate_last) AS A
GROUP BY permno, permco;

--d

