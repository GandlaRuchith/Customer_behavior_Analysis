-- Revenue by gender

select gender , sum(purchase_amount) as revenue from [dbo].[customer_shopping_behavior] group by gender


--High-Spending Discount Users – Identified customers who used discounts but still spent above the average purchase amount.


select customer_id , purchase_amount from [dbo].[customer_shopping_behavior] where discount_applied ='Yes' and purchase_amount>=(select avg(purchase_amount) from [dbo].[customer_shopping_behavior])

--Top 5 Products by Rating – Found products with the highest average review ratings.

select top 5 item_purchased,round(avg(review_rating),2) as 'avg rating' from [dbo].[customer_shopping_behavior] group by item_purchased
order by 'avg rating' desc


-- Shipping Type Comparison – Compared average purchase amounts between Standard and Express shipping.

 select shipping_type , Round(avg(purchase_amount),2) as round from [dbo].[customer_shopping_behavior] where shipping_type in ('Standard','Express')
 group by shipping_type

 -- Subscribers vs. Non-Subscribers – Compared average spend and total revenue across subscription status.

 select subscription_status , count(customer_id) as cnt , round(avg(purchase_amount),2) as 'avg spend' , round(sum(purchase_amount),2) as revenue from [dbo].[customer_shopping_behavior]
 group by subscription_status
 order by [avg spend] ,revenue desc


 --Discount-Dependent Products – Identified 5 products with the highest percentage of discounted purchases

 select top 5 item_purchased , round(100* sum(case when discount_applied ='Yes' then 1 else 0 end)/count(*),2) as per from 
[dbo].[customer_shopping_behavior] group by item_purchased order by per desc

--Customer Segmentation – Classified customers into New, Returning, and Loyal segments based on purchase history.

SELECT 
    CASE 
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    
    COUNT(customer_id) AS customer_count

FROM dbo.customer_shopping_behavior 
GROUP BY 
    CASE 
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END;


--Top 3 Products per Category – Listed the most purchased products within each category.

WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM [dbo].[customer_shopping_behavior]
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;

--Repeat Buyers & Subscriptions – Checked whether customers with >5 purchases are more likely to subscribe.

SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM [dbo].[customer_shopping_behavior]
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Revenue by Age Group – Calculated total revenue contribution of each age group.

select age_group , sum(purchase_amount) as revenue from [dbo].[customer_shopping_behavior] group by age_group