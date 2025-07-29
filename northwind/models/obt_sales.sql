with fact as (
    select * from {{ ref('fact_sales') }}
),

customer as (
    select customerkey as cust_key, companyname, contactname from {{ ref('dim_customer') }}
),

employee as (
    select employeekey as emp_key, employeenamefirstlast from {{ ref('dim_employee') }}
),

product as (
    select productkey as prod_key, productname from {{ ref('dim_product') }}
),

order_date as (
    select datekey as order_date_key from {{ ref('dim_date') }}
),

sales_data as (
    select
        f.orderid,
        f.customerkey,
        f.employeekey,
        f.orderdatekey,
        f.productkey,
        f.quantity,
        f.extendedpriceamount,
        f.discountamount,
        f.soldamount,
        c.companyname,
        c.contactname,
        e.employeenamefirstlast,
        p.productname,
    from fact f
    left join customer c on f.customerkey = c.cust_key
    left join employee e on f.employeekey = e.emp_key
    left join product p on f.productkey = p.prod_key
    left join order_date d on f.orderdatekey = d.order_date_key
)

select * from sales_data
