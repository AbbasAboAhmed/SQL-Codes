											-- Section 5 Video 038 Demo

-- Business Concept:
-- We want to see landing page performance for a certain time period

-- Step 1: Find the first website_pageview_id for relevant sessions
-- step 2: identifying the landing page of each session
-- step 3: counting pageviews for each session, to identify "bounces"
-- step 4: summarizing Total sessions and bounced sessions, by LP

-- Finding the minimum website pageview id with each session we care about

Select 
    wp.website_session_id	
	,MIN(wp.website_pageview_id) AS min_pageview_id

FROM website_sessions ws
	LEFT JOIN  website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN "2014-01-01" AND "2014-02-01" 
GROUP BY 
	wp.website_session_id;

-- We wil take the query above and create a temporary table

CREATE TEMPORARY TABLE first_pageviews    
Select 
    wp.website_session_id	
	,MIN(wp.website_pageview_id) AS min_pageview_id

FROM website_sessions ws
	LEFT JOIN  website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN "2014-01-01" AND "2014-02-01" 
GROUP BY 
	wp.website_session_id;    

select * from first_pageviews; -- To see what is in the teporary table
    
-- identifying the landing page of each session
CREATE TEMPORARY TABLE sessions_w_landing_page
SELECT 
	fp.website_session_id
    ,fp.min_pageview_id
    ,wp.pageview_url AS landing_page
FROM first_pageviews fp
	LEFT JOIN website_pageviews wp
		ON fp.website_session_id = wp.website_session_id;
                
select * from sessions_w_landing_page;   -- To see what is in the teporary table
    
-- Next, we make a table include a count of pageview per session
-- first, we will show all the sessions. then we will limit to bounced sessions and create a temp table
    
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
	sl.website_session_id
    ,sl.landing_page
    ,COUNT(wp.website_pageview_id) AS count_of_page_viewed
FROM  sessions_w_landing_page sl
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id = sl.website_session_id
GROUP BY 
	sl.website_session_id
    ,sl.landing_page
HAVING 
	COUNT(wp.website_pageview_id) = 1;

select * from bounced_sessions_only;   -- To see what is in the teporary table

SELECT
	sl.landing_page
	,sl.website_session_id 
    ,bs.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page sl
    LEFT JOIN bounced_sessions_only bs
		ON sl.website_session_id = bs.website_session_id
ORDER BY
	sl.website_session_id;



-- final 
		-- we will use the previouse query , and count the records
        -- we will grounp by landing page
SELECT
	sl.landing_page
	,COUNT(DISTINCT sl.website_session_id) AS sessions
    ,COUNT(DISTINCT bs.website_session_id) AS bounced_session
	,COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT sl.website_session_id) AS bounce_rate
FROM sessions_w_landing_page sl
    LEFT JOIN bounced_sessions_only bs
		ON sl.website_session_id = bs.website_session_id
GROUP BY
	sl.landing_page
ORDER BY bounced_session DESC;

------------------------------------------------------------------------------------------------------------------------------
											-- Section 5 Video 045 Demo

-- Building Convertion Funnels
-- Business Concept:
	-- we want  to build a mini conversion funnel trying to understand which customers hit /lander-2 to /cart
    -- we wnat to know how many people reach each step along the way and the drop off rates at each step
    -- for simplicity of the demo,  we only care about /lander-2 traffic 
    -- for simplicity of the demo, we are looking at customers who like the Mr. Fuzzy page only
    
-- Step 1: Select all the pageviews for all the relevant sessions that we care about.
-- Step 2: Then we'll identify each relevant pageviews as a specific step in our funnel.
-- Step 3: Then we'll create a session level conversion funnel view( which is a summary for each individual session).
-- Step 4: finally we'll aggregate the data to assess our funnel performance so let's take a look here.


SELECT  
	ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS product_page
	,CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page
	,CASE WHEN pageview_url =  "/cart" THEN 1 ELSE 0 END AS cart_page
    
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN "2014-01-01" AND "2014-02-01" 
    AND wp.pageview_url IN ("/lander-2", "/products", "/the-original-mr-fuzzy", "/cart")
ORDER BY 
	ws.website_session_id
    ,wp.created_at;

-- Next we will put the previous query as a subquery
-- we will group by website_session_id, and take max of each of the flag
-- this max become a made_it flag for that sessions, to show the sessions made it there 

SELECT
	website_session_id
    ,MAX(product_page) AS product_made_it
    ,MAX(mrfuzzy_page) AS mmrfuzzy_ade_it
	,MAX(cart_page) AS cart_made_it
FROM(
SELECT  
	ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS product_page
	,CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page
	,CASE WHEN pageview_url =  "/cart" THEN 1 ELSE 0 END AS cart_page
    
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN "2014-01-01" AND "2014-02-01" 
    AND wp.pageview_url IN ("/lander-2", "/products", "/the-original-mr-fuzzy", "/cart")
ORDER BY 
	ws.website_session_id
    ,wp.created_at
) AS pageview_level

GROUP BY website_session_id ;

-- next we will turn the previous query into a temp table 

CREATE TEMPORARY TABLE sessions_level_made_it_flage
SELECT
	website_session_id
    ,MAX(product_page) AS product_made_it
    ,MAX(mrfuzzy_page) AS mrfuzzy_ade_it
	,MAX(cart_page) AS cart_made_it
FROM(
SELECT  
	ws.website_session_id
    ,wp.pageview_url
    ,wp.created_at AS pageview_created_at
    ,CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS product_page
	,CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page
	,CASE WHEN pageview_url =  "/cart" THEN 1 ELSE 0 END AS cart_page
    
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN "2014-01-01" AND "2014-02-01" 
    AND wp.pageview_url IN ("/lander-2", "/products", "/the-original-mr-fuzzy", "/cart")
ORDER BY 
	ws.website_session_id
    ,wp.created_at
) AS pageview_level

GROUP BY website_session_id ;

SELECT *  FROM sessions_level_made_it_flage;


-- then this would get the final result 

SELECT
	COUNT(DISTINCT website_session_id ) AS sessions
    ,COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_product
    ,COUNT(DISTINCT CASE WHEN mrfuzzy_ade_it = 1 THEN website_session_id ELSE NULL END ) AS to_mrfuzzy
    ,COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_cart
FROM sessions_level_made_it_flage;


-- we will translate those counts to click rates

SELECT
	COUNT(DISTINCT website_session_id ) AS sessions
    ,COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END ) / 
			COUNT(DISTINCT website_session_id ) AS clicked_to_product_rate
    ,COUNT(DISTINCT CASE WHEN mrfuzzy_ade_it = 1 THEN website_session_id ELSE NULL END ) / 
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END ) AS product_clicked_to_mrfuzzy_rate
    ,COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END ) /
		COUNT(DISTINCT CASE WHEN mrfuzzy_ade_it = 1 THEN website_session_id ELSE NULL END ) AS mrfuzzy_clicked_to_cart_rate
FROM sessions_level_made_it_flage;





SELECT

FROM 
LEFT JOIN 
		ON 
WHERE 
GROUP BY ;




SELECT

FROM 
LEFT JOIN 
		ON 
WHERE 
GROUP BY ;




SELECT

FROM 
LEFT JOIN 
		ON 
WHERE 
GROUP BY ;




SELECT

FROM 
LEFT JOIN 
		ON 
WHERE 
GROUP BY ;


SELECT

FROM 
LEFT JOIN 
		ON 
WHERE 
GROUP BY ;