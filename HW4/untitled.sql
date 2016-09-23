SELECT permno, permco,
 (MAX(prc_last)-MAX(prc_first))/MAX(prc_first) AS yearly_ret2011
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
     MIN(date_part('epoch', retdate)) AS retdate_first,
     MAX(date_part('epoch', retdate)) AS retdate_last
   FROM stocks2016.d2010
   WHERE prc IS NOT null --gets the first AND last dates that are not null
   GROUP BY permno, permco) AS RHS
 USING (permno, permco)
 WHERE retdate_epoch = retdate_first OR retdate_epoch = retdate_last) AS A
GROUP BY permno, permco;