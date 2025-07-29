with orders as (
    select * from {{ source('northwind', 'Orders') }}
),

order_details as (
    select * from {{ source('northwind', 'Order_Details') }}
),

combined as (
    select
        o.orderid,
        o.customerid,
        o.employeeid,
        o.orderdate,
        od.productid,
        od.quantity,
        od.unitprice,
        od.discount,
        od.quantity * od.unitprice as extendedpriceamount,
        (od.quantity * od.unitprice) * od.discount as discountamount,
        (od.quantity * od.unitprice) - ((od.quantity * od.unitprice) * od.discount) as soldamount
    from orders o
    join order_details od using (orderid)
)

select
    {{ dbt_utils.generate_surrogate_key(['combined.orderid', 'combined.productid']) }} as saleskey,
    combined.orderid,
    c.customerkey as customerkey,
    e.employeekey as employeekey,
    d.datekey as orderdatekey,
    p.productkey as productkey,
    combined.quantity,
    combined.extendedpriceamount,
    combined.discountamount,
    combined.soldamount
from combined
left join {{ ref('dim_customer') }} c on combined.customerid = c.customerid
left join {{ ref('dim_employee') }} e on combined.employeeid = e.employeeid
left join {{ ref('dim_date') }} d on combined.orderdate = d.date
left join {{ ref('dim_product') }} p on combined.productid = p.productid
