# MySQL必知必会

| Author | Date |
| :--- | :--- |
| Kissoul | 2021/08/03 |

------
=== 目录 ===  

[TOC]  
------


## SQL 基本定义
MySQL --- 关系型数据库, 非常适合小批量数据库的处理, 大型数据库一般使用 Oracle; NoSQL --- 非关系型数据库, MongoDB 是一种常用的非关系型数据库

### 数据库管理系统(DBMS)
DBMS --- 数据库管理软件

- 数据库(database): 有组织的数据容器(通常是一个文件或一组文件)
- 表(table): 某类数据的结构化清单
- 模式(schema): 关于数据库和表的布局及特性的信息

### 基本术语
- 列(column): 表中的一个字段, 特征
- 数据类型(datatype): 每个列都有唯一的数据类型
- 行(row): 表中的一个记录(数据库记录, record), 样本
- 主键(primary key): 数据唯一标志列, 其值(唯一不变)能够唯一区分表中每个行(应该总定义主键)

- 子句(clause): 

### 命名规范

#### 基本命名规则
- 使用有意义的英文词汇, 词汇中间以下划线分隔(例如: 数据库名_表名)
- 只能使用英文字母, 数字, 下划线, 并以英文字母开头
- 库、表、字段全部采用小写, 不要使用驼峰式命名
- 避免用 ORACLE, MySQL 的保留字如 desc, 关键字如 index
- 见名知意, 不宜过长(32 个字符以内), 使用名词而不是动词, 不要使用复数
- 数据库, 数据表一律使用前缀
	- 临时库(表)必须以 tmp 前缀, 日期后缀
	- 备份库(表)必须以 bak 前缀, 日期后缀

#### 为什么库, 表, 字段要全小写
- Windows 下是不区分大小写的
- Linux下大小写规则: 
	- 数据库名与表名是严格区分大小写的
	- 表的别名是严格区分大小写的
	- 列名与列的别名在所有的情况下均是忽略大小写的
	- 变量名也是严格区分大小写的

如果已经设置了驼峰式的命名如何解决? 需要在MySQL的配置文件 my.ini 中增加 lower_case_table_names = 1 即可

#### 常用表名约定
```
user 用户
cust 顾客
category 分类
goods 商品、物品
good_gallery 物品相册
good_cate 物品分类
attr 属性
article 文章
cart 购物差
feedback 用户反馈
order 订单
site_nav 页头和页尾导航
site_config 系统配置表
admin 后台用户
role 后台用户角色
access 后台操作权限
role_admin 后台用户对应的角色
access_role 后台角色对应的权限
```

#### 示例
| table_name | column_name |
| --- | --- |
| cust_table(顾客表) | cust_id(primary key) | cust_name | cust_addr | cust_order |
| order_table(订单表) | cust_id(primary key) | order_id | order_price |

## SQL 语法
语句(query) --- 子句(clause) --- 关键字(key word)/操作符(operator)/字段(field)/谓词(predicate) --- 通配符(wildcard)

- **SELECT**: 查询语句
	- 子句: 
		- **DISTINCT**: 去重(用于所有列)
		- **CONCAT()**: 字段, 拼接(sql 使用 '+' 或 '||')
		- **AS**: 关键字, 取别名(也叫导出列, derived column), 常用于重命名不合规或易混淆的表列名
	- **FROM**: 选择数据表
	- **ORDER BY**: 排序(就近优先排序)
		- **DESC**: 关键字, 降序(只对指定列降序)
		- **ASC**: 关键字, 升序(default)
	- **WHERE**: 子句, 过滤条件(filter condition), 注意使用明确的括号分组条件操作符
		- **BETWEEN cond1 AND cond2**: 关键字, 范围查询
		- **IS NULL**: 关键字, 空值检查
		- **AND**: 操作符, 与条件, 优先级大于OR
		- **OR**: 操作符, 或条件, 优先级小于AND
		- **IN**: 操作符, 指定范围, 可以包含其他 select 语句, 执行比 OR 更快
		- **NOT**: 关键字, 否定后跟条件
		- **LIKE**: 谓词, 模糊搜索
			- 通配符: 非必要不使用通配符, 使用函数来处理空格
				- '%': 匹配任意字符, 除了 NULL
				- '_': 匹配单个字符
		- **REGEXP**: 正则表达式
			- '.': 匹配任意一个字符
			- '|': OR 匹配
			- '[]': 匹配几个字符之一
			- '^': NOT 匹配
			- '-': [0-9] 和 [a-z], 范围匹配(任意区间)
			- '\\': 
				- 转义(escaping), 例如: \\. \\- \\\ 等
				- 引用元字符: '\\f': 换页 '\\n': 换行 '\\r': 回车 '\\t': 制表 '\\v': 纵向制表
		- **BINARY**: 关键字, 正则表达式匹配大小写
	- **GROUP BY**: 分组
	- **HAVING**: 聚合(**where 在数据分组前过滤, having 在数据分组后过滤**; where 过滤行, having 过滤分组)
