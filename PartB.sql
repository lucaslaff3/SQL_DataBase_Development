-- Question 1 Which weekday (including weekends) has the highest number of orders? 
-- Which weekday has the lowest number of orders? 
create view totalOrders as  
	select order_dow, count(order_id) as DayOfWeekCount
    from orders
    group by order_dow;
    
select DayOfWeekCount,
case
when order_dow = 0 then 'Saturday' when order_dow = 1 then 'Sunday' when order_dow = 2 then 'Monday' when order_dow = 3 then 'Tuesday'
when order_dow = 4 then 'Wednesday' when order_dow = 5 then 'Thursday' when order_dow = 6 then 'Friday' end as day_name 
from totalOrders order by order_dow;

-- Question 2 What percentage of orders are made during daytime (8am-5pm)? 
-- Round the result to 2 digits to decimal.
with totalOrders as (
	select count(order_id) as totalOrders 
    from orders
),
totalDayOrders as (
	select count(order_id) as totalDayOrders
    from orders
    where order_hour_of_day >= 8 and order_hour_of_day <= 17
)
select round((totalDayOrders / totalOrders), 2) as OrdersDuringDayPercentage
from totalOrders, totalDayOrders;

-- Question 3 . 
-- (a) If the company wants to give discount for customers’ reorders. 
-- At what time should the company launch the discount event? Find the top 3 prime times for re-orders. 
-- Prime time is measured by the reorder counts. Your results should look like Wednesday 3am, etc.
select count(order_id) as ReOrderCount, 
case
	when order_dow = 0 then 'Saturday' when order_dow = 1 then 'Sunday' when order_dow = 2 then 'Monday' when order_dow = 3 then 'Tuesday'
	when order_dow = 4 then 'Wednesday' when order_dow = 5 then 'Thursday' when order_dow = 6 then 'Friday' end as day_name, 
case 
	when order_hour_of_day = 10 then '10am' when order_hour_of_day = 14 then '2pm' 
    when order_hour_of_day = 15 then '3pm' end as time_of_day
from orders 
where days_since_prior != '' 
group by order_dow, order_hour_of_day
order by count(order_id) desc limit 3;

-- (b). The company wants to attract new customers by launching promotion events. 
-- At what time should the company launch the promotion to customers who place his/her first order? 
-- Find the top 3 prime times for customers’ first orders.
select count(order_id) as ReOrderCount,
case
	when order_dow = 0 then 'Saturday' when order_dow = 1 then 'Sunday' when order_dow = 2 then 'Monday' when order_dow = 3 then 'Tuesday'
	when order_dow = 4 then 'Wednesday' when order_dow = 5 then 'Thursday' when order_dow = 6 then 'Friday' end as day_name,
case 
	when order_hour_of_day = 15 then '3pm' when order_hour_of_day = 14 then '2pm' 
    when order_hour_of_day = 13 then '1pm' end as Time_Of_Day
from orders 
where days_since_prior = '' 
group by order_dow, order_hour_of_day
order by count(order_id) desc limit 3;

-- Question 4: How often do the users reorder items? 
-- To answer this question, you need to show the number of users reorder items for each days_since_prior. 
select count(order_id) as UserReorders, days_since_prior as DaysPrior
from orders
where days_since_prior != ''
group by days_since_prior
order by count(order_id) desc;


-- Question 5 
-- Show how many customers reorder once in every week, two weeks, three weeks, or once in every month, etc. 
select 'order every week' as frequency, count(order_id)
from orders
where days_since_prior between 0 and 7
union
select 'order every 2 weeks' as frequency, count(order_id)
from orders
where days_since_prior between 8 and 14
union
select 'order every 3 weeks' as frequency, count(order_id)
from orders
where days_since_prior between 15 and 21
union 
select 'order every month' as frequency, count(order_id) 
from orders
where days_since_prior between 22 and 31;


-- Question 6. Use order_products_prior and order_products_train to answer this question. 
-- The company wants to know on average how many items and how many products users buy. Round to the integer. 
-- Do you see the distributions are comparable between the train and prior order set?
-- Note that add_to_cart_order show the purchased items. 
-- It is possible that a customer purchased multiple items of a product in an order. 
with totalProductsTrain as (
	select count(distinct product_id) as totalProductOrderedTrain, max(add_to_cart_order) as totalItemsTrain
    from order_products_train
    group by order_id
)
select round(avg(totalProductOrderedTrain)) as averageProducts, round(avg(totalItemsTrain)) as AverageItemsTrain
from totalProductsTrain;

