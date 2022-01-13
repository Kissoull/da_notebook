# 

# cmd命令: 连接数据库
# mysql -u root -p
# mysql -uroot -p12345

# 查询当前连接所有数据库
show databases;

# 连接所选数据库
use mysql_db;

# 查询当前数据库中所有表
show tables;

# 按产品名称排序
select prod_name
from products
order by prod_name;

# 按价格排序
select prod_id, prod_price, prod_name
from products
order by prod_price;

# 返回最贵的产品价格
select prod_price
from products
order by prod_price desc
limit 1;

# 返回价格等于$2.5的产品信息
select prod_name, prod_price
from products
where prod_price = 2.50;

# 返回fause产品信息
select prod_name, prod_price
from products
where prod_name = 'fuses';

# 不是供应商1003生产的产品
select vend_id, prod_name
from products
-- where vend_id <> 1003;
where vend_id != 1003;

# 
select prod_name, prod_price
from products
-- where 5 <= prod_price and prod_price <= 10;
where prod_price between 5 and 10;

# 空值检查
select cust_id
from customers
where cust_email is null;

# 指定范围
select prod_name, prod_price
from products
-- where vend_id in (1002, 1003)
where vend_id not in (1002, 1003)
order by prod_name;

# 模糊搜索
select prod_id, prod_name
from products
-- where prod_name like 'jet%';
-- where prod_name like '%anvil%';
where prod_name like '_ ton anvil';

# 正则表达式
select prod_name
from products
-- where prod_name regexp '.000'
-- where prod_name like '%000'
-- where prod_name regexp '1000|2000|3000'
-- where prod_name regexp '[123] ton'
-- where prod_name regexp '[1-5] ton'
-- where prod_name regexp '\\.'
-- where prod_name regexp '[[:digit:]]{4}'
-- where prod_name regexp '[0-9]{4}'
where prod_name regexp '^[0-9\\.]'
order by prod_name;

# 拼接字段
-- select concat(vend_name, '(', vend_country, ')')
select concat(rtrim(vend_name), '(', rtrim(vend_country), ')') as vend_title
from vendors
order by vend_name;

# 计算字段
select
	prod_id,
	quantity,
	item_price,
	quantity*item_price as expanded_price
from orderitems
where order_num = 20005;

# 函数
select vend_name, upper(vend_name) as vend_name_upcase
from vendors
order by vend_name;

# soundex()
select cust_name, cust_contact
from customers
-- where cust_contact = 'Y. Lie';
where soundex(cust_contact) = soundex('Y Lie');

# 日期格式必须为 yyyy-mm-dd
# date()和time()
select cust_id, order_num
from orders
where date(order_date) = '2005-09-01';

# 
select cust_id, order_num
from orders
-- where date(order_date) between '2005-09-01' and '2005-09-30';
where year(order_date) = 2005 and month(order_date) = 9;

# 聚集函数
# avg() 函数
select avg(prod_price) as avg_price
from products
where vend_id = 1003;

# count(*) count(column)
-- select count(*) as total_cust
-- from customers;
select count(cust_email) as num_cust
from customers;

# max() 函数
select max(prod_price) as max_price
from products;

# min() 函数
select min(prod_price) as min_price
from products;

# sum() 函数
-- select sum(quantity) as items_ordered
-- from orderitems
-- where order_num = 20005;
select sum(item_price*quantity) as total_price
from orderitems
where order_num = 20005;

# 在聚集函数中使用 distinct
select avg(distinct prod_price) as avg_price
from products
where vend_id = 1003;

# 使用多个聚集函数
select
	count(*) as num_items,
	min(prod_price) as price_min,
	max(prod_price) as price_max,
	avg(prod_price) as price_avg
from products;

# 分组
select vend_id, count(*) as num_prods
from products
group by vend_id;

# with rollup 得到所有分组
select vend_id, count(*) as num_prods
from products
group by vend_id with rollup;

# having 子句
select cust_id, count(*) as orders
from orders
group by cust_id
having count(*) >= 2

