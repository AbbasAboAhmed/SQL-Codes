use mavenfuzzyfactory;

-------------------------------------------------------------------------------------------------------------------------------------
-- First Assignment

select 
	utm_content
    ,count(distinct ws.website_session_id) as sessions
    ,count(o.order_id) as orders
    
    
from website_sessions ws
	left join orders o
    on ws.website_session_id = o.website_session_id
    
where ws.website_session_id between 1000 and 2000

group by utm_content
order by sessions desc;

------------------------------------------------------------------------------------------------------------------------------------
use mavenfuzzyfactory;

select 
	
    created_at
    -- ,month(created_at)
    ,week(created_at)
    ,year(created_at)
    ,count(website_session_id) Sessions

from website_sessions
where website_session_id between 100000 and 115000

group by 
	month(created_at)
    ,week(created_at)
    ,year(created_at)

order by Sessions desc;

------------------------------------------------------------------------------------------------------------------------------------

select 
	distinct primary_product_id
	,count(distinct case when items_purchased = 1 then order_id else NULL end) Number_of_p_1
	,count(distinct case when items_purchased = 2 then order_id end) Number_of_p_2
	,count(distinct case when items_purchased = 1 then order_id end) + count(distinct case when items_purchased = 2 then order_id end) Total
    ,count(distinct order_id) Total_2
    
from orders
where order_id between 31000 and 32000
group by 1;

------------------------------------------------------------------------------------------------------------------------------------
-- Secound Assignment

select 
	min(date(created_at))
    ,count(website_session_id) Sessions
from website_sessions

where created_at < "2012-5-12"
	and utm_source = "gsearch"
    and utm_campaign = "nonbrand"

group by 
	year(created_at)
	,week(created_at) ;
    
-- order by Sessions desc

------------------------------------------------------------------------------------------------------------------
-- to understand the privious solution

select 
	created_at
	,year(created_at)
	,week(created_at)
	,date(created_at)
	,Min(date(created_at))
	

from website_sessions

where created_at < "2012-5-10"
	and utm_source = "gsearch"
    and utm_campaign = "nonbrand"

group by 
	year(created_at)
	,week(created_at);

-----------------------------------------------------------------------------------------------------------------------------------

-- The 3 assignment
use mavenfuzzyfactory;

select 
	ws.device_type
    ,count(distinct ws.website_session_id) Sessions
    ,count(distinct o.order_id) orders
    ,count(distinct o.order_id) /count(distinct ws.website_session_id) Session_to_order_conv_rate

from website_sessions ws
	left join orders o
    on ws.website_session_id = o.website_session_id
    
where ws.created_at < "2012-05-11"
	and utm_source = "gsearch"
    and utm_campaign = "nonbrand"


group by
	ws.device_type;
    
-----------------------------------------------------------------------------------------------------------------------------------

-- The 4 assignment
use mavenfuzzyfactory;

select
	 min(date(ws.created_at))
    ,count(distinct case when ws.device_type = "desktop" then ws.website_session_id Else "Others" END ) desktop_Sessions
    ,count(distinct case when ws.device_type = "mobile" then ws.website_session_id Else "Others" END ) mobile_Sessions
    ,count(ws.website_session_id) 
from website_sessions ws
	left join orders o
    on ws.website_session_id = o.website_session_id

where(ws.created_at > "2012-04-15" and ws.created_at < "2012-06-9" )
	and utm_source = "gsearch"
    and utm_campaign = "nonbrand"

group by 
    year(ws.created_at)
	,week(ws.created_at)

order by 1;

-----------------------------------------------------------------------------------------------------------------------------------
--  Section_5_Assignment 3

use mavenfuzzyfactory;

select  pageview_url
	-- ,website_session_id
    ,count(distinct website_pageview_id) Sessions

from website_pageviews
where created_at < "2012-06-09"
group by pageview_url
order by Sessions desc;

-----------------------------------------------------------------------------------------------------------------------------------
--  Section_5_Assignment 4

Create Temporary Table first_pv_per_session
select 
     website_session_id
	,min(website_pageview_id) first_PV
from website_pageviews
where created_at < "2012-06-12"
group by website_session_id;

SELECT 
	wp.pageview_url as Entry_page
    ,count(fp.first_PV) Sessions_hitting_page
FROM first_pv_per_session fp
	LEFT JOIN website_pageviews wp
    on fp.first_PV = wp.website_pageview_id
group by Entry_page;

-----------------------------------------------------------------------------------------------------------------------------------
-- Section_5_Assignment 5

use mavenfuzzyfactory;

-- Section_5_Assignment 5      >> Bounce rating

