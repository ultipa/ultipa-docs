# CASE

Function CASE calculates a new value from one or multiple values based on conditions. Once the condition of a WHEN is met, the value in the correspondent THEN is generated, and the rest of WHEN and ELSE will be skipped.


<p tit="Syntax1"></p> 

```uql
case
  when <condition> then <output>
  when <condition> then <output>
  ...
  else <otherOutput>
end
```


<p tit="Syntax2"></p> 

```uql
case <expression>
  when <value> then <output>
  when <value> then <output>
  ...
  else <otherOutput>
end
```

- \<output> is the value to generate when \<condition> is met (Syntax 1), or when \<expression> equals \<value> (Syntax 2)
- \<otherOutput> is the value to generate when none of the conditions is met; a default value will be generated when ELSE is absent, which has same data format with \<output>

> Keywords CASE, WHEN, THEN, ELSE, END are all case insensitive.

> The condition statements (`WHEN`) are executed from top to bottom in sequence. When a condition is met, the corresponding output (`THEN`) is executed, and the remaining conditional statements are not executed.

## Common Usage

Example: Calculate the day of week of the planned payday (15th) of each month in 2023
 

```uql
uncollect ["2023-1-15","2023-2-15","2023-3-15","2023-4-15","2023-5-15","2023-6-15","2023-7-15","2023-8-15","2023-9-15","2023-10-15","2023-11-15","2023-12-15"] as payday
return CASE dayOfWeek(payday)
when 1 then "Sunday"
when 2 then "Monday"
when 3 then "Tuesday"
when 4 then "Wednesday"
when 5 then "Thursday"
when 6 then "Friday"
when 7 then "Saturday"
END
```
<p tit="Result"></p>

```
Sunday
Wednesday
Wednesday
Saturday
Monday
Thursday
Saturday
Tuesday
Friday
Sunday
Wednesday
Friday
```

Example: Calculate the actual payday of each month in 2023, knowing that a planned payday in the weekend should be postponded to the following Monday 
 

```uql
uncollect ["2023-1-15","2023-2-15","2023-3-15","2023-4-15","2023-5-15","2023-6-15","2023-7-15","2023-8-15","2023-9-15","2023-10-15","2023-11-15","2023-12-15"] as payday
return CASE dayOfWeek(payday)
when 1 then dateAdd(payday, 1, "day")
when 7 then dateAdd(payday, 2, "day")
else dateAdd(payday, 0, "day")
END
```
Analysis: Function dateAdd() in WHEN shifts the planned <i>payday</i> from weekend to the following Monday; ELSE indicates the <i>payday</i>s that are during working days, but still need the <i>payday</i> to be 0-shifted by dateAdd(), the reason is to keep the output data format of ELSE in consistent with WHEN.
<p tit="Result"></p>

```
2023-01-16 00:00:00
2023-02-15 00:00:00
2023-03-15 00:00:00
2023-04-17 00:00:00
2023-05-15 00:00:00
2023-06-15 00:00:00
2023-07-17 00:00:00
2023-08-15 00:00:00
2023-09-15 00:00:00
2023-10-16 00:00:00
2023-11-15 00:00:00
2023-12-15 00:00:00
```