# where 和 having 子句联合使用
select vend_id, count(*) as num_prods
from products
where prod_price >= 10
group by vend_id
having count(*) >= 2;

# group by 别忘了使用 order by 排序
-- select order_num, sum(quantity*item_price) as order_total
-- from orderitems
-- group by order_num
-- having sum(quantity*item_price) >= 50;
select order_num, sum(quantity*item_price) as order_total
from orderitems
group by order_num
having sum(quantity*item_price) >= 50
order by order_total;

# 子查询
-- 查询包含'TNT2'的订单 -> 返回 20005,20007
select order_num
from orderitems
where prod_id = 'TNT2';
-- 查询订单20005,20007的客户id -> 返回 10001,10004
select cust_id
from orders
where order_num in (20005,20007);
-- 合并子查询
select cust_id
from orders
where order_num in (
	select order_num
	from orderitems
	where prod_id = 'TNT2'
);
--- 多层嵌套子查询 -> 查询购买了'TNT2'的客户信息
select cust_name, cust_contact
from customers
-- 查询客户id
where cust_id in (
	select cust_id
	from orders
	-- 查询订单号
	where order_num in (
		select order_num
		from orderitems
		where prod_id = 'TNT2'
	)
);

# 查询客户订单量
select
	cust_name,
	cust_state,
	( select count(*)
	from orders
	where orders.cust_id = customers.cust_id ) as orders
from customers
order by cust_name;

# 联结表
# 两种联结表的方法: where ... and ...  和 join ... on ...
select vend_name, prod_name, prod_price
from vendors, products
where vendors.vend_id = products.vend_id
order by vend_name, prod_name;

# 等值联结(equijoin)
-- select vend_name, prod_name, prod_price
-- from vendors, products
-- where vendors.vend_id = products.vend_id
-- order by vend_name, prod_name;
select vend_name, prod_name, prod_price
from vendors inner join products
	on vendors.vend_id = products.vend_id;

# 联结多个表
select prod_name, vend_name, prod_price, quantity
from orderitems, products, vendors
where products.vend_id = vendors.vend_id
	and orderitems.prod_id = products.prod_id
	and order_num = 20005;

# 联结表查询购买'TNT2'的客户信息
select cust_name, cust_contact
from customers, orders, orderitems
where customers.cust_id = orders.cust_id
	and orderitems.order_num = orders.order_num
	and prod_id = 'TNT2';
    
# 使用表别名, 缩短SQL语句
select cust_name, cust_contact
from customers as c, orders as o, orderitems as oi
where c.cust_id = o.cust_id
	and oi.order_num = o.order_num
    and prod_id = 'TNT2';
    
# 自联结: 从相同表中检索数据时, 使用自联结往往比子查询快
# 查询生产'DTNTR'的供应商的所有商品
select prod_id, prod_name
from products
where vend_id = (
	select vend_id
	from products
	where prod_id = 'DTNTR'
);
-- 使用 where 联结查询
select p1.prod_id, p1.prod_name
from products as p1, products as p2
where p1.vend_id = p2.vend_id
	and p2.prod_id = 'DTNTR';

# 自然联结
select c.*, o.order_num, o.order_date, oi.prod_id, oi.quantity, oi.item_price
from customers as c, orders as o, orderitems as oi
where c.cust_id = o.cust_id
	and oi.order_num = o.order_num
    and prod_id = 'FB';
   
# 查询所有客户及其订单
-- 内部联结: 查询所有客户及其订单, 不包括没有订单的客户
select customers.cust_id, orders.order_num
from customers inner join orders
	on customers.cust_id = orders.cust_id;
-- 外部联结: 查询所有客户及其订单, 包括没有订单的客户
select customers.cust_id, orders.order_num
from customers left outer join orders
	on customers.cust_id = orders.cust_id;

# 
select customers.cust_id, orders.order_num
from customers right outer join orders
	on orders.cust_id = customers.cust_id;
    
# 查询所有客户及每个客户所下的订单数
select
	customers.cust_name,
    customers.cust_id,
    count(orders.order_num) as num_ord