-- Step 1: Find the first website_pageview_id for relevant sessions
-- step 2: identifying the landing page of each session
-- step 2: counting pageviews for each session, to identify "bounces"
-- step 2: summarizing by counting total sessions and bounced sessions

Create Temporary Table first_pageviews                              
select 
     website_session_id
	,min(website_pageview_id) first_PV
from website_pageviews
where created_at < "2012-06-14"
group by website_session_id;


Create Temporary Table sessions_w_home_landing_page
SELECT 
	fp.website_session_id
	,wp.pageview_url as Entry_page
    -- ,count(fp.first_PV) Sessions_hitting_page
FROM first_pageviews fp
	LEFT JOIN website_pageviews wp
    on fp.first_PV = wp.website_pageview_id
where wp.pageview_url = '/home';

select * from sessions_w_home_landing_page;


-- then a table to have count of pageview per session
-- then limit it to just bounced_sessions

Create Temporary Table bounced_sessions
select 
	swh.website_session_id
    ,swh.Entry_page
    ,count(wp.website_pageview_id)  count_of_page_viewed
from sessions_w_home_landing_page   swh
	left join website_pageviews wp
    on swh.website_session_id = wp.website_session_id

group by 
	swh.website_session_id
    ,swh.Entry_page
having count(wp.website_pageview_id) = 1;

/*
-- we will do this first to show what is in this query, then we will count them after:

select 
	swh.website_session_id
    ,bs.website_session_id bounced_wesite_sessions_id

from sessions_w_home_landing_page  swh
	left join bounced_sessions  bs
		on swh.website_session_id = bs.website_session_id
order by 
	swh.website_session_id
*/

-- final output for assignement_calculating _bounce_rating


select 
	count(distinct swh.website_session_id) sessions
    ,count(distinct bs.website_session_id) bounced_sessions
    ,count(distinct bs.website_session_id) / count(distinct swh.website_session_id) AS bounce_rate
    
from sessions_w_home_landing_page swh
	left join bounced_sessions  bs
		on swh.website_session_id = bs.website_session_id;

-----------------------------------------------------------------------------------------------------------------------------------

--  Section_5_Assignment 7       >>>>>>>>>>>>>   Section_5 Video 041 - 042

use mavenfuzzyfactory;

-- steo 0: find out when the new page (/lander) launch
-- Step 1: Find the first website_pageview_id for relevant sessions
-- step 2: identifying the landing page of each session
-- step 3: counting pageviews for each session, to identify "bounces"
-- step 4: summarizing by counting total sessions and bounced sessions

select 
	min(created_at) As first_create_at
    ,min(website_pageview_id) first_page_id
from website_pageviews
where  
	pageview_url = "/lander-1"
    AND created_at IS NOT NULL;
    
-- first_create_at = 2012-06-18 17:35:54
-- first_page_id = 23504

-- Step 1: Find the first website_pageview_id for relevant sessions

drop table first_test_pageviews;

create temporary table first_test_pageviews
SELECT 
     wp.website_session_id                                                       
    ,min(wp.website_pageview_id) min_page_view_id
    
FROM website_pageviews wp
	left join website_sessions ws 
    on wp.website_session_id = ws.website_session_id
    And ws.created_at < "2012-07-28"
    ANd wp.website_pageview_id > 23504
    AND ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand"
group by wp.website_session_id;


select *  from first_test_pageviews;


-- step 2: identifying the landing page of each session
-- We will bring in landing page to each session , like last time, but restricting to home or lander-1 this time


drop table nonbrand_test_sessions_w_landing_page;

create temporary table nonbrand_test_sessions_w_landing_page
select 
	ft.website_session_id
    ,wp.pageview_url AS landing_page
from first_test_pageviews ft
	join website_pageviews wp
    on ft.website_session_id = wp.website_session_id
where wp.pageview_url IN ("/home", "/lander-1");

-- select *  from nonbrand_test_sessions_w_landing_page

-- step 3: counting pageviews for each session, to identify "bounces"

-- then a table to have pageviews per session
	-- then limi it to just bounced_sessions
    
create temporary table nonbrand_bounced_sessions
select 
	nt.website_session_id
    ,nt.landing_page
    ,count(wp.website_pageview_id) AS count_of_page_viewed
from nonbrand_test_sessions_w_landing_page nt
	left join website_pageviews wp
    on nt.website_session_id = wp.website_session_id
    
group by
	nt.website_session_id
	,nt.landing_page
HAVING count(wp.website_pageview_id) = 1;

	
-- step 4: summarizing by counting total sessions and bounced sessions
         -- do this first to show,then count them after

