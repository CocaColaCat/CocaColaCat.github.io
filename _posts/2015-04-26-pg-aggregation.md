---
title: Rails App 性能优化实战篇 - 1 （初级）
---
### Rails App 性能优化实战篇 - 1 （初级）

#### TL,DR
 
 本文简述了 Rails App 开发中会用到的性能优化技巧。包括了:
 
- 通过编写 PostgreSQL aggregation sql 来提取时间有关的统计数据; （Covered）
- 使用 eager loading 来消除 n+1 问题；(TBC)
- 设置 index 来提升 query 效率。(TBC)

**以上都属于基础优化，不适合资深开发员。**

#### 按 日/周/月 提取统计数据
 
 **问题**：无论是应用开发人员还是运维人员，都会面对提取统计数据的需求。比如：
 
 - 最近 7 天/周/月，每 天/周/月 的报名人数 (某事件发生的次数) 是多少

碰到这样的问题，可能会很直观的采用如下解决方案：


```
// 提取最近 7 周的报名人数
def get_enrollment_count_by_weeks
weeks = 7
count = Array.new(weeks) { |i| i = 0  }
weeks.times do |i|
  count[i] = enrollments.where("created_at >= ? and created_at < ?",
                            Date.today.weeks_ago(i).beginning_of_week.to_datetime, 
                            Date.today.weeks_ago(i).end_of_week.to_datetime + 1).count
end
```

同时会使用类似的逻辑来处理其他时间范围的问题。不言而喻，以上的解决方案是很低效的。

解题的关键在于如何利用数据库本身的 Aggregation 能力来提取数据，而不是通过 app logic 来完成。

简化说，就是如何用一句 SQL statement 来达到相同的目的。

 **优化**: 通过 PostgreSQL 提供的 [generate_series](http://www.postgresql.org/docs/current/interactive/functions-srf.html), [date_trunc](http://www.postgresql.org/docs/9.4/static/functions-datetime.html) functions 可以达到优化目的。
 
 首先是一些背景知识解释。
 
 generate_series: 可以按照自定的规则生成新表格，如生成一个最近七天日期的单表, 
 
 间隔 2 steps 获取 1 到 10 整数单表。

```
// console
sql = <<-SQL
  SELECT generate_series(-6, 0) + current_date as day
SQL
puts (ActiveRecord::Base.connection.execute sql).to_a

// 输出
{"day"=>"2015-04-13"}
{"day"=>"2015-04-14"}
{"day"=>"2015-04-15"}
{"day"=>"2015-04-16"}
{"day"=>"2015-04-17"}
{"day"=>"2015-04-18"}
{"day"=>"2015-04-19"}

// console
sql = <<-SQL
  SELECT generate_series(1, 10, 2) as int
SQL
puts (ActiveRecord::Base.connection.execute sql).to_a

// 输出
{"int"=>"1"}
{"int"=>"3"}
{"int"=>"5"}
{"int"=>"7"}
{"int"=>"9"}
```

 date_trunc: 给定一个时间，提取部分信息组成新的时间返回。如找到这周的开始日期
 
 ```
// console
sql = <<-SQL
  SELECT date_trunc('week', now()) AS week_start_at;
SQL
puts (ActiveRecord::Base.connection.execute sql).to_a

// 输出
{"week_start_at"=>"2015-04-13 00:00:00+08"}
```

为什么要使用这些 functions? 回到我们的问题，提取最近 7 周每周的报名人数。把问题拆分为这样：

- 拿到最近七周的开始时间的日期

```
sql = <<-SQL
SELECT (date_trunc('week', now()))::date - s.a AS start_date FROM 
  generate_series(0,42,7) AS s(a) 
SQL

puts (ActiveRecord::Base.connection.execute sql).to_a

// 输出
{"start_date"=>"2015-04-13"}
{"start_date"=>"2015-04-06"}
{"start_date"=>"2015-03-30"}
{"start_date"=>"2015-03-23"}
{"start_date"=>"2015-03-16"}
{"start_date"=>"2015-03-09"}
{"start_date"=>"2015-03-02"}

```

- 按照每周把所有的报名分组
- 算每组的总数
 
```
sql = <<-SQL
  SELECT series.start_date, count(id) as approval_count
  FROM
    (SELECT (date_trunc('week', now()))::date - s.a AS start_date 
    FROM generate_series(0,42,7) AS s(a)) series
  LEFT OUTER JOIN enrollments on 
      enrollments.created_at::date <= (series.start_date + 6)
      AND
      enrollments.created_at::date >= series.start_date
  GROUP BY series.start_date ORDER BY series.start_date desc;
SQL

// 输出
[{"start_date"=>"2015-04-13", "approval_count"=>"2"},
 {"start_date"=>"2015-04-06", "approval_count"=>"0"},
 {"start_date"=>"2015-03-30", "approval_count"=>"0"},
 {"start_date"=>"2015-03-23", "approval_count"=>"0"},
 {"start_date"=>"2015-03-16", "approval_count"=>"1"},
 {"start_date"=>"2015-03-09", "approval_count"=>"0"},
 {"start_date"=>"2015-03-02", "approval_count"=>"0"}]
```

一旦生成了需要的日期单表，再使用 JOIN，就能轻易达到提取的目的。

**FIRST PART END**
 