from customers inner join orders
	on customers.cust_id = orders.cust_id
group by customers.cust_id;

# 价格小于等于5的所有物品的一个列表，而且还想包括供应商1001和1002生产的所有物品（不考虑价格）
select vend_id, prod_id, prod_price
from products
where prod_price <= 5
-- 不包含重复行
union
-- 包含重复行
-- union all
select vend_id, prod_id, prod_price
from products
where vend_id in (1001,1002)
order by vend_id, prod_price
;
-- 
select vend_id, prod_id, prod_price
from products
where prod_price <= 5
	or vend_id in (1001,1002);
    
# 全文本搜索
select note_text
from productnotes
where match(note_text) against('rabbit');
-- 
select note_text
from productnotes
where note_text like '%rabbit%';
-- 
select note_text, match(note_text) against('rabbit') as nt_rank
from productnotes;

# 查询扩展
select note_text
from productnotes
-- where match(note_text) against('anvils');
where match(note_text) against('anvils' with query expansion);

# 布尔文本查询
-- 检索包含词heavy的所有行
select note_text
from productnotes
where match(note_text) against('heavy' in boolean mode);
-- 匹配包含heavy但不包含任意以rope开始的词的行
select note_text
from productnotes
where match(note_text) against('heavy -rope*' in boolean mode);
-- 匹配包含词rabbit和bait的行
select note_text
from productnotes
where match(note_text) against('+rabbit +bait' in boolean mode);
-- 匹配包含rabbit和bait中的至少一个词的行
select note_text
from prouctnotes
where match(note_text) against('rabbit bait' in boolean mode);
-- 匹配短语 (rabbit bait)
select note_text
from productnotes
where match(note_text) against('"rabbit bait"' in boolean mode);
-- 匹配rabbit和carrot，增加前者的等级，降低后者的等级
select note_text
from prouctnotes
where match(note_text) against('>rabbit <carrot' in boolean mode);
-- 匹配词safe和combination，降低后者的等级
select note_text
from prouctnotes
where match(note_text) against('+safe +(<combination)');

# 插入数据(增)
-- 依赖特定表次序的插入方法(不安全, 使用后一种)
insert into customers values(
	null,
	'Pep E. LaPew',
	'100 Mian Street',
	'Los Angles',
	'CA',
	'90046',
	'USA',
	null,
	null );
-- 指定列名插入(安全)
insert into customers (
	cust_name,
	cust_address,
	cust_city,
	cust_state,
	cust_zip,
	cust_country,
	cust_contact,
	cust_email )
values (
	'Pep E. LaPew',
	'100 Mian Street',
	'Los Angles',
	'CA',
	'90046',
	'USA',
	null,
	null );
-- 插入多条数据
insert into customers ( cust_name,
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country)
values ( 'Pep E. LaPew',
	'100 Mian Street',
	'Los Angles',
	'CA',
	'90046',
	'USA'),
    ( 'M. Mrtian',
    '42 Galaxy Way',
    'New York',
    'NY',
    '11213',
    'USA');
    
# 从custnew中将所有数据导入customers
-- 新建表custnew
create table if not exists custnew (
  cust_id      int       NOT NULL AUTO_INCREMENT,
  cust_name    char(50)  NOT NULL ,
  cust_address char(50)  NULL ,
  cust_city    char(50)  NULL ,
  cust_state   char(5)   NULL ,
  cust_zip     char(10)  NULL ,
  cust_country char(50)  NULL ,
  cust_contact char(50)  NULL ,
  cust_email   char(255) NULL ,
  PRIMARY KEY (cust_id)
) ENGINE=InnoDB;
-- 
insert into customers (cust_id,
	cust_contact,
    cust_email,
    cust_name,
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country)
select cust_id,
	cust_contact,
    cust_email,
    cust_name,
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country
from custnew;

# 更新数据(改)
-- 更新一列
update customers
set cust_email = 'elmer@fudd.com'
where cust_id = 10005;
-- 更新多个列
update customers
set cust_name = 'The Fudds',
	cust_email = 'elmer@fudd.com'