select 
	nt.landing_page
    ,count(distinct nt.website_session_id) AS Sessions
    ,count(nb.website_session_id) As bounced_sessions
    ,count(nb.website_session_id) / count(distinct nt.website_session_id) As bounce_rate
    
from nonbrand_test_sessions_w_landing_page nt
	left join nonbrand_bounced_sessions nb
    on nt.website_session_id = nb.website_session_id

group by nt.landing_page ;

-----------------------------------------------------------------------------------------------------------------------------------

--  Section_5_Assignment 8       >>>>>>>>>>>>>> Video 043, 044

use mavenfuzzyfactory;

-- Solution is a multi-step Query

-- Step 1: Find the first website_pageview_id for relevant sessions
-- step 2: identifying the landing page of each session
-- step 3: counting pageviews for each session, to identify "bounces"
-- step 4: summarizing by week (bounce rate, sessions to each lander)

-- Step 1: Find the first website_pageview_id for relevant sessions

create temporary table sessins_w_min_view_count
SELECT 
	ws.website_session_id
    ,min(wp.website_pageview_id) as first_page_view
    ,count(wp.website_pageview_id) As count_pageviews
from website_sessions ws
	left join website_pageviews wp
    on ws.website_session_id = wp.website_session_id
where 
	ws.created_at > "2012-06-01"
    AND ws.created_at < "2012-08-31"
    AND ws.utm_source = "gsearch"
    AnD ws.utm_campaign = "nonbrand"
group by ws.website_session_id;

select * from sessins_w_min_view_count;

-- step 2: identifying the landing page of each session
create temporary table sessions_w_count_lander_and_created_at
SELECT 
	sw.website_session_id
    ,sw.first_page_view
    ,sw.count_pageviews
    ,wp.pageview_url AS landing_page
    ,wp.created_at  As sessions_created_at
    
from sessins_w_min_view_count sw
	left join website_pageviews wp
    on sw.website_session_id = wp.website_session_id
    AND wp.pageview_url IN ("/home", "/lander-1")

select * from sessions_w_count_lander_and_created_at

-- step 3: counting pageviews for each session, to identify "bounces"
create temporary table s
select 
	-- YEARWEEK(sessions_created_at)
	min(date(sessions_created_at)) AS week_start_day
    -- ,count(distinct website_session_id) AS total_sessions 
    -- ,count(distinct case when count_pageviews = 1 then website_session_id else NULL END) bounced_sessions
    ,count(distinct case when count_pageviews = 1 then website_session_id else NULL END)*1.0/count(distinct website_session_id) AS weekly_bounce_rate
    ,count(distinct case when landing_page = "/home" then website_session_id else NULL END) home_sessions
    ,count(distinct case when landing_page = "/lander-1" then website_session_id else NULL END) lander_sessions
from sessions_w_count_lander_and_created_at 
group by
	YEARWEEK(sessions_created_at);
-----------------------------------------------------------------------------------------------------------------------------------
                                      --      >>>>>>>>>>>>>>>>>>>>> section 5 video 045
use mavenfuzzyfactory;

select 
	 ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
from website_sessions ws
	left join website_pageviews wp
		on ws.website_session_id = wp.website_session_id
where ws.created_at BETWEEN "2014-01-01" AND "2014-02-01"
	  AND wp.pageview_url IN ("/lander-1","/products","/the-original-mr-fuzzy", "/cart")
order by ws.website_session_id

-- next we will put the previous query inside a subquery (similar to temporary tables)
-- we will group by website_session_id, and take max() of each of flags
-- this max() becomes a made_it flag for that session, to show the session made it there 

select 
	 website_session_id
    ,max(products_page) AS products_made_it
    ,max(fuzzy_page) AS fuzzy_made_it
    ,max(cart_page) AS cart_made_it


FROM(
select 
	 ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
from website_sessions ws
	left join website_pageviews wp
		on ws.website_session_id = wp.website_session_id
where ws.created_at BETWEEN "2014-01-01" AND "2014-02-01"
	  AND wp.pageview_url IN ("/lander-1","/products","/the-original-mr-fuzzy", "/cart")
order by ws.website_session_id
) AS pageview_level
group by website_session_id
;


-- we will turn it two a temporary tabe

create temporary table session_level_made_it_flags_demo
select 
	website_session_id
    ,max(products_page) AS products_made_it
    ,max(fuzzy_page) AS fuzzy_made_it
    ,max(cart_page) AS cart_made_it

FROM(
select 
	ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
from website_sessions ws
	left join website_pageviews wp
		on ws.website_session_id = wp.website_session_id
where ws.created_at BETWEEN "2014-01-01" AND "2014-02-01"
	  AND wp.pageview_url IN ("/lander-1","/products","/the-original-mr-fuzzy", "/cart")
order by ws.website_session_id
) AS pageview_level
group by website_session_id
;