- **LIMIT**: 限制输出
	- **LIMIT n**: 只返回 n 行结果
	- **LIMIT t OFFSET s**: 从行 s 开始的 t 行(相当于: LIMIT s, t)

## 常用表

### 字符类
| 类 | 说明 |
| --- | ---  |
| [:alnum:] | 任意字母和数字（同[a-zA-Z0-9]） |
| [:alpha:] | 任意字符（同[a-zA-Z]） |
| [:blank:] | 空格和制表（同[\\t]） |
| [:cntrl:] | ASCII控制字符（ASCII 0到31和127） |
| [:digit:] | 任意数字（同[0-9]） |
| [:graph:] | 与[:print:]相同，但不包括空格 |
| [:lower:] | 任意小写字母（同[a-z]） |
| [:print:] | 任意可打印字符 |
| [:punct:] | 既不在[:alnum:]又不在[:cntrl:]中的任意字符 |
| [:space:] | 包括空格在内的任意空白字符（同[\\f\\n\\r\\t\\v]） |
| [:upper:] | 任意大写字母（同[A-Z]） |
| [:xdigit:] | 任意十六进制数字（同[a-fA-F0-9]） |

### 重复元字符
| 元字符 | 说明 |
| --- | --- |
| * | 0个或多个匹配 |
| + | 1个或多个匹配（等于{1,}） |
| ? | 0个或1个匹配（等于{0,1}） |
| {n} | 指定数目的匹配 |
| {n,} | 不少于指定数目的匹配 |
| {n,m} | 匹配数目的范围（m不超过255） |

### 定位元字符
| 元字符 | 说明 |
| --- | --- |
| ^ | 文本的开始 |
| $ | 文本的结尾 |
| [[:<:]] | 词的开始 |
| [[:>:]] | 词的结尾 |

## 函数

### 字符串处理函数
| 函数 | 说明 |
| --- | --- |
| Left() | 返回串左边的字符 |
| Length() | 返回串的长度 |
| Locate() | 找出串的一个子串 |
| Lower() | 将串转换为小写 |
| LTrim() | 去掉串左边的空格 |
| Right() | 返回串右边的字符 |
| RTrim() | 去掉串右边的空格 |
| Soundex() | 返回串的SOUNDEX值 |
| SubString() | 返回子串的字符 |
| Upper() | 将串转换为大写 |

### 日期和时间处理函数
| 函数 | 说明 |
| --- | --- |
| AddDate() | 增加一个日期（天、周等） |
| AddTime() | 增加一个时间（时、分等） |
| CurDate() | 返回当前日期 |
| CurTime() | 返回当前时间 |
| Date() | 返回日期时间的日期部分 |
| DateDiff() | 计算两个日期之差 |
| Date_Add() | 高度灵活的日期运算函数 |
| Date_Format() | 返回一个格式化的日期或时间串 |
| Day() | 返回一个日期的天数部分 |
| DayOfWeek() | 对于一个日期，返回对应的星期几 |
| Hour() | 返回一个时间的小时部分 |
| Minute() | 返回一个时间的分钟部分 |
| Month() | 返回一个日期的月份部分 |
| Now() | 返回当前日期和时间 |
| Second() | 返回一个时间的秒部分 |
| Time() | 返回一个日期时间的时间部分 |
| Year() | 返回一个日期的年份部分 |

### 数值处理函数
| 函数 | 说明 |
| --- | --- |
| Abs() | 返回一个数的绝对值 |
| Cos() | 返回一个角度的余弦 |
| Exp() | 返回一个数的指数值 |
| Mod() | 返回除操作的余数 |
| Pi() | 返回圆周率 |
| Rand() | 返回一个随机数 |
| Sin() | 返回一个角度的正弦 |
| Sqrt() | 返回一个数的平方根 |
| Tan() | 返回一个角度的正切 |

### 聚集函数(aggregate function)
| 函数 | 说明 |
| --- | --- |
| AVG() | 返回某列的均值 |
| COUNT() | 返回某列的行数 |
| MAX() | 返回某列的最大值 |
| MIN() | 返回某列的最小值 |
| SUM() | 返回某列值之和 |