where cust_id = 10005;
-- 删除指定列值(如果允许, 替换为null)
update customers
set cust_email = null
where cust_id = 10005;

# 删除整行数据
delete from customers
where cust_id = 10006;

# 创建表
create table if not exists customers(
  cust_id      int       NOT NULL AUTO_INCREMENT,
  cust_name    char(50)  NOT NULL ,
  cust_address char(50)  NULL ,
  cust_city    char(50)  NULL ,
  cust_state   char(5)   NULL ,
  cust_zip     char(10)  NULL ,
  cust_country char(50)  NULL ,
  cust_contact char(50)  NULL ,
  cust_email   char(255) NULL ,
  PRIMARY KEY (cust_id)
) ENGINE=InnoDB;

# 更新表
-- 新增vendors表列vend_phone
alter table vendors
add vend_phone char(20);
-- 删除vendors表列vend_phone
alter table vendors
drop column vend_phone;

# 定义外键
alter table orderitems
add constraint fk_orderitems_orders
foreign key (order_num) references orders (order_num);
--
alter table orderitems
add constraint fk_orderitems_products
foreign key (prod_id) references products (prod_id);
-- 
alter table orders
add constraint fk_orders_customers foreign key (cust_id)
references customers (cust_id);
-- 
alter table products
add constraint fk_products_vendors
foreign key (vend_id) references vendors (vend_id);

# 删除表
drop table customers2;

# 重命名表
rename table customers2 to customers;

# 视图
-- 创建视图: 返回已订购了任意产品的所有客户的列表
create view productcustomers as 
select cust_name, cust_contact, prod_id
from customers as c, orders as o, orderitems as oi
where c.cust_id = o.cust_id
	and oi.order_num = o.order_num;
select * from productcustomers;
-- drop view productcustomers;

# 存储过程
-- 创建存储过程
delimiter //
create procedure productpricing()
begin
	select avg(prod_price) as priceaverage
    from products;
end //
delimiter ;
-- 调用存储过程
call productpricing();
-- 删除存储过程
drop procedure if exists productpricing;

-- 存储过程参数
delimiter //
create procedure productpricing(
	out pl decimal(8,2),
    out ph decimal(8,2),
    out pa decimal(8,2))
begin
	select min(prod_price)
    into pl
    from products;
    select max(prod_price)
    into ph
    from products;
    select avg(prod_price)
    into pa
    from products;
end //
delimiter ;
-- 调用存储过程
call productpricing(
	@pricelow,
    @pricehigh,
    @priceaverage);
-- 
select @priceaverage;
select @pricelow, @pricehigh, @priceaverage;
-- 删除存储过程
drop procedure if exists productpricing;

# in ..., out ...
-- Drop the procedure ordertotal
drop procedure if exists ordertotal;
delimiter //
create procedure ordertotal(
	in onumber int,
    out ototal decimal(8,2)
)
begin
	select sum(item_price* quantity)
    from orderitems
    where order_num = onumber
    into ototal;
end //
delimiter ;
-- 查询计算订单20005合计值
call ordertotal(20005, @total);
select @total;
-- 查询计算订单2000合计值
call ordertotal(20009, @total);
select @total;

# if ... then ... end if;
-- Drop the procedure ordertotal
drop procedure if exists ordertotal;
delimiter //
-- Name: ordertotal
-- Parameters: onumber = order number
-- 				taxable = 0 if not taxable, 1 if taxable
-- 				ototal = order total variable
create procedure ordertotal(
	in onumber int,
    in taxable boolean,
    out ototal decimal(8,2)
) comment 'Obtain order total, optionally adding tax'
begin
	-- Declare variable for total
    declare total decimal(8,2);
    -- Declare tax percentage
    declare taxrate int default 6;
    
    -- Get the order total
    select sum(item_price*quantity)
    from orderitems
    where order_num = onumber
    into total;
    
    -- Is this taxable?
    if taxable then
		-- Yes, so add taxrate to the total
        select total+(total/100*taxrate) into total;
	end if;
    
    -- And, finaly, save to out variabe
    select total into ototal;
