# 牛客网SQL题解
## 1. 查找employees里最晚入职员工的所有信息
- 通过排序
```sql
select *
from employees
order by hire_date desc;
```

- 子查询
```sql
select *
from employees
where hire_date = (
    select max(hire_date)
    from employees
);
```

## 2. 查找employees里入职员工时间排名倒数第三的员工所有信息
- 多层嵌套子查询
```sql
select *
from employees
where hire_date = (
    select max(hire_date)
    from employees
    where hire_date < (
        select max(hire_date)
        from employees
        where hire_date < (
            select max(hire_date)
            from employees
        )
    )
)
```

- 倒序使用限制输出
```sql
select *
from employees
where hire_date = (
    select hire_date
    from employees
    order by hire_date desc
	-- 跳过2行从第1行开始
    limit 1 offset 2
);
```

## 3. 查找各个部门领导薪水详情以及其对应部门编号dept_no，输出结果以salaries.emp_no升序排序，并且请注意输出结果里面dept_no列是最后一列
- 联结表 inner join
```sql
select
    s.*,
    dm.dept_no
from salaries as s inner join dept_manager as dm
on s.emp_no = dm.emp_no
where s.to_date = '9999-01-01'
    and dm.to_date = '9999-01-01'
order by s.emp_no;
```

- 联结表 where ... and ...
```sql
select
    s.*,
    dm.dept_no
from salaries as s, dept_manager as dm
where s.emp_no = dm.emp_no
	and s.to_date = '9999-01-01'
	and dm.to_date = '9999-01-01'
order by s.emp_no;
```

## 4. 查找所有已经分配部门的员工的last_name和first_name以及dept_no，未分配的部门的员工不显示
- 笛卡尔积
```sql
select
    e.last_name,
    e.first_name,
    de.dept_no
from employees as e, dept_emp as de
where e.emp_no = de.emp_no;
```

- inner join
```sql
select
	e.last_name,
	e.first_name,
	de.dept_no
from employees as e inner join dept_emp as de
on e.emp_no = de.emp_no;
```

## 5. 查找所有已经分配部门的员工的last_name和first_name以及dept_no，也包括暂时没有分配具体部门的员工
- left join
```sql
select
    e.last_name,
    e.first_name,
    de.dept_no
from employees as e left join dept_emp as de
on e.emp_no = de.emp_no;
```

## 6. 查找薪水记录超过15次的员工号emp_no以及其对应的记录次数t
- group by ... having ...
```sql
select distinct emp_no, count(emp_no) as t
from salaries
group by emp_no
having t > 15
order by emp_no;
```

## 7. 找出所有员工具体的薪水salary情况，对于相同的薪水只显示一次,并按照逆序显示
- 小表: distinct
```sql
select distinct salary
from salaries
where to_date = '9999-01-01'
order by salary desc;
```

- 大表: group by
```sql
select salary
from salaries
where to_date = '9999-01-01'
group by salary
order by salary desc;
```

## 8. 找出所有非部门领导的员工emp_no
- 子查询
```sql
select emp_no
from employees
where emp_no not in (
    select emp_no
    from dept_manager
)
order by emp_no;
```

- 联结表
```sql
select e.emp_no
from employees as e left join dept_manager as dm
on e.emp_no = dm.emp_no
where dept_no is null
order by e.emp_no;
```

## 9. 获取所有的员工和员工对应的经理，如果员工本身是经理的话则不显示
- where
```sql
select de.emp_no, dm.emp_no as manager
from dept_emp as de, dept_manager as dm
-- 必须为在同一部门的员工和经理
where de.dept_no = dm.dept_no
	-- 必须为在职员工
    and dm.to_date = '9999-01-01'
	-- 员工本身是经理就不显示
    and de.emp_no <> dm.emp_no
order by emp_no;
```

## 10. 获取每个部门中员工薪水最高的相关信息，给出dept_no, emp_no以及其对应的salary，按照部门编号升序排列
-
```sql
select de.dept_no, de.emp_no, s.salary as maxSalary
from dept_emp as de inner join salaries as s
on de.emp_no = s.emp_no
    -- 在职员工
    and de.to_date = '9999-01-01'
    and s.to_date = '9999-01-01'
where s.salary = (
	-- 最高薪水
    select max(s2.salary)
    from dept_emp as de2 inner join salaries as s2
    on de2.emp_no = s2.emp_no
        and de2.to_date = '9999-01-01'
        and s2.to_date = '9999-01-01'
	-- 同一部门
    where de2.dept_no = de.dept_no
    group by de2.dept_no )
-- 按部门编号排序
order by de.dept_no;
```

