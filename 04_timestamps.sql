/*
Produce a timestamp for 1 a.m. on the 31st of August 2012.
*/

SELECT MAKE_TIMESTAMP(2012, 8, 31, 1, 0, 0);



/*
Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
*/

SELECT (TIMESTAMP '2012-08-31 01:00:00' - TIMESTAMP '2012-07-30 01:00:00') AS interval;



/*
Produce a list of all the dates in October 2012. They can be output as a timestamp (with time set to midnight) or a date.
*/

SELECT GENERATE_SERIES('2012-10-01 00:00'::timestamp, '2012-10-31 00:00', '1 day') AS ts;



/*
 Get the day of the month from the timestamp '2012-08-31' as an integer.
*/

SELECT EXTRACT(day FROM '2012-08-31'::timestamp) AS date_part;