### 分组数据
select 子句及其顺序

| 子句 | 说明 | 是否必须使用 |
| --- | --- |
| SELECT | 要返回的列或表达式 | 是 |
| FROM | 从中检索数据的表 | 仅在从表选择数据时使用 |
| WHERE | 过滤行 | 否 |
| GROUP BY | 分组 | 仅在按组计算聚集时使用 |
| HAVING | 过滤分组 | 否 |
| ORDER BY | 输出排序 | 否 |
| LIMIT | 要检索的行数 | 否 |

## 子查询
子查询是自内向外处理的, 使用子查询即嵌套查询

- 相关子查询: 涉及外部查询的子查询, 即在多个表中查询

## 联结表
使用 where 或 join 进行联结表(MySQL 中的表为关系表)

- where ... and ... and ...
- inner join ... on ...
- left/right outer join ... on ...

## 组合查询(union, compound query)
```sql
query1
union
query2
...;
```

## 全文本搜索
- FULLTEXT: 子句, 创建全文本索引
- match(...) against(...): 使用全文本索引

## 布尔文本搜索

**表.全文本布尔操作符**

| 布尔操作符 | 说明 |
| --- | --- |
| + | 包含，词必须存在 |
| - | 排除，词必须不出现 |
| > | 包含，而且增加等级值 |
| < | 包含，且减少等级值 |
| () | 把词组成子表达式（允许这些子表达式作为一个组被包含、排除、排列等） |
| ~ | 取消一个词的排序值 |
| * | 词尾的通配符 |
| "" | 定义一个短语（与单个词的列表不一样，它匹配整个短语以便包含或排除这个短语） |

## 插入数据(增)
- 插入数据: insert into ... column(...) values (...);
- 降低插入优先级: insert low_priority into ... column(...) values (...);
- 插入多条数据: insert into ... column(...) values (...), (...)...

## 更新数据(改)
- 更新数据: update ... set ... where ...;
- 更新数据(忽略错误): update ignore ... set ... where ...;

## 删除表(数据)
- 删除数据: delete from ... where ...;

## 创建表
- **引擎类型:**
	1. **InnoDB:** 适合***事务处理***, 不支持全文本搜索
	2. **MEMORY:** 数据存储在内存, 适合***临时表***
	3. **MyISAM:** 适合***全文本搜索***, 不支持事务处理

## 更新表
- 增加/删除: alter table ... add/drop ...;
- 定义外键: 

## 删除表(结构+数据)
- 删除整张表: drop table ...;

## 重命名表
- 重命名表: rename table ... to ...;

## 视图
- 重用sql语句的一种方式, 和函数类似  
- 视图一般用于**检索**

## 存储过程
```sql
# 创建存储过程
delimiter //
create procedure ...()
begin
	...;
end //
delimiter ;
```

```sql
# 调用存储过程
call ...();
```

## 游标(cursor)

## 触发器

## 事务处理(transaction processing)

## 安全管理

## 数据库维护



# MySQL命令行

## 创建新用户
```sh
create user 'username'@localhost identifited by 'secret_password';
grant all privileges on 'database_name'.* to 'username'@'localhost';
flush privileges;
```

## 连接, 退出数据库
- 连接数据库服务
```sh
mysql -u root -p
$ mysql -uroot -p12345
mysql -h localhost -P 3306 -u root -p
```

## 修改用户密码
```mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345';
```

- 退出数据库
```sh
exit
\q
```

## 数据库操作: 显示, 创建, 使用, 删除
- 显示所有的数据库文件(类似打开excel文件目录): 
```sh
show databases;
```
- 创建数据库 (类似创建excel文件): 
```sh
create database test;
```
- 使用某个数据库(相当于打开一个excel文件): 
```sh
use test;
```
- 查看数据表(相当于看看有哪些 sheet): 
```sh
show tables;
```
- 删除库(相当于删除excel): 
```sh
drop database test;
```

## 数据表操作: 创建表, 删除表, 查看表结构, 查看表
- 创建表(相当于我们在 excel 中新建一个sheet，然后sheet的首行规定每一列该填什么，如姓名，年龄，性别):
```sh
create table [if not exists] 表名称 (
			字段名1  列类型 [属性] [约束] [注释],
			字段名2  列类型 [属性] [约束] [注释],
			......
			字段名n  列类型 [属性] [约束] [注释]
		);
```
- 删除表(相当于在excel 中删除一个存在的sheet, 删除表时需要确保改数据库没有被使用): 
```sh
drop table (表名称);
```
- 查看表结构: 
```sh
desc (表名称);
```
- 查看数据表: 
```sh
show tables;
```

