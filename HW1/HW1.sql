--3
SELECT *
FROM stocks2016.d2010
WHERE cusip = '45920010';

SELECT *
FROM stocks2016.d2010
WHERE cusip = '45920010'
	AND retdate = '2010-01-07';

SELECT bid-ask AS difference
FROM stocks2016.d2010
WHERE cusip = '45920010'
	AND retdate = '2010-01-07';

SELECT retdate
FROM stocks2016.d2010
WHERE cusip = '45920010'
	AND vol < 5000000
	AND bid > 140;

--4
SELECT shrout*prc AS market_capitalization
FROM stocks2016.d2010
WHERE permno = 14593
	AND retdate = '2010-02-01';

SELECT permno, shrout*prc AS market_capitalization
FROM stocks2016.d2010
WHERE shrout*prc IS NOT null
ORDER BY market_capitalization DESC
LIMIT 5;

SELECT permno, shrout*prc AS market_capitalization
FROM stocks2016.d2010
WHERE shrout*prc IS NOT null
	AND retdate = '2010-02-03'
ORDER BY market_capitalization DESC
LIMIT 5;

SELECT permno, shrout*prc AS market_capitalization
FROM stocks2016.d2010
ORDER BY market_capitalization ASC
LIMIT 5;

SELECT permno, shrout*prc AS market_capitalization
FROM stocks2016.d2010
WHERE retdate = '2010-02-03'
	AND vol < 10000000
ORDER BY market_capitalization ASC
LIMIT 5;

--5
SELECT permno
FROM stocks2016.d2010
WHERE vol < 25000
ORDER BY abs(bid-ask) ASC
LIMIT 1;

SELECT permno
FROM stocks2016.d2010
WHERE retdate = '2010-02-08'
	AND shrout > 500000
ORDER BY abs(bid-ask) ASC
LIMIT 1;

SELECT permno, abs(bid-ask) AS spread
FROM stocks2016.d2010
WHERE vol < 1000
ORDER BY spread ASC
LIMIT 1;

--6
SELECT tic
FROM stocks2016.fnd
WHERE netinc IS NOT null
ORDER BY netinc DESC
LIMIT 1;

SELECT tic
FROM stocks2016.fnd
WHERE fyear = 2011
	AND netinc IS NOT null
ORDER BY netinc DESC
LIMIT 1;

SELECT tic
FROM stocks2016.fnd
ORDER BY netinc ASC
LIMIT 1;

SELECT tic
FROM stocks2016.fnd
WHERE fyear = 2011
ORDER BY netinc ASC
LIMIT 1;

SELECT tic
FROM stocks2016.fnd
WHERE emp > 1
	AND fyear = 2011
	AND netinc IS NOT null
ORDER BY netinc/emp DESC
LIMIT 1;

SELECT tic
FROM stocks2016.fnd
WHERE emp > 0
	AND netinc/emp > 1
ORDER BY emp DESC
LIMIT 1;