- 窗口排序函数
```sql
select d.dept_no, d.emp_no, d.salary
from (
	select
		dense_rank() over (partition by c.dept_no order by c.salary desc) as raking,
		c.dept_no,
		c.emp_no,
		c.salary
    from (
		select a.dept_no, a.emp_no, b.salary
		from dept_emp a inner join salaries b
		on a.emp_no = b.emp_no
		where a.to_date = '9999-01-01'
			and b.to_date = '9999-01-01'
		) c
	) d
where d.raking = 1
order by d.dept_no
```

## 11. 查找employees表所有emp_no为奇数，且last_name不为Mary的员工信息，并按照hire_date逆序排列
- 使用取模%
```sql
select *
from employees
where emp_no % 2 = 1
    and last_name <> 'Mary'
order by hire_date desc;
```

- 使用按位与&
```sql
select *
from employees
where emp_no & 1
    and last_name <> 'Mary'
order by hire_date desc;
```

## 12. 统计出各个title类型对应的员工薪水对应的平均工资avg。结果给出title以及平均工资avg，并且以avg升序排序
- where
```sql
select t.title, avg(s.salary)
from titles as t inner join salaries as s
on t.emp_no = s.emp_no
    -- 在职员工
    and t.to_date = '9999-01-01'
    and s.to_date = '9999-01-01'
-- 按部门分组
group by t.title
order by avg(s.salary);
```

- inner join ... on ...
```sql
select t.title, avg(s.salary)
from titles as t inner join salaries as s
on t.emp_no = s.emp_no
group by t.title
order by avg(s.salary);
```

## 13. 获取薪水第二多的员工的emp_no以及其对应的薪水salary
- order by
```sql
select emp_no, salary
from salaries
where to_date = '9999-01-01'
order by salary desc
limit 1 offset 1;
```

- group by
```sql
select emp_no, salary
from salaries
where salary = (
    select salary
    from salaries
    where to_date = '9999-01-01'
    group by salary
    order by salary desc
    limit 1,1 );
```

## 14. 查找薪水排名第二多的员工编号emp_no、薪水salary、last_name以及first_name，不能使用order by完成
- 嵌套子查询
```sql
select e.emp_no, s.salary, e.last_name, e.first_name
from employees as e inner join salaries as s
on e.emp_no = s.emp_no
where s.salary = (
    -- 次高工资
    select max(salary)
    from salaries
    where salary < (
        -- 最高工资
        select max(salary)
        from salaries
        where to_date = '9999-01-01'
    )
);
```

## 15. 查找所有员工的last_name和first_name以及对应的dept_name，也包括暂时没有分配部门的员工
- 不包括没分配部门的员工
```sql
select e.last_name, e.first_name, d.dept_name
from employees as e, departments as d, dept_emp as de
where d.dept_name = (
    select dept_name
    from departments as d2
    where d2.dept_no = de.dept_no )
    and e.emp_no = de.emp_no;
```

- 嵌套联结表
```sql
select e.last_name, e.first_name, d.dept_name
from employees as e left join dept_emp as de
-- 同一员工
on e.emp_no = de.emp_no left join departments as d
-- 同一部门
on de.dept_no = d.dept_no;
```

## 16. 查找所有员工自入职以来的薪水涨幅情况，给出员工编号emp_no以及其对应的薪水涨幅growth，并按照growth进行升序
-
```sql
select s2.emp_no, (s2.salary-s1.salary) as growth
-- 当前员工工资
from (select s.emp_no, s.salary
    from employees e, salaries s
    where e.emp_no = s.emp_no
        and s.to_date = '9999-01-01') as s2,
    -- 员工入职工资
    (select s.emp_no, s.salary
    from employees e, salaries s
    where e.emp_no = s.emp_no
        and s.from_date = e.hire_date) as s1
where s2.emp_no = s1.emp_no
order by growth;
```

## 17. 统计各个部门的工资记录数，给出部门编码dept_no、部门名称dept_name以及部门在salaries表里面有多少条记录sum，按照dept_no升序排序
- inner ... join ...
```sql
select d.*, count(s.salary) as sum
from dept_emp as de inner join salaries as s
-- 同一员工
on de.emp_no = s.emp_no inner join departments as d
-- 同一部门
on de.dept_no = d.dept_no
-- 按部门分组
group by d.dept_no
order by d.dept_no;
```

- where
```sql
select d.*, count(s.salary) as sum
from dept_emp as de, salaries as s, departments as d
-- 同一部门
where d.dept_no = de.dept_no
	-- 同一员工
    and de.emp_no = s.emp_no
group by d.dept_no
order by d.dept_no;
```