select * from session_level_made_it_flags_demo ;

-- then we would produce the final out put (part 1)

select 
	count(distinct website_session_id) AS sessions 
    ,count( distinct case when products_made_it = 1 then website_session_id else Null END ) AS to_products
    ,count( distinct case when fuzzy_made_it then website_session_id else Null END ) AS to_fuzzy
    ,count( distinct case when cart_made_it then website_session_id else Null END ) AS to_cart

from session_level_made_it_flags_demo
limit 20000
group by website_session_id
;




-----------------------------------------------------------------------------------------------------------------------------------
--                                                               sec 5 video 046 - 047
-- Step 1: Select all pageviews for relevant sessions
-- step 2: identify each page view as a spacifc fuunel
-- step 3: create the session level conversion funnel view
-- step 4: aggregate the data ta assessfunnel performace

-- Step 1: Select all pageviews for relevant sessions

select 
	ws.website_session_id
    ,wp.pageview_url
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
	,CASE WHEN wp.pageview_url = "/shipping" then 1 else 0 end  as shipping_page
    ,CASE WHEN wp.pageview_url = "/billing" then 1 else 0 end  as billing_page
    ,CASE WHEN wp.pageview_url = "/thank-you-for-your-order" then 1 else 0 end  as thank_you_page
    
from website_pageviews wp
	join website_sessions ws
		on wp.website_session_id = ws.website_session_id
where
	wp.created_at > "2012-08-05"
	AND ws.created_at < "2012-09-05"
    AND  ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand"
order by 
	ws.website_session_id
    ,wp.created_at;


-- we will use the previos qurey as a subquery
select 
	website_session_id
	,max(products_page) products_made_it
    ,max(fuzzy_page) fuzzy_made_it
    ,max(cart_page) cart_made_it
    ,max(shipping_page) shipping_made_it
    ,max(billing_page) billing_made_it
    ,max(thank_you_page) thankyou_made_it
from(
select 
	ws.website_session_id
    ,wp.pageview_url
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
	,CASE WHEN wp.pageview_url = "/shipping" then 1 else 0 end  as shipping_page
    ,CASE WHEN wp.pageview_url = "/billing" then 1 else 0 end  as billing_page
    ,CASE WHEN wp.pageview_url = "/thank-you-for-your-order" then 1 else 0 end  as thankyou_page
    
from website_pageviews wp
	join website_sessions ws
		on wp.website_session_id = ws.website_session_id
where
	wp.created_at >= "2012-08-05"
	AND ws.created_at < "2012-09-05"
    AND  ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand"
order by 
	ws.website_session_id
    ,wp.created_at
) AS pageview_level
group by website_session_id;



	drop table 	sessions_level_made_it_flags;														-- turn it into temp table
create temporary table sessions_level_made_it_flags
select 
	website_session_id
	,max(products_page) products_made_it
    ,max(fuzzy_page) fuzzy_made_it
    ,max(cart_page) cart_made_it
    ,max(shipping_page) shipping_made_it
    ,max(billing_page) billing_made_it
    ,max(thankyou_page) thankyou_made_it
from(
select 
	ws.website_session_id
    ,wp.pageview_url
    ,CASE WHEN wp.pageview_url = "/products" then 1 else 0 end  as products_page
    ,CASE WHEN wp.pageview_url = "/the-original-mr-fuzzy" then 1 else 0 end  as fuzzy_page
    ,CASE WHEN wp.pageview_url = "/cart" then 1 else 0 end  as cart_page
	,CASE WHEN wp.pageview_url = "/shipping" then 1 else 0 end  as shipping_page
    ,CASE WHEN wp.pageview_url = "/billing" then 1 else 0 end  as billing_page
    ,CASE WHEN wp.pageview_url = "/thank-you-for-your-order" then 1 else 0 end  as thankyou_page
    
from website_pageviews wp
	join website_sessions ws
		on wp.website_session_id = ws.website_session_id
where
	wp.created_at >= "2012-08-05"
	AND ws.created_at < "2012-09-05"
    AND  ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand"
order by 
	ws.website_session_id
    ,wp.created_at
) AS pageview_level
group by website_session_id;


select * from sessions_level_made_it_flags;

select 
	count(distinct website_session_id) As sessions
	,count(distinct case when products_made_it = 1 then website_session_id else NULL end) AS to_products
    ,count(distinct case when fuzzy_made_it then website_session_id else NULL end) AS to_fuzzy
    ,count(distinct case when cart_made_it then website_session_id else NULL end) AS to_cart
    ,count(distinct case when shipping_made_it then website_session_id else NULL end) AS to_shipping
    ,count(distinct case when billing_made_it  then website_session_id else NULL end) AS to_billing
    ,count(distinct case when thankyou_made_it then website_session_id else NULL end) AS to_thank_you