with totalProductsPrior as (
    select count(product_id) as totalProductOrderedPrior, max(add_to_cart_order) as totalItemsPrior
    from order_products_prior
    group by order_id
)
select round(avg(totalProductOrderedPrior)) as averageProducts, round(avg(totalItemsPrior)) as averageItemsPrior
from totalProductsPrior;

-- Question 7 What are the top 10 products most often ordered? 
-- Show the product names of these products. Note: You need to add the results order_products_prior and order_products_train tables. 
with PriorCount as (
	select count(product_id) as PriorCount, product_id
	from order_products_prior
    group by product_id
),
TrainCount as (
	select count(product_id) as TrainCount, product_id
    from order_products_train
    group by product_id
)
select (PriorCount + TrainCount) as TotalCount, p.product_name
from products p join PriorCount ac on (p.product_id = ac.product_id) join
	TrainCount tc on (p.product_id = tc.product_id)
order by TotalCount desc limit 10;


-- Question 8 For each of the top 5 users who placed the highest number of orders,
-- 				what is the average days interval of this user’s orders? 
with Top5Orders as (
	select count(user_id) as NumberOfOrders, user_id
	from orders
    group by user_id
    order by NumberOfOrders desc limit 5
)
select t5.user_id, round(avg(days_since_prior), 2) as averageDaysPrior
from Top5Orders t5 join orders o on (t5.user_id = o.user_id)
where days_since_prior != ''
group by user_id;


-- Q9 Show days_since_prior and the average reorder rate of each days_since_prior.
-- Round the average of reordered as 2 digits to decimal. Sort the result set by days_since_prior. 
with totalOrders as (
	select days_since_prior, count(*) as total_order
    from orders
    group by days_since_prior
),
priorOrders as (
	select days_since_prior, count(*) as totalprior
    from orders
    where eval__set = 'prior'
    group by days_since_prior
)
select tOr.days_since_prior,
	round(totalprior/total_order, 2) as reorder_rate
    from totalOrders tOr join priorOrders po on (tOr.days_since_prior = po.days_since_prior)
    order by reorder_rate desc;
    
-- Q10 We want to know which product people put into the cart first if they buy products? 
-- To answer this question, find the product_id, product_name, and the highest percentage of this product’s put-into-the-cart-first.
with firstOrderCounts as (
	select product_id, count(*) as first_order
    from order_products
    where add_to_cart_order = '1'
    group by product_id
    order by first_order desc limit 1
)
select foc.first_order, p.product_name, p.product_id
from firstOrderCounts foc join products p on (foc.product_id = p.product_id);

-- Question 11 Are the top 5 products with the highest number of orders more likely to be reordered? 
-- Note that if the proportion of reordered is >70%, then this product is more likely to be reordered. 
-- Counts the amount of time a product was ordered and reordered in Prior
with PriorProductOrderedCount as (
	select count(order_id) as PriorOrderCount, product_id
    from order_products_prior
    group by product_id
),
TrainProductOrderedCount as (
	select count(order_id) as TrainOrderCount, product_id
    from order_products_train
    group by product_id
),
PriorReorderedCounts as(
	select count(reordered) as PriorReorderedCount, product_id
    from order_products_prior
    where reordered = '1' 
    group by product_id
),
TrainReorderedCounts as(
	select count(reordered) as TrainReorderedCount, product_id
    from order_products_train
    where reordered = '1' 
    group by product_id
),
Proportion as(
	select (PriorReorderedCount + TrainReorderedCount) as TotalProductReorderCount, (PriorOrderCount + TrainOrderCount) as TotalProductOrdersCount, ppoc.product_id as product_id
    from PriorProductOrderedCount ppoc join TrainProductOrderedCount tpoc on (ppoc.product_id = tpoc.product_id) join PriorReorderedCounts prc on (ppoc.product_id = prc.product_id)
		join TrainReorderedCounts trc on (ppoc.product_id = trc.product_id)
    group by ppoc.product_id
	order by TotalProductOrdersCount
)
select TotalProductOrdersCount, TotalProductReorderCount, product_id from Proportion order by TotalProductOrdersCount desc limit 5;