## 18. 对所有员工的薪水按照salary进行按照1-N的排名，相同salary并列且按照emp_no升序排列
- dense_rank(): 并列连续排名窗口函数
```sql
select emp_no,
    salary,
    -- 并列连续排名
    dense_rank() over (order by salary desc) as t_rank
from salaries
where to_date = '9999-01-01';
```

## 19. 获取所有非manager员工薪水情况，给出dept_no、emp_no以及salary
- 多表联结
```sql
select de.dept_no, s.emp_no, s.salary
from (employees as e inner join salaries as s
      on s.emp_no = e.emp_no
      and s.to_date = '9999-01-01')
      inner join dept_emp as de
          on e.emp_no = de.emp_no
where de.emp_no not in (
    select emp_no
    from dept_manager
    where to_date = '9999-01-01' )
order by de.dept_no;
```

- 嵌套子查询
```sql
select de.dept_no, de.emp_no, s.salary
from dept_emp as de, salaries as s
where de.emp_no in (
    -- 查找非经理的员工id
    select emp_no
    from dept_emp
    where emp_no not in (
        -- 查找部门经理的员工id
        select emp_no
        from dept_manager ) )
    -- 同一员工
    and de.emp_no = s.emp_no
    -- 在职员工
    and de.to_date = '9999-01-01'
order by de.dept_no;
```

## 20. 获取员工其当前的薪水比其manager当前薪水还高的相关信息,第一列给出员工的emp_no,第二列给出其manager的manager_no,第三列给出该员工当前的薪水emp_salary,第四列给该员工对应的manager当前的薪水manager_salary
- 分合思想: 复杂查询拆分为简单查询再组合
```sql
-- 查询员工编号和薪水
select de.emp_no, s.salary
from dept_emp as de, dept_manager as dm, salaries as s
where de.emp_no <> dm.emp_no
    and s.emp_no = de.emp_no
    and s.emp_no <> dm.emp_no
    and s.to_date = '9999-01-01'

-- 查询经理编号和薪水
select dm.emp, s.salary
from dept_manager as dm, salaries as s
where dm.emp_no = s.emp_no
    and s.to_date = '9999-01-01'

-- 组合查询
select de.emp_no,
    dm.emp_no as manager_no,
    s1.salary as emp_salary,
    s2.salary as manager_salary
from dept_emp as de,
    dept_manager as dm,
    salaries as s1,
    salaries as s2
-- 同一部门
where de.dept_no = dm.dept_no
	-- 员工编号一致
    and s1.emp_no = de.emp_no
    and s2.emp_no = dm.emp_no
	-- 员工工资超过经理
    and s1.salary > s2.salary
	-- 在职员工
    and s1.to_date = '9999-01-01'
    and s2.to_date = '9999-01-01'
order by de.emp_no;
```

-
```sql
select emp_sal.emp_no,
    mag_sal.manager_no,
    emp_sal.emp_salary,
    mag_sal.manager_salary
from (
    select de.emp_no, de.dept_no, s1.salary as emp_salary
    from dept_emp de,salaries s1
    where de.emp_no = s1.emp_no
    and s1.to_date = '9999-01-01'
    and de.to_date = '9999-01-01'
) as emp_sal
inner join (
    select dm.emp_no as manager_no, dm.dept_no, s2.salary as manager_salary
    from dept_manager dm,salaries s2
    where dm.emp_no = s2.emp_no
    and s2.to_date = '9999-01-01'
    and dm.to_date = '9999-01-01'
) as mag_sal
on emp_sal.dept_no = mag_sal.dept_no
where mag_sal.manager_salary < emp_sal.emp_salary
order by emp_no;
```

## 21. 汇总各个部门当前员工的title类型的分配数目，即结果给出部门编号dept_no、dept_name、其部门下所有的员工的title以及该类型title对应的数目count，结果按照dept_no升序排序
- 联结表
```sql
select d.*, t.title, count(t.title) as "count"
from titles as t inner join dept_emp as de
-- 同一员工
on t.emp_no = de.emp_no
    and de.to_date = '9999-01-01'
    and t.to_date = '9999-01-01'
inner join departments as d
-- 同一部门
on de.dept_no = d.dept_no
-- 按部门和职称分组
group by de.dept_no, t.title
order by de.dept_no;
```

- 重新建表查询
```sql
select d.dept_no,
    d.dept_name,
    emp_title.title,
    count(emp_title.title) as "count"
from departments d inner join (
    select d_p.emp_no, d_p.dept_no, t.title
    from dept_emp d_p inner join titles t
    on d_p.emp_no = t.emp_no
    where d_p.to_date = '9999-01-01'
        and t.to_date = '9999-01-01'
) as emp_title
on emp_title.dept_no = d.dept_no
group by d.dept_no, emp_title.title
order by d.dept_no;
```