from sessions_level_made_it_flags;


select 
	count(distinct website_session_id) As sessions
	,count(distinct case when products_made_it = 1 then website_session_id else NULL end) /count(distinct website_session_id) AS products_click_rt
    ,count(distinct case when fuzzy_made_it then website_session_id else NULL end) / count(distinct case when products_made_it = 1 then website_session_id else NULL end) AS to_fuzzy
    ,count(distinct case when cart_made_it then website_session_id else NULL end) / count(distinct case when fuzzy_made_it then website_session_id else NULL end) AS cart_click_rt
    ,count(distinct case when shipping_made_it then website_session_id else NULL end) / count(distinct case when cart_made_it then website_session_id else NULL end) AS shipping_click_rt
    ,count(distinct case when billing_made_it  then website_session_id else NULL end) / count(distinct case when shipping_made_it then website_session_id else NULL end) AS shipping_click_rt
    ,count(distinct case when thankyou_made_it then website_session_id else NULL end) AS thank_you_click_rt
from sessions_level_made_it_flags;

-----------------------------------------------------------------------------------------------------------------------------------
 --                                                Section_5 Video 048 - 049

use mavenfuzzyfactory;

-- steo 0: find out when the new page (/biling-2) launch
-- Step 1: Find the first website_pageview_id for relevant sessions
-- step 2: identifying the landing page of each session
-- step 3: counting pageviews for each session, to identify "bounces"
-- step 4: summarizing by counting total sessions and bounced sessions


-- steo 0: find out when the new page (/biling-2) launch
-- /billing-2 is created_at >> 2012-09-09 it's  website_pageview_id = 53550 

select 
	-min(website_pageview_id) first_time_to_launch_billing_2
     -- website_pageview_id
    ,pageview_url
    ,created_at
from website_pageviews
where 
     pageview_url = "/billing-2"
    ;
                                                                       
                                           -- find ("/billing","billing-2")                            

select
	wp.website_session_id
    ,wp.pageview_url AS billing_vesion_seen
    ,o.order_id
from website_pageviews wp
	left join  orders o
		on wp.website_session_id = o.website_session_id
WHERE
	website_pageview_id >= 53550
    AND wp.created_at < "2012-11-10"
	ANd wp.pageview_url in ("/billing","/billing-2");
    
-- use it as a subquery

select 
	billing_vesion_seen
    ,count(distinct website_session_id) AS sessions 
    ,count(distinct order_id) orders 
    ,count(distinct order_id) / count(distinct website_session_id) rt
from(
select
	wp.website_session_id
    ,wp.pageview_url AS billing_vesion_seen
    ,o.order_id
from website_pageviews wp
	left join  orders o
		on wp.website_session_id = o.website_session_id
WHERE
	website_pageview_id >= 53550
    AND wp.created_at < "2012-11-10"
	ANd wp.pageview_url in ("/billing","/billing-2")
) AS billing_sessions_w_orders
group by billing_vesion_seen;

-----------------------------------------------------------------------------------------------------------------------------------
                                                  -- Section 7 video 054
select 
	utm_content
    ,count(DISTINCT ws.website_session_id) As sessions 
    ,count(DISTINCT od.order_id) AS orders 
    ,count(od.order_id) / count(ws.website_session_id) AS sessions_to_orders_conversion_rate   -- aka "conversion_rate"
from website_sessions ws
	left join orders od
		on ws.website_session_id = od.website_session_id
where ws.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 1
ORDER BY sessions DESC ;




-----------------------------------------------------------------------------------------------------------------------------------
														-- Section 7 video 055 - 056

select
	-- yearweek(ws.created_at)
	min(date(ws.created_at)) AS week_start_day
	-- ,count(distinct ws.website_session_id) AS sessions
    -- ,count(distinct od.order_id) AS orders 
    ,count(distinct case when utm_source = "gsearch" then ws.website_session_id else NULL END ) AS gsearch_sessions
    ,count(distinct case when utm_source = "bsearch" then ws.website_session_id else NULL END ) AS bsearch_sessions
	-- ,count(distinct case when utm_source = "gsearch" then od.order_id else NULL END ) AS gsearch_orders
    -- ,count(distinct case when utm_source = "bsearch" then od.order_id else NULL END ) AS bsearch_orders
from website_sessions ws
	left join orders od 
    on ws.website_session_id = od.website_session_id
where 
	ws.created_at > "2012-08-22"
    AND ws.created_at < "2012-11-29"
    AND utm_source in ("gsearch", "bsearch")
    And utm_campaign = "nonbrand" 