-- Question 12 Are organic products sold more often than non-organic products? 
-- You can solve this question by showing the percentage of orders that have organic products. 
-- Product_name describes whether a product is organic or not. 
with Organic as (
	select count(opp.order_id) as organicCount
    from order_products_prior opp join products p on (opp.product_id = p.product_id),
		order_products_train opt join products p2 on (opt.product_id = p2.product_id)
    where p.product_name like '%organic%' or p2.product_name like '%organic%'
)
select (organicCount/organicCount) as OrganicPercentage
	from products, Organic;
    
-- Question 13 How many unique products are offered in each department/aisle?
select count(distinct product_id) as Products, aisle_id, department_id
from products
group by aisle_id, department_id;

-- Question 14 Find the top 10 best-sellers in each department.
-- counts all of the orders for each product in each department of the order_products_prior
-- DEPARTMENT TOP 10
with priorCount as (
	select order_id, product_id, count(*) as PriorSold
	from order_products_prior
    group by product_id
),
trainCount as (
	select order_id, product_id, count(*) as TrainSold
    from order_products_train
    group by product_id
),
departmentList as (
	select product_id, product_name, department_id
	from products
),
getRanking as (
	select department_id, priorCount.product_id, product_name, (PriorSold + TrainSold) as totalSold,
		rank() over (partition by department_id order by (PriorSold + TrainSold) desc) as departmentRank
	from priorCount join departmentList on (priorCount.product_id = departmentList.product_id) join trainCount on (departmentList.product_id = trainCount.product_id)
)
select department_id, product_id, product_name, totalSold, departmentRank
from getRanking
where departmentRank <= 10
order by department_id, departmentRank;
-- DEPARTMENT TOP 10


-- Question 15 Find the top 10 best-sellers in each aisle.
-- AISLE TOP 10
with priorCount as (
	select order_id, product_id, count(*) as PriorSold
	from order_products_prior
    group by product_id
),
trainCount as (
	select order_id, product_id, count(*) as TrainSold
    from order_products_train
    group by product_id
),
aisleList as (
	select product_id, product_name, aisle_id
	from products
),
getRanking as (
	select aisle_id, priorCount.product_id, product_name, (PriorSold + TrainSold) as totalSold,
		rank() over (partition by aisle_id order by (PriorSold + TrainSold) desc) as aisleRank
	from priorCount join aisleList on (priorCount.product_id = aisleList.product_id) join trainCount on (aisleList.product_id = trainCount.product_id)
)
select aisle_id, product_id, product_name, totalSold, aisleRank
from getRanking
where aisleRank <= 10
order by aisle_id, aisleRank;
    

-- Question 16 
-- Show the number of new users (i.e., customers place the first orders), and the number of existing users, 
-- and the ratio of new users to existing users in each weekday. Which day has the highest ratio?

-- Gets all users who made their first order
with firstOrder as (
	select count(user_id) as NewUsers, 
    case
		when order_dow = 0 then 'Saturday' when order_dow = 1 then 'Sunday' when order_dow = 2 then 'Monday' when order_dow = 3 then 'Tuesday'
		when order_dow = 4 then 'Wednesday' when order_dow = 5 then 'Thursday' when order_dow = 6 then 'Friday' end as day_name    
    from orders
    where days_since_prior = '' 
    group by order_dow
),
-- Not their first order
recurringOrder as (
	select count(user_id) as ExistingUsers,
    case
		when order_dow = 0 then 'Saturday' when order_dow = 1 then 'Sunday' when order_dow = 2 then 'Monday' when order_dow = 3 then 'Tuesday'
		when order_dow = 4 then 'Wednesday' when order_dow = 5 then 'Thursday' when order_dow = 6 then 'Friday' end as day_name    
	from orders
    where days_since_prior != '' 
    group by order_dow
),
totalNew as (
	select count(user_id) as TotalNewUsers from orders where days_since_prior = '' 
),
totalExisting as (
	select count(user_id) as TotalExistingUsers from orders where days_since_prior != '' 
)
select TotalExistingUsers, ro.ExistingUsers, TotalNewUsers, fo.NewUsers, (fo.NewUsers/ro.ExistingUsers) as NewToExistingRation, ro.day_name
from firstOrder fo join recurringOrder ro on (fo.day_name = ro.day_name),
	totalNew, totalExisting;	