## 22. 查找描述信息(film.description)中包含robot的电影对应的分类名称(category.name)以及电影数目(count(film.film_id))，而且还需要该分类包含电影总数量(count(film_category.category_id))>=5部
- 
```sql
-- 1. 找到对应电影数量>=5的所有分类，建立成虚表c2
-- 2. 设定限制条件 f.description like '%robot%'
-- 3. 在表c2、f、fc、c中查找包括robot的电影对应的分类名称和对应的电影数目
select c.name, count(f.film_id) as "count"
from film as f, category as c, film_category as fc,
	-- 查询电影数量>=5的所有分类的category_id
    (select category_id
    from film_category
    group by category_id
    having count(category_id) >= 5) as c2
-- 查询包含robot的电影
where f.description like '%robot%'
	-- 分类号相同
    and fc.category_id = c.category_id
	-- 电影id相同
    and f.film_id = fc.film_id
	-- 电影分类id>=5
    and c.category_id = c2.category_id;
```

## 23. 使用join查询方式找出没有分类的电影id以及名称
- left join
```sql
select f.film_id, f.title
from film as f left join film_category as fc
on f.film_id = fc.film_id
where fc.category_id is null;
```

## 24. 使用子查询的方式找出属于Action分类的所有电影对应的title,description
- 使用子查询
```sql
select title, description
from film
-- 注意这里用in(可以包含多个值), 不用=(只能包含一个值)
where film_id in (
    select film_id
    from film_category
    where category_id in (
        select category_id
        from category
        where name = 'Action'
    )
)
order by title;
```

- where and
```sql
select f.title, f.description
from film as f, film_category as fc, category as c
where f.film_id = fc.film_id
	and fc.category_id = c.category_id
	and c.name = 'Action'
order by f.title;
```

## 25. 将employees表的所有员工的last_name和first_name拼接起来作为Name，中间以一个空格区分
- concat()
```sql
select concat(last_name, ' ', first_name) as name
from employees;
```

## 26. 创建一个actor表，包含如下列信息
- create table if not exists
```sql
create table if not exists actor (
    actor_id smallint(5) not null auto_increment,
    first_name varchar(45) not null,
    last_name varchar(45) not null,
    last_update date not null,
    primary key (actor_id)
) engine = innodb;
```

## 27. 对于表actor批量插入如下数据(不能有2条insert语句)
- insert into
```sql
insert into actor (actor_id, first_name, last_name, last_update)
values (1, 'PENELOPE', 'GUINESS', '2006-02-15 12:34:33'),
    (2, 'NICK', 'WAHLBERG', '2006-02-15 12:34:33');
```

## 28. 对于表actor插入如下数据,如果数据已经存在，请忽略(不支持使用replace操作)
- insert ignore into ...
```sql
insert ignore into actor (actor_id, first_name, last_name, last_update)
values (3, 'ED', 'CHASE', '2006-02-15 12:34:33');
```

## 29. 创建一个actor_name表，并且将actor表中的所有first_name以及last_name导入该表
- create table table_name as ...
```sql
create table if not exists actor_name as
select first_name, last_name
from actor;
```

## 30. 针对如下表actor结构创建索引
- create [unique] index index_name on table_name (column [asc|desc])
```sql
-- 创建唯一索引
create unique index uniq_idx_firstname on actor (first_name);
-- 创建普通索引
create index idx_lastname on actor(last_name);
```

## 31. 针对actor表创建视图actor_name_view，只包含first_name以及last_name两列，并对这两列重新命名，first_name为first_name_v，last_name修改为last_name_v
- create view view_name as ...
```sql
create view actor_name_view as
select first_name as first_name_v, last_name as last_name_v
from actor;
```

## 32. 针对salaries表emp_no字段创建索引idx_emp_no，查询emp_no为10005, 使用强制索引
- force index(index_name) ...
```sql
select *
from salaries
force index(idx_emp_no)
where emp_no = 10005;
```

## 33. 在last_update后面新增加一列名字为create_date, 类型为datetime, NOT NULL，默认值为'2020-10-01 00:00:00'
- alter table table_name add...
```sql
alter table actor
add create_date datetime not null default '2020-10-01 00:00:00';
```

## 34. 构造一个触发器audit_log，在向employees_test表中插入一条数据的时候，触发插入相关的数据到audit中
- create trigger
```sql
delimiter //
create trigger audit_log after insert on employees_test
for each row
begin
    insert into audit values(new.id, new.name);
end //
delimiter ;
```