group by 
	yearweek(ws.created_at) -- we can do this step >       GROUP BY year(ws.created_at) and week(ws.created_at)


-----------------------------------------------------------------------------------------------------------------------------------

                                                  -- Section 7 video 057 - 058
                                                  
SELECT 
	ws.utm_source
    ,COUNT(distinct ws.website_session_id) AS sessions
    ,COUNT(distinct case when ws.device_type = "mobile" then ws.website_session_id else NULL END ) AS mobile_sessions
    ,COUNT(distinct case when ws.device_type = "mobile" then ws.website_session_id else NULL END ) / 
		COUNT(distinct ws.website_session_id) AS pct_mobile
	-- ,COUNT(distinct case when ws.device_type = "mobile" then wswebsite_session_id else NULL END ) AS mobile_sessions
FROM website_sessions ws
WHERE ws.created_at > "2012-08-22"
	AND ws.created_at < "2012-11-30"
    AND utm_campaign = "nonbrand"													
    
GROUP BY ws.utm_source ;
-----------------------------------------------------------------------------------------------------------------------------------
                                                  -- Section 7 video 059 - 060

SELECT
	ws.device_type
    ,ws.utm_source
    ,count(distinct ws.website_session_id) AS sessions
    ,count(distinct od.order_id) AS orders 
    ,count(distinct od.order_id) / count(distinct ws.website_session_id) as con_rt
FROM website_sessions ws
	left join orders od
		on ws.website_session_id = od.website_session_id
WHERE 
	ws.created_at > "2012-08-22"
    AND ws.created_at < "2012-09-18"
    AND ws.utm_campaign = "nonbrand"
    
group by
	ws.device_type
    ,ws.utm_source ;

--------------------------------------------------------------------------------------------------------------------

                                                     -- Section 7 video 061 - 062
select  
	min(date(created_at)) As week_start_date
	,COUNT(distinct case when device_type = "desktop" AND  utm_source = "gsearch" then ws.website_session_id else NULL END ) AS g_desktop_sessions
	,COUNT(distinct case when device_type = "desktop" AND  utm_source = "bsearch" then ws.website_session_id else NULL END ) AS b_desktop_sessions
    
    ,COUNT(distinct case when device_type = "desktop" AND  utm_source = "bsearch" then ws.website_session_id else NULL END ) / 
		COUNT(distinct case when device_type = "desktop" AND  utm_source = "gsearch" then ws.website_session_id else NULL END ) AS b_percent_of_g_destop
    
	,COUNT(distinct case when device_type = "mobile" AND  utm_source = "gsearch" then ws.website_session_id else NULL END ) AS g_mobile_sessions
	,COUNT(distinct case when device_type = "mobile" AND  utm_source = "bsearch" then ws.website_session_id else NULL END ) AS b_mobile_sessions
	
    ,COUNT(distinct case when device_type = "mobile" AND  utm_source = "bsearch" then ws.website_session_id else NULL END ) / 
		COUNT(distinct case when device_type = "mobile" AND  utm_source = "gsearch" then ws.website_session_id else NULL END ) AS b_percent_of_g_mobile

from website_sessions ws 
WHERE 
	ws.created_at > "2012-11-04"
    AND ws.created_at < "2012-12-22"
    AND ws.utm_campaign = "nonbrand"   
group by 
	yearweek(ws.created_at);


--------------------------------------------------------------------------------------------------------------------
                                      -- Section 7 video 063
SELECT distinct 
	CASE 
		WHEN http_referer IS NULL AND is_repeat_session = 0 THEN "new_direct_type_in"
        WHEN http_referer IS NULL AND is_repeat_session = 1 THEN "repeat_direct_type_in"
        WHEN http_referer IN ("https://www.gsearch.com", "https://www.bsearch.com") AND is_repeat_session = 0 THEN "new_organic"
        WHEN http_referer IN ("https://www.gsearch.com", "https://www.bsearch.com") AND is_repeat_session = 1 THEN "repeat_organic"
	ELSE NULL
    END AS segment
    ,count(website_session_id) AS sessions
FROM website_sessions
where 
	website_session_id BETWEEN 100000  AND 115000
    AND utm_source IS NULL -- NOT paid trafic
GROUP BY 1  
ORDER BY 2 DESC 
;

--------------------------------------------------------------------------------------------------------------------
                                                   -- Section 7 video 064 - 065

--------------------------------------------------------------------------------------------------------------------
                                                   -- Section 7 video 066 - 067


--------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------
                                                   -- Section 9 video 072