-- Question 17 How many customers always reorder the same products all the time?
-- gets all of the user ids, the amount of orders they have made and the ids of those order that do not contain a reordered 0 value
-- To search the users you need to look at all orders (excluding the first order), where the percentage of reordered items is exactly 1. 

-- counts all of the items in an order for those ids that were not their first order 
with OrderItemCount as (
	select order_id, count(order_id) as ItemsOrdered 
    from order_products_prior
    group by order_id
),
-- counts all of the items that were reordered for each order id
PriorReorderCount as (
	select oc.order_id, count(reordered) as ReorderedItemCount
    from order_products_prior opp join OrderItemCount oc on (opp.order_id = oc.order_id)
    where reordered = '1'
    group by oc.order_id
),
-- counts the amount of users that had full reorders 
FullReorderCount as (
	select count(distinct user_id) as FullReorderCustomers
	from orders o join PriorReorderCount prc on (o.order_id = prc.order_id) 
	join OrderItemCount oic on (prc.order_id = oic.order_id)
	where ItemsOrdered = ReorderedItemCount
)
select FullReorderCustomers from FullReorderCount;

-- Question 18 Segment the customers based on their average days of interval of reordering into 4 segments. Count the number of users in each segment.
with reorderAverages as (
	select user_id, avg(days_since_prior) as AverageReordering
    from orders
    where days_since_prior != ''
    group by user_id
),
niteledUsers as (
	select AverageReordering, user_id,
		ntile(4) over (order by AverageReordering) as ReorderFrequency
	from reorderAverages        
),
countOne as (
	select count(user_id) as OneCount
    from niteledUsers
    where ReorderFrequency = 1
),
countTwo as (
	select count(user_id) as TwoCount
    from niteledUsers
    where ReorderFrequency = 2
),
countThree as (
	select count(user_id) as ThreeCount
    from niteledUsers
    where ReorderFrequency = 3
),
countFour as (
	select count(user_id) as FourCount
    from niteledUsers
    where ReorderFrequency = 4
)
select OneCount as TopSegment, TwoCount as SecondSegment, ThreeCount as ThirdSegment, FourCount as BottomSegment from countOne, countTwo, countThree, countFour; 

-- Question 19 For those customers who reordered within 7 days, what are the most frequently reordered products? 
-- Show the top 5 products' product_id and product_name.
with ordersUnder7 as (
	select order_id
    from orders
    where days_since_prior < '7'
),
productCount as (
	select count(opp.product_id) as ProductReorder, opp.product_id
    from ordersUnder7 ou join order_products_prior opp on (ou.order_id = opp.order_id)
    where reordered = 1
    group by opp.product_id
),
productMatch as (
	select p.product_id, p.product_name, ProductReorder
    from productCount pc join products p on (pc.product_id = p.product_id)
	order by ProductReorder desc limit 5
)
select product_id, product_name, ProductReorder 
from productMatch;

-- Question 20 The manager thinks that the longer the length of days interval between reorders, the more users will purchase in the next reorder. Do you agree with the manager? Explain why.
with customerAvgDays as (
	select user_id, avg(days_since_prior) as AverageDaysTilOrder, order_id
    from orders
    group by user_id
),
PriorReorderCounting as (
	select order_id, count(order_id) as PriorReorderCount
	from order_products_prior
    where reordered = '1'
	group by order_id
),
TrainReorderCounting as (
	select order_id, count(order_id) as TrainReorderCount
	from order_products_train
    where reordered = '1'
	group by order_id
)
select cad.user_id, AverageDaysTilOrder, (PriorReorderCount + TrainReorderCount) as totalReordered
from customerAvgDays cad join orders o on (cad.user_id = o.user_id) join PriorReorderCounting prc on (cad.order_id = prc.order_id)
	join TrainReorderCounting trc on (cad.order_id = trc.order_id)
group by user_id;

    