## 35. 删除emp_no重复的记录，只保留最小的id对应的记录
- 直接找到最小id
```sql
delete from titles_test
-- id值不为最小值
where id not in (
    select min_id
	-- 最小id作为中间表
    from (
        select min(id) as min_id
        from titles_test
        group by emp_no ) as t1
);
```

- 找出所有需要删除的记录的id
```sql
delete from titles_test
-- 根据id删除数据
where id in (
    select id
	from (
		-- 联合titles_test找出所有需要删除的id
		select a.id
		from titles_test as a,
			-- 找出所有出现的频次>1 emp_no 及最小id
			(select min(id) as id, emp_no
			from titles_test 
			group by emp_no
			having count(emp_no) > 1) as b
		where a.emp_no = b.emp_no
			and a.id > b.id ) as t
);
```

## 36. 将所有to_date为9999-01-01的全部更新为NULL,且 from_date更新为2001-01-01
- update
```sql
update titles_test
set to_date = null,
    from_date = '2001-01-01'
where to_date = '9999-01-01';
```

## 37. 将id=5以及emp_no=10001的行数据替换成id=5以及emp_no=10005,其他数据保持不变，使用replace实现，直接使用update会报错
- replace
```sql
update titles_test
set emp_no = replace(emp_no, 10001, 10005)
where id = 5;
```

## 38. 将titles_test表名修改为titles_2017
- rename table old_table_name to new_table_name
```sql
rename table titles_test to titles_2017;
```

## 39. 在audit表上创建外键约束，其emp_no对应employees_test表的主键id
- 添加外键
```sql
-- alter table <表名>
-- add constraint foreign key (<列名>)
-- references <关联表>（关联列）

alter table audit
add constraint foreign key (emp_no)
references employees_test (id);
```

## 40. 写出更新语句，将所有获取奖金的员工当前的(salaries.to_date='9999-01-01')薪水增加10%
- 使用子查询
```sql
update salaries
set salary = salary*1.1
where emp_no in (
    select emp_no
    from emp_bonus
    where to_date = '9999-01-01'
);
```

- 联结表
```sql
update salaries as s inner join emp_bonus as eb
-- 获奖员工编号一致
on s.emp_no = eb.emp_no
set salary = salary*1.1
-- 当前在职员工
where s.to_date = '9999-01-01';
```

## 41. 将employees表中的所有员工的last_name和first_name通过(')连接起来
- 
```sql
select concat(last_name, '\'', first_name)
from employees;
```

## 42. 查找字符串'10,A,B' 中逗号','出现的次数cnt
- 
```sql
select (length("10,A,B") - length(replace("10,A,B", ",", "")))  as cnt;
```

## 43. 获取Employees中的first_name，查询按照first_name最后两个字母，按照升序进行排列
- substr()
```sql
select first_name
from employees
order by substr(first_name, -2);
```

## 44. 按照dept_no进行汇总，属于同一个部门的emp_no按照逗号进行连接，结果给出dept_no以及连接出的结果employees
- group_conct()
```sql
select dept_no, group_concat(emp_no separator ',') as employees
from dept_emp
group by dept_no
```

## 45. 查找排除最大、最小salary之后的当前(to_date = '9999-01-01' )员工的平均工资avg_salary
- 
```sql
select avg(salary) as avg_salary
from salaries
-- 在职员工
where to_date = '9999-01-01'
	-- 去除最大值
    and salary not in (
        select max(salary)
        from salaries
		-- 在职员工
        where to_date = '9999-01-01' )
	-- -- 去除最小值
    and salary not in (
        select min(salary)
        from salaries
		-- 在职员工
        where to_date = '9999-01-01' );
```

## 46. 分页查询employees表，每5行一页，返回第2页的数据
- 
```sql
select *
from employees
limit 5,5;
```

## 47. 使用含有关键字exists查找未分配具体部门的员工的所有信息
- in
```sql
select *
from employees
where emp_no not in (
    select emp_no
    from dept_emp
)
order by emp_no;
```

- exists
```sql
select *
from employees
where not exists (
    select emp_no
    from dept_emp
    where employees.emp_no = dept_emp.emp_no
);
```

# 48. 获取有奖金的员工相关信息。给出emp_no、first_name、last_name、奖金类型btype、对应的当前薪水情况salary以及奖金金额bonus。 bonus类型btype为1其奖金为薪水salary的10%，btype为2其奖金为薪水的20%，其他类型均为薪水的30%。 当前薪水表示to_date='9999-01-01'
- 
```sql

```