select
	primary_product_id
	,count(order_id) AS orders
    ,sum(price_usd) AS revenue
    ,sum(price_usd - cogs_usd) AS margin 
    ,avg(price_usd) AS aov
from orders
where order_id BETWEEN 10000 AND 11000 -- arbitary
GROUP BY 1
ORDER BY orders desc;


--------------------------------------------------------------------------------------------------------------------
                                                   -- Section 9 video 073 - 074
select
	year(created_at) AS yr
	,month(created_at) AS mon
    ,sum(items_purchased) AS number_of_sales
    ,sum(price_usd) AS total_revenue
    ,sum(price_usd - cogs_usd) AS total_margin
from orders 
where created_at < "2013-01-04"
group by
	mon;

--------------------------------------------------------------------------------------------------------------------
                                                   -- Section 9 video 075 - 076
select 
	year(ws.created_at) AS yr
    ,month(ws.created_at) AS mon
    ,count(distinct o.order_id) AS orders
   -- ,count(distinct ws.website_session_id) AS sessions
    ,count(distinct o.order_id) / count(distinct ws.website_session_id) AS con_rt
    ,sum(o.price_usd) AS revenue
    ,sum(o.price_usd) / count(ws.website_session_id) AS revenue_per_sessions 
    ,count(distinct case when o.primary_product_id = 1 then o.order_id ELSE NULL END) product_one_orders
    ,count(distinct case when o.primary_product_id = 2 then o.order_id ELSE NULL END) product_two_orders

from website_sessions ws
	left join orders o
		on ws.website_session_id = o.website_session_id
where 
	ws.created_at > "2012-04-01" 
    AND ws.created_at < "2013-04-01"
group by 
	yr
    ,mon;
--------------------------------------------------------------------------------------------------------------------
											 -- Section 9 video 077
select
	-- wp.website_session_id
	pageview_url
    ,COUNT(distinct wp.website_session_id) AS sessions
    ,count(distinct order_id) AS orders
    ,count(distinct order_id) / COUNT(distinct wp.website_session_id) AS viewed_product_to_order_rate
from  website_pageviews wp
	left join orders o
		on wp.website_session_id = o.website_session_id
where 
	wp.created_at BETWEEN "2013-02-01"  AND "2013-03-01"
    and pageview_url IN ("/the-original-mr-fuzzy","/the-forever-love-bear")
group by pageview_url;
    
--------------------------------------------------------------------------------------------------------------------
												 -- Section 9 video 078 - 079
               -- Assignment_product_pathing_Analysis                                  
                                                 
-- Step 1: find the relevant /products pageview with website_sessions_id
-- Step 2: find the next page view id that occurs ARTER the product pageview
-- Step 3: find the pageview url associated with any applicable next pageview id
-- Step 4: summarize the data and analyze the pre VS. post periods


-- step 1: finding the /products pageviews we are care about 
        
CREATE TEMPORARY TABLE Products_pageviews
SELECT
	website_session_id
    ,website_pageview_id
    ,created_at
    ,CASE 
		WHEN created_at < "2013-01-06" THEN "A. pre_product-2"  -- before the product 2 lunch
        WHEN created_at >= "2013-01-06" THEN "B. post_product-2" -- after the product 2 lunch
        ELSE "uh oh....check logic"
	END AS time_period
FROM website_pageviews
WHERE  
	created_at > "2012-10-06"  -- start of 3 months before product 2 luanch
    and created_at < "2013-04-06"  -- date of request
    and pageview_url = "/products";
    
SELECT * 
FROM Products_pageviews;
    
            -- Step 2: find the next page view id that occurs ARTER the product pageview
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	pp.time_period
    ,pp.website_session_id
    ,min(wp.website_pageview_id) as min_next_page_view_id
FROM Products_pageviews pp
	left join website_pageviews wp
		on pp.website_session_id = wp.website_session_id
		and wp.website_pageview_id > pp.website_pageview_id
GROUP BY 
	pp.time_period
    ,wp.website_session_id;
    
select *
from sessions_w_next_pageview_id;
 

-- Step 3: find the pageview url associated with any applicable next pageview id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
	sn.time_period
    ,sn.website_session_id
    ,wp.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id  sn
	left join website_pageviews wp
		ON sn.min_next_page_view_id = wp.website_pageview_id;

select distinct next_pageview_url
from sessions_w_next_pageview_url;


-- just to show the distinct next pageview urls
-- SELECT DISTINCT next_pageview_url FROM sessions_w_next_pageview_url

