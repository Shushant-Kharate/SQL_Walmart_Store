#1 Show moving average of Total sales over last 3 transactions per branch
select Invoice_ID, Branch, total, Date, time,
avg(Total) over (
        partition by Branch 
        order by Date, Time desc
        rows between 3 preceding and current row
    ) as Moving_Avg_3
from walmart;

#2 For each branch, rank the product lines by their total revenue (Total) in descending order.
select 
	Branch, 
	Product_Line, 
	sum(Total) as total_revenue, 
	Rank() Over(partition by Branch order by sum(total) desc) as Total_rank
from walmart
group by Branch, Product_Line;

#3 Calculate Running Total of Gross Income by Date
select 
	Date,
	SUM(gross_income) AS Daily_Income,
	SUM(SUM(gross_income)) OVER (order by date rows between unbounded preceding and current row ) AS Running_Income
FROM walmart
group by date
ORDER BY Date;

#4 Show the Rating of each transaction and the average rating of that branch. Also calculate the difference.
select
	Invoice_id,
	branch, 
	rating,
	avg(rating) over(partition by branch) as Average_branch_rating
from walmart
order by rating desc;

#5 Identify the Highest Revenue Transaction Per Customer Type
select * from (select 
	Invoice_id, 
	Customer_type, 
	Total,
	Rank() over(partition by customer_type order by total desc) as Heigest_revenue
from walmart) R
 where r.heigest_revenue=1;

#6 What is the 3-day moving average of Quantity sold (sorted by Date)
select 
	Date, 
	Quantity, 
	avg(quantity) over(order by date rows between 2 preceding and current row) as Average_of_3_Days
from walmart;

#7 Compare Today's Income with Yesterday's 
select 
	Branch,
    Date,
    sum(gross_income) as Gross_income,
    lag(sum(gross_income)) over(
		partition by branch order by date) as Lag_Sum,
	sum(gross_income)- lag(sum(gross_income)) over(
		partition by branch order by date) as Comparision
from walmart
group by Branch, Date
order by Branch, Date;

#8 What is the Next Product Line Purchase 
select 
	Invoice_Id,
    Product_line,
    lead(Product_line) over() as Next_In_Line
from walmart;

#9 Percent of Total Income by Branch
select 
	branch,
    sum(gross_income) as Branch_Income,
    round((sum(gross_income)*100)/ sum(sum(gross_income)) over() ,2) as Percent
from walmart
group by branch;

#10 Rank Products by Income within Branch 
select 
	branch,
    product_line,
    sum(gross_income) as Total,
    rank() over(partition by branch order by sum(gross_income) desc) as Income_rank
from walmart
group by branch, product_line;

#11 Percentile Ranking of Daily Income 
select 
	branch,
    date,
    sum(gross_income) as Income,
    percent_rank() over(partition by branch order by sum(Gross_Income) desc) as Percentile
from walmart
group by branch,date;

#12 Assign Sales into 4 Quartiles by Product Line
select 
    Product_line,
    sum(gross_income) as Income,
    ntile(4) over(order by sum(gross_income)) as Sales
from walmart
group by Product_line;

#13 Detect days where a branch's income dropped compared to the previous day.
select
	Branch,
    Date,
    sum(gross_income) as Total_Income,
    lag(sum(gross_income)) over(partition by branch order by date) as Lag_Income,
case
	when sum(gross_income) < lag(sum(gross_income)) over(partition by branch order by date)
    then 'Drop'
    else 'No drop'
    end as Income_trend
from walmart
group by branch, date
order by branch, date;


#14 Identify Peak Hours for Sales per Branch
select *
from (
    select  
        Branch,
        extract(HOUR FROM CAST(Time AS Time)) as Sale_Hour,
        avg(Total) as Avg_Hourly_Sale,
        Rank() Over (
					partition by Branch 
					order by avg(Total) desc) as Hourly_Sale_Rank
    from walmart
    group by Branch, extract(HOUR FROM CAST(Time AS TIME))) ranked_hours
where Hourly_Sale_Rank = 1;

#15 Show Revenue Gap Between Top-Selling and Second-Best Product Line
select 
    Branch,
    max(case when product_rank = 1 then Product_line end) as Top_Product,
    max(case when product_rank = 2 then Product_line end) as Second_Best_Product,
    max(case when product_rank = 1 then Total_Income end) - max(case when product_rank = 2 then Total_Income end) as Revenue_Gap
from (select 
        Branch,
        Product_line,
        sum(gross_income) as Total_Income,
        rank() over (partition by Branch order by SUM(gross_income) desc) as product_rank
    from walmart
    group by Branch, Product_line) t
where t.product_rank in (1, 2)
group by t.Branch;

    


