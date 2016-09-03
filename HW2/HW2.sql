--1
--a
select distinct retdate from stocks2016.d2010;
--b
select cusip from stocks2016.d2010 where retdate = '2010-01-11' and
cusip in (select cusip from stocks2016.d2010 where retdate = '2010-12-01')
order by vol asc limit 1;
--c
select cusip from stocks2016.d2010 where retdate = '2010-01-11' and
cusip in (select cusip from stocks2016.d2011 where retdate = '2011-12-01'
and vol between 1000000 and 10000000) order by vol asc limit 5;
--d
select distinct permco from stocks2016.d2011 where permco not in (select
distinct permco from stocks2016.d2010);
--e
select permco from stocks2016.d2011 where permco not in (select
distinct permco from stocks2016.d2010) and vol is not null
order by vol desc limit 1;
--f
select distinct cusip from (select * from stocks2016.d2011 where vol is not
null order by vol desc) as A limit 50;
--g
select cusip from (
select distinct cusip from (select * from stocks2016.d2011 where vol is not
null order by vol desc) as A limit 50) as B where cusip in (
select distinct cusip from (select * from stocks2016.d2010 where vol is not
null order by vol desc) as C limit 100);
--h
select distinct permno from stocks2016.d2011 where permno in
(select permno from stocks2016.d2011 where vol is not null and
retdate = '2011-02-02' order by vol desc limit 500)
and permno in
(select permno from stocks2016.d2011 where vol is not null and
retdate = '2011-02-03' order by vol desc limit 500)
and permno in
(select permno from stocks2016.d2011 where vol is not null and
retdate = '2011-02-04' order by vol desc limit 500);
--i
select distinct permno from stocks2016.d2011 where permno in
(select permno from stocks2016.d2010 where vol between 100000
and 1000000 and retdate = '2010-02-02')
and permno in
(select permno from stocks2016.d2010 where vol between 100000
and 1000000 and retdate = '2010-02-03')
and permno in
(select permno from stocks2016.d2010 where vol > 5000000
and retdate = '2010-02-04');

--2
--a
select distinct tic from stocks2016.fnd where netinc between 20 and 30 and
fyear = 2011 and tic in (select tic from stocks2016.fnd where fyear = 2010
and emp > 0 and netinc/emp > 1);
--b
select distinct tic from stocks2016.fnd where emp > 25 and fyear = 2011
and tic in (select tic from stocks2016.fnd where fyear = 2011 and 
netinc/rev > 0.2 and rev != 0);
--c
select distinct tic from stocks2016.fnd where netinc/rev > 0.3 and
rev != 0 and fyear = 2011 and tic in (select tic from stocks2016.fnd
where netinc/rev > 0.2 and rev != 0 and fyear = 2010);
--d
select tic, netinc/rev as profit_margin from stocks2016.fnd where rev != 0
and fyear = 2011 and emp > 1 and tic in (select tic from stocks2016.fnd where 
emp > 0 and netinc/emp > 1 and fyear = 2010) order by
profit_margin desc limit 1;
--e
select netinc/rev as profit_margin from stocks2016.fnd where rev != 0
and fyear = 2011 and emp > 1 and tic in (select tic from stocks2016.fnd where 
emp > 0 and netinc/emp > 1 and fyear = 2010) order by
profit_margin asc limit 1;
--f
select tic, netinc/rev as profit_margin from stocks2016.fnd where rev != 0
and fyear = 2011 and emp between 1 and 2 and tic in (select tic from
stocks2016.fnd where emp > 0 and netinc/emp > 1 and fyear = 2010) order by
profit_margin desc limit 1;
--g
select tic from stocks2016.fnd where fyear = 2011 and invt > 0 and tic in
(select tic from stocks2016.fnd where rev between 1 and 2 and fyear = 2010)
order by rev/invt desc limit 1;
--h
select distinct tic from stocks2016.fnd where fyear = 2010 and invt > 0 and
rev/invt between 1 and 2 and emp > 0 and netinc/emp > 1 and fyear = 2010;
--i
select distinct tic from stocks2016.fnd where tic in (select tic from
stocks2016.fnd where fyear = 2010 and invt > 0 and rev/invt between 1
and 2) and emp > 0 and netinc/emp > 1 and fyear = 2011;
--j
select distinct conm from stocks2016.fnd where fyear = 2010 and rev != 0
and netinc/rev > 0.2 and invt > 0 and rev/invt > 2 and emp > 10;

--3
--a
--select conm, tic, rev, invt, emp from stocks2016.fnd where fyear = 2010;
--b