-- Step 4: summarize the data and analyze the pre VS. post periods
SELECT 
	time_period
    ,COUNT(DISTINCT website_session_id) AS sessions
	,COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page
    ,COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) / 
		COUNT(DISTINCT website_session_id) AS pct_w_next_page
    ,COUNT(DISTINCT CASE WHEN next_pageview_url = "/the-original-mr-fuzzy" THEN website_session_id ELSE NULL END) AS to_mrfuzzy
    ,COUNT(DISTINCT CASE WHEN next_pageview_url = "/the-original-mr-fuzzy" THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy
    ,COUNT(DISTINCT CASE WHEN next_pageview_url = "/the-forever-love-bear" THEN website_session_id ELSE NULL END) AS to_lovebear
    ,COUNT(DISTINCT CASE WHEN next_pageview_url = "/the-forever-love-bear" THEN website_session_id ELSE NULL END) / 
		COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY 
	time_period;									
--------------------------------------------------------------------------------------------------------------------
											-- Section 9 video 082
select 
    od.primary_product_id
    ,count(distinct od.order_id) AS oders
    ,count(distinct case when oi.product_id = 1 then od.order_id ELSE NULL END) as cross_sell_product_1
	,count(distinct case when oi.product_id = 2 then od.order_id ELSE NULL END) as cross_sell_product_2
    ,count(distinct case when oi.product_id = 3 then od.order_id ELSE NULL END) as cross_sell_product_3
    
    ,count(distinct case when oi.product_id = 1 then od.order_id ELSE NULL END) / count(distinct od.order_id) as cross_sell_product_1_rt
	,count(distinct case when oi.product_id = 2 then od.order_id ELSE NULL END) / count(distinct od.order_id) as cross_sell_product_2_rt
    ,count(distinct case when oi.product_id = 3 then od.order_id ELSE NULL END) / count(distinct od.order_id) as cross_sell_product_3_rt

from orders od
	left join order_items oi
		on od.order_id = oi.order_id
        and oi.is_primary_item = 0 -- this is cross sell only
where od.order_id between 10000 AND 11000 -- arbitray
group by
	od.primary_product_id
    ;
--------------------------------------------------------------------------------------------------------------------
															-- Section 9 video 083 - 084
-- Step 1: identify the relevant /card page views and their sessions
-- step 2: see which of those /card sessions clicked through to the shipping page
-- step 3: find the orders assoiated with the /card sessions. analyse products purchased, AOV
-- step 4: Aggragate and Analyse a summary of our finidings


-- Step 1: identify the relevant /card page views and their sessions
create temporary table sessions_seeing_cart
select 
    CASE 
		WHEN created_at < "2013-09-25" THEN "A. Pre_Cross_Sell"
        when created_at >= "2013-09-25" THEN "b. Pre_Cross_Sell"
		ELSE "Uh oh....cheak logic"
	END AS time_period
	,website_session_id AS cart_sessions_id
    ,website_pageview_id AS cart_pageview_id
    
from website_pageviews
where 
	created_at > "2013-08-25"
    AND created_at < "2013-10-25"
    AND pageview_url = "/cart";

select * from sessions_seeing_cart;

-- step 2: see which of those /card sessions clicked through to the shipping page
create temporary table cart_sessions_seening_anther_page
select 
	ss.time_period
    ,ss.cart_sessions_id
    ,min(wp.website_pageview_id) AS pv_id_after_cart
from sessions_seeing_cart ss
	left join website_pageviews wp
		on ss.cart_sessions_id = wp.website_session_id
        and wp.website_pageview_id > ss.cart_pageview_id
group by 
	ss.time_period
    ,ss.cart_sessions_id
having min(wp.website_pageview_id) IS NOT NULL
;

select * from cart_sessions_seening_anther_page;


create temporary table pre_post_sessions_orders
SELECT 
	time_period
    ,cart_sessions_id
    ,order_id
    ,items_purchased
    ,price_usd
FROM sessions_seeing_cart ss 
	INNER JOIN orders od
		ON  ss.cart_sessions_id = od.website_session_id;


-- first, we will look at this select statemant
-- then we will turn it into a subquery
                                                                -- انا واقف عند الدقيقة 6:30  
select

FROM 
LEFT JOIN
ON
LEFT JOIN
ON 
ORDER BY
                                                       
--------------------------------------------------------------------------------------------------------------------
													-- Section 9 video 087
select
	oi.order_id
    ,oi.order_item_id
    ,oi.price_usd AS pricr_paid_used
    ,oi.created_at
    ,oir.order_item_refund_id
    ,oir.refund_amount_usd
    ,oir.created_at

from order_items oi
	left join order_item_refunds oir
		ON oi.order_item_id = oir.order_item_id
where oi.order_id in (3489, 32049, 27061);
--------------------------------------------------------------------------------------------------------------------
												-- Section 9 video 088 - 089
                                                
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------







































































































































































































































































