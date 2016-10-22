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



/*
Work out the number of seconds between the timestamps '2012-08-31 01:00:00' and '2012-09-02 00:00:00'
*/

SELECT EXTRACT(EPOCH FROM ('2012-09-02 00:00:00'::timestamp - '2012-08-31 01:00:00'::timestamp));



/*
For each month of the year in 2012, output the number of days in that month. Format the output as an integer column containing the month of the year, and a second column containing an interval data type.
*/

SELECT EXTRACT(month FROM year_info) AS month, 
	(DATE_TRUNC('month', year_info) + '1 month'::interval - DATE_TRUNC('month', year_info)) AS length
FROM GENERATE_SERIES('2012-01-01'::timestamp, '2012-12-31', '1 month') AS year_info
ORDER BY month;



/*
For any given timestamp, work out the number of days remaining in the month. The current day should count as a whole day, regardless of the time. Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer. Format the output as a single interval value.
*/

SELECT (DATE_TRUNC('month', t) + '1 month'::interval - DATE_TRUNC('day', t)) AS remaining
FROM (
	SELECT '2012-02-11 01:00:00'::timestamp AS t
	) AS ts;



/*
Return a list of the start and end time of the last 10 bookings (by the time at which they end) in the system.
*/

SELECT starttime, (starttime + (slots * '30 minutes'::interval)) AS endtime
FROM cd.bookings
ORDER BY endtime DESC
LIMIT 10;



/*
Return a count of bookings for each month, sorted by month
*/

SELECT DATE_TRUNC('month', starttime) AS month, COUNT(*)
FROM cd.bookings
GROUP BY month
ORDER BY month;



/*
Work out the utilisation percentage for each facility by month, sorted by month, rounded to 1 decimal place. Opening time is 8am, closing time is 8.30pm. You can treat every month as a full month, regardless of if there were some dates the club was not open.
*/

SELECT name, month, ROUND((slotsBooked * 100 / (daysOpen * 25))::numeric, 1) AS util
FROM (
	SELECT fac.name AS name,
		DATE_TRUNC('month', book.starttime) AS month,
		EXTRACT(day FROM 
			(DATE_TRUNC('month', book.starttime) + '1 month'::interval - DATE_TRUNC('month', book.starttime))) AS daysOpen,
		SUM(book.slots) AS slotsBooked
	FROM cd.bookings AS book
	JOIN cd.facilities AS fac
		ON fac.facid = book.facid
	GROUP BY name, month
	ORDER BY name, month
	) AS sub