end //
delimiter ;
-- 查询订单20005合计
call ordertotal(20005, 0, @total);
select @total;
-- 查询订单20005合计(包含营业税)
call ordertotal(20005, 1, @total);
select @total;
-- 查询存储过程orertotal的详细信息
show create procedure ordertotal;
-- 查询存储过程
-- show procedure status;
show procedure status like 'ordertotal';

# 游标
-- 删除存储过程
drop procedure if exists processorders;
-- 创建游标
delimiter //
create procedure processorders()
begin
	declare ordernumbers cursor
	for 
    select order_num from orders;
end //
delimiter ;
-- 打开游标, 关闭游标(打开关闭成对使用)
open ordernumbers;
close ordernumbers;

# 申明, 打开, 关闭游标
-- 删除存储过程
drop procedure if exists processorders;
delimiter //
create procedure processorders()
begin
	-- Declare the cursor
    declare ordernumbers cursor
    for
    select order_num from orders;
    
    -- Open the cursor
    open ordernumbers;
    
    -- close the cursor
    close ordernumbers;
end //
delimiter ;

# 从游标中检索第一行
-- 删除存储过程
drop procedure if exists processorders;
delimiter //
create procedure processorders()
begin
	-- Declare local varibles
    declare o int;
    
    -- Declare the cursor
    declare ordernumbers cursor
    for
    select order_num from orders;
    
    -- Open the cursor
    open ordernumbers;
    
    -- Get order number
    fetch ordernumbers into o;
    
    -- Close the cursor
    close ordernumbers;
end //
deilmiter ;

# 从游标中循环检索
-- 删除存储过程
drop procedure if exists processorders;
delimiter //
create procedure processorders()
begin
	-- Declare local varibles
    declare done boolean default 0;
    declare o int;
    
    -- Declare the cursor
    declare ordernumbers cursor
    for
    select order_num from orders;
    -- Declare continue handler
    declare continue handler for sqlstate '02000' set done=1;
    
    -- Open the cursor
    open ordernumbers;
    
    -- Loop through all rows
    repeat
		-- Get order number
        fetch ordernumbers into o;
	-- End of loop
    until done end repeat;
    
    -- Close the cursor
    close ordernumbers;
end //
delimiter ;

# 完整的游标范例
-- Drop the procedure ordertotal
drop procedure if exists ordertotal;
-- Create the procedure ordertotal
delimiter //
create procedure ordertotal(
	in onumber int,
    in taxable boolean,
    out ototal decimal(8,2)
) comment 'Obtain order total, optionally adding tax'
begin
	-- Declare variable for total
    declare total decimal(8,2);
    -- Declare tax percentage
    declare taxrate int default 6;
    
    -- Get the order total
    select sum(item_price*quantity)
    from orderitems
    where order_num = onumber
    into total;
    
    -- Is this taxable?
    if taxable then
		-- Yes, so add taxrate to the total
        select total+(total/100*taxrate) into total;
	end if;
    
    -- And, finaly, save to out variabe
    select total into ototal;
end //
delimiter ;
-- Test the procedure ordertotal
call ordertotal(20005, 0, @total);
select @total;
-- Drop the procedure processorders
drop procedure if exists processorders;
-- Create the procedure processorders
delimiter //
create procedure processorders()
begin
	-- Declare local variables
    declare done boolean default 0;
    declare o int;
    declare t decimal(8,2);
    
    -- Declare the cursor
    declare ordernumbers cursor
    for
    select order_num from orders;
    -- Declare continue handler
    declare continue handler for sqlstate '02000' set done=1;
    
    -- Create a table to store the results
    create table if not exists ordertotals(
		order_num int, total decimal(8,2));
        
	-- Open the cursor
    open ordernumbers;
    
    -- Loop through all rows
    repeat
		-- Get order number
        fetch ordernumbers into o;
        
        -- Get the total for this order
        call ordertotal(o, 1, t);
        
        -- Insert order and total into ordertotals
        insert into ordertotals(order_num, total)
        values (o, t);
        
	-- End of loop
    until done end repeat;
    
    -- Close the cursor
    close ordernumbers;
