-- 1. Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). 
-- This information will help us identify high-value products that are currently being heavily discounted, 
-- which can be useful for evaluating our pricing and promotion strategies.


select product_code, base_price from fact_events 
where base_price>500 and promo_type='BOGOF';


-- 2. Generate a report that provides an overview of the number of stores in each city. 
-- The results will be sorted in descending order of store counts, 
-- allowing us to identify the cities with the highest store presence. 
-- The report includes two essential fields: city and store count, 
-- which will assist in optimizing our retail operations.

select s.city,count(distinct e.store_id) as stores 
from fact_events e join dim_stores s on e.store_id=s.store_id
group by s.city order by stores desc;


-- 3. Generate a report that displays each campaign along with the total revenue generated 
-- before and after the campaign? The report includes three key fields: 
-- campaign_name, total_revenue(before_promotion), total_revenue(after_promotion). 
-- This report should help in evaluating the financial impact of our promotional campaigns.
-- (Display the values in millions)

select c.campaign_name,
concat(sum(e.base_price*e.`quantity_sold(before_promo)`)/1000000,' M') as revenue_before_promo,
concat(sum(e.base_price*e.`quantity_sold(after_promo)`)/1000000, ' M') as revenue_after_promo
from dim_campaigns c join fact_events e on c.campaign_id=e.campaign_id group by c.campaign_name;


-- 4. Produce a report that calculates the Incremental Sold Quantity (ISU%)
-- for each category during the Diwali campaign. Additionally, provide rankings
-- for the categories based on their ISU%. 
-- The report will include three key fields: 
-- category, isu%, and rank order. 
-- This information will assist in assessing the 
-- category-wise success and impact of the Diwali campaign on incremental sales.

select p.category, concat(round((sum(e.`quantity_sold(after_promo)`)-
sum(e.`quantity_sold(before_promo)`))/
(sum(e.`quantity_sold(before_promo)`))*100,2),' %') as ISU_percentage,
rank() over(order by (sum(e.`quantity_sold(after_promo)`)-
sum(e.`quantity_sold(before_promo)`))/
(sum(e.`quantity_sold(before_promo)`)) desc) as rnk
from dim_products p join fact_events e 
on p.product_code=e.product_code join dim_campaigns c 
on e.campaign_id=c.campaign_id 
where c.campaign_name='Diwali' 
group by p.category;


-- 5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), 
-- across all campaigns. The report will provide essential information including product name, 
-- category, and ir%. This analysis helps identify the most successful products in 
-- terms of incremental revenue across our campaigns, assisting in product optimization.

select p.product_name,p.category,
concat(round((sum(e.base_price*`quantity_sold(after_promo)`)-
sum(e.base_price*`quantity_sold(before_promo)`))/
(sum(e.base_price*`quantity_sold(before_promo)`))*100,2), ' %') as IR_percentage
 from dim_products p join fact_events e on p.product_code=e.product_code
group by p.product_name,p.category 
order by 
(sum(e.base_price*`quantity_sold(after_promo)`)-
sum(e.base_price*`quantity_sold(before_promo)`))/
sum(e.base_price*`quantity_sold(before_promo)`) desc;