## 数据类型
1. 数值
	- 整型: int, bigint
	- 浮点型: float, double
2. 字符串
	- char(m)
	- varchar(m) varchar(20) 表示20个字符
	- text
	- longtext：存个小说
3. 日期
	- date 2019-8-3
	- datetime 2019-8-3 10:05:30
	- timestamp 时间戳
	- time 10:05:30

## 属性与约束
- null 空
- not null 不为空
- default 默认值如： 上面的 age : age int default 18,
- unique key 唯一设置某个列的值都是唯一的，也就是没用重复,如 身份证号，一般是唯一的
- primary key : 主键唯一标示(自带唯一属性，not null属性)一个表中必须有的,一般都是数字自增
- auto_increment: 自增长 必须给主键设置 ，int ,它的数值是不会回退的
- foreign key : 外键 减少冗余，用来与其他表连接。
- 语法： constraint 你给外键取的名字 foreign key (你想引用到外键的列名称) references 参考表的表名(列名称且这个列名称是有主键属性)

## 更改表结构
- 更改表名称
> 语法：alter table (旧表名) rename as (新表名)  
> 如：-> alter table class1 rename as classOne;  
- 添加字段
> 语法：alter table (表名称) add (字段名) (列类型)[属性][约束]  
> 如:-> alter table class2 add phone varchar(20);  
- 删除字段
> 语法：alter table (表名称) drop (字段名)
- 更改字段名称
> 语法：alter table (表名) change (旧字段名) (新字段名)(列类型)[属性][约束]  
> 如：-> alter table class2 change name stu_name varchar(20) not null;  
- 更改属性：
> 语法： alter table (表名称) modity (字段名) ( 列类型) [属性][约束]  
> 如:-> alter table class2 modify stu_name varchar(50) not null;  
- 增加外键：
> 语法： alter table (你要增加外键的表名) add constraint (你给外键取的名字)( foreign key (你想引用到外键的列名称) references (参考表的表名)(列名称且这个列名称是有主键属性)  
> 如: alter table *emp* add constraint *fk_dno* foreign key(*deptno*) references *dept*(*deptno*);

## 练习
1. 创建库goods
```cmd
create database goods;
```
2. 使用goods库
```cmd
use goods;
```
3. 创建商品种类表 commoditytype
4. 创建商品表 commodity
> c_id 主键 自增长  
> c_name 50个字的字符串 不为空 
> c_madein 50个字的字符串 不为空  
> c_type ，整型，外键关联到 商品表的 ct_id  
> c_inprice ,整型 不为空  
> c_outprice,整型 不为空  
> c_num, 整数 默认 100  
```cmd
create table if not exists commodity_type(
	ct_id int primary key auto_increment,
	ct_name varchar(50) not null
)default charset=utf8;
```

```cmd
create table if not exists commodity(
	c_id int primary key auto_increment,
	c_name varchar(50) not null,
	c_madein varchar(50) not null,
	c_type int,
	c_outprice int not null,
	c_num int default 100
)default charset=utf8;
alter table commodity add constraint fk_ctype foreign key (c_type) references commodity_type(ct_id);
```

## 表数据: 增删改查
1. 插入数据
```cmd
insert into [table_name] ([column],…) values(“name”,…);
```
2. 删除行数据
```cmd
delete from [table_name] where [column_name] = " ";
```
3. 更改数据值
```cmd
update [table_name] set [columns] = " ",[columns] = " " where /;
```
4. 按照统计要求查询数据
```cmd
按照NCEE_grade升序展示: select * from student order by NCEE_grade desc;
分组统计每一个column出现的次数: select [column],count(*) (as [name])from student group by [column];
根据column1的分组 分别计算每一组的column2的总值: select [column1],sum(column2) from student group by [column1];
根据column1的分组 分别计算每一组的column2的总值 并且 统计总人数：select coalesce(column1,“total_num”),sum(column2) as [name] from student group by [column1] with rollup;
```
# navicat中常用快捷键总结
1. Ctrl+q就会弹出一个sql输入窗口
2. Ctrl+r就执行sql了
3. 按f6会弹出一个命令窗口
4. Ctrl+/ 注释
5. Ctrl +Shift+/ 解除注释
6. Ctrl+R 运行选中的SQL语句
7. Ctrl+Shift+R 只运行选中的sql语句
8. Ctrl+L 删除选中行内容
9. Ctrl+D 表的数据显示显示页面切换到表的结构设计页面，但是在查询页面写sql时是复制当前行并粘贴到下一行
10. Ctrl+N 打开一个新的查询窗口
11. Ctrl+W 关闭当前查询窗口
12. 鼠标三击选择当前行

## SQL执行顺序: F-W-G-S-H-O
1. FROM
2. WHERE
3. GROUP BY
4. SELECT
5. HAVING
6. ORDER BY
7. LIMIT

## MySQL处理事务
- 开始: BEGIN
- 事务回滚: ROLLBACK
- 确认: COMMIT
- 提交模式: SET AUTOCOMMIT = 0(禁止自动提交) | 1(开启自动提交)

## 索引
- 索引也是一张表, 该表保存了主键与索引字段, 并指向实体表的记录
- 虽然索引大大提高了查询速度, 同时却会降低更新表的速度

### 普通索引
- 创建索引
```MySQL
CREATE INDEX indexName ON table_name (column_name);
```
- 修改表结构
```MySQL
ALTER table table_name ADD INDEX indexName(columnName);
```
- 创建表时指定索引
```MySQL
CREATE TABLE table_name (
	ID INT NOT NULL,
	username VARCHAR(16) NOT NULL,
	INDEX [indexName] (username(length))
)DEFAULT CHARSET(utf8);
```
- 删除索引
```MySQL
DROP INDEX [indexName] ON table_name;
```

### 唯一索引
- 创建索引
```MySQL
CREATE UNIQUE INDEX indexName ON mytable(username(length));
```
- 修改表结构
```MySQL
ALTER table table_name ADD UNIQUE [indexName] (username(length));
```
- 创建表时指定索引
```MySQL
CREATE TABLE table_name (
	ID INT NOT NULL,
	username VARCHAR(16) NOT NULL,
	UNIQUE INDEX [indexName] (username(length))
)DEFAULT CHARSET(utf8);
```

### 使用ALTER 命令添加和删除索引
- ALTER TABLE tbl_name ADD PRIMARY KEY (column_list): 该语句添加一个主键，这意味着索引值必须是唯一的，且不能为NULL。
- ALTER TABLE tbl_name ADD UNIQUE index_name (column_list): 这条语句创建索引的值必须是唯一的（除了NULL外，NULL可能会出现多次）。
- ALTER TABLE tbl_name ADD INDEX index_name (column_list): 添加普通索引，索引值可出现多次。
- ALTER TABLE tbl_name ADD FULLTEXT index_name (column_list):该语句指定了索引为 FULLTEXT ，用于全文索引。

### 使用 ALTER 命令添加和删除主键


### 显示索引信息


## 获取服务器元数据
- 获取SQL服务器版本信息
```MySQL
SELECT VERSION();
```
- 当前数据库名 (或者返回空)
```MySQL
SELECT DATABASE();
```
- 当前用户名
```MySQL
SELECT USER();
```
- 获取服务器状态
```MySQL
SHOW STATUS;
```
- 服务器配置变量
```MySQL
SHOW VARIABLES;
```

## 
- 统计重复数据
```MySQL
SELECT 
	COUNT(*) as repetdata
FROM
	runoob_tb1
GROUP BY
	runoob_title, runoob_author
HAVING repetdata > 1;
```
- 过滤重复数据
```MySQL
SELECT DISTINCT
	runoob_author
FROM
	runoob_tb1;
```
- 删除重复数据
```MySQL
CREATE TABLE tmp SELECT
	runoob_author 
FROM
	runoob_tb1 
GROUP BY
	runoob_title,
	runoob_author;
DROP TABLE runoob_tb1;
ALTER TABLE tmp RENAME TO runoob_tb1;
```

## 正则表达式

### 限定符
- 限定符: ab?, ab*c, ab{2,6}c, (ab)+
- xx(str1|str2) [ab] [^a-zA-Z0-9]

### 元字符
\d+: 数字字符
\w+: 单词字符(英文, 数字, 下划线)
\s+: 空白字符(tab制表符, 换行符)
\D+: 非数字字符
\W+: 非单词字符
\S+: 非空白字符
.*: 任意字符
^: 匹配行首
$: 匹配行尾

### 贪婪(Greedy Match)与懒惰匹配(Lazy Match)
<span><b>This is a sample text</b></span>
懒惰匹配: <.+?>

### 实例
- RGB颜色识别
```txt
#00
#ffffff
#ffaaff
#00hh00
#aabbcc
#000000
#ffffffff
```
> #[a-fA-F0-9]{6}\b

- IPv4地址匹配
```txt
123
255.255.255.0
192.168.0.1
0.0.0.0
256.1.1.1
This is a string.
123.123.0
```
> \b((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)\b

## 