end //
delimiter ;
-- Select ordertotals
select *
from ordertotals;

# 触发器
desc products;
select distinct *
from products
where vend_id = 1001;
drop trigger if exists newproduct;
create trigger newproduct after insert on products
for each row select 'Product added!' into @arg;
insert into products(prod_id, vend_id, prod_name, prod_price, prod_desc)
values('comp', 1001, 'computer', 9999, 'A Nice Computer');
select @arg;
drop trigger if exists newprouct;

# insert触发器
-- 删除触发器
drop trigger if exists neworder;
-- 创建触发器
create trigger neworder after insert on orders
for each row select new.order_num into @arg;
-- 插入值
insert into orders(order_date, cust_id)
values (now(), 10001);
select @arg;
-- 删除触发器
drop trigger if exists neworder;

# delete触发器
-- Drop the trigger deleteorder
drop trigger if exists deleteorder
-- Create the trigger deleteorder
delimiter //
create trigger deleteorder before delete on orders
for each row
begin
	insert into archive_orders( order_num, order_date, cust_id )
    values ( old.order_num, old.order_date, old.cust_id );
end //
delimiter ;

# update触发器
-- Drop the trigger upd_vender
drop trigger if exists upd_vendor
-- Create the trigger upd_vender
-- 保证州名缩写总是大写(不管UPDATE语句中给出的是大写还是小写)
delimiter //
create trigger upd_vendor before update on vendors
for each row
begin
	set new.vend_state = upper( new.vend_state );
end; //
delimiter ;

# 事务处理(transaction processing)
select * from custnew;
-- 事务开始
start transaction;
-- 保留点(复杂一般设置越多越好, 简单事务也可以没有)
savepoint delete1;
delete from custnew
where cust_id = 10010;
select * from custnew;
-- 回滚到保留点
rollback to delete1;
-- 回滚(自动释放保留点)
rollback;
select * from custnew;
-- 提交(自动释放保留点)
commit;

# 更改默认提交行为(设为不自动提交)
-- set autocommit=0;

# 字符集和校对
-- 显示所有可用的字符集以及每个字符集的描述和默认校对
show character set;
-- 查看所支持校对的完整列表
show collation;
-- 查看所用的字符集和校对
show variables like 'character%';
show variables like 'collation%';
-- 对表指定字符集和校对
create table if not exists mytable(
	col1 int,
    col2 varchar(10)
) default character set hebrew
collate hebrew_general_ci;
-- 对列指定字符集和校对
create table if not exists mytable(
	col1 int,
    col2 varchar(10),
    col3 varchar(10) character set latin1 collate latin1_general_ci
) default character set hebrew
collate hebrew_general_ci;
-- 临时区分大小写
select * from customers
order by lastname, firstname collate latinl_general_cs;

# 安全管理(多用户, 分权限)
use mysql;
-- 查看账户
select user from user;
-- 创建用户
create user lee identified by '0000';
-- 重命名用户
rename user lee to jack;
-- 删除用户
drop user jack;
-- 权限控制
show grants for lee;
-- 授予用户lee对数据库mysql_db只读权限
grant select on mysql_db.* to lee;
-- 撤销用户lee对数据库mysql_db只读权限
revoke select on mysql_db.* to lee;
-- 更改用户口令
set password for 'lee' = old_password('0000');

# 数据库维护
-- 检查表键
analyze table orders;
-- 检查多个问题
check table orders, orderitems;

# 查看数据库编码格式
show variables like 'character%';

# 改善性能
-- 查看系统变量
show variables;
-- 查看服务器状态信息
show status;
-- 显示所有进程
show processlist;
-- 结束进程
-- kill [processname];

# 窗口排序函数
-- rank()

-- dense_rank()

-- row_number()


    







