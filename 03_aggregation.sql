/*
For our first foray into aggregates, we're going to stick to something simple. We want to know how many facilities exist - simply produce a total count.
*/

SELECT COUNT(*)
FROM cd.facilities;



/*
Produce a count of the number of facilities that have a cost to guests of 10 or more.
*/

SELECT COUNT(*)
FROM cd.facilities
WHERE guestcost >= 10;



/*
Produce a count of the number of recommendations each member has made. Order by member ID.
*/

SELECT recommendedby, COUNT(recommendedby)
FROM cd.members
GROUP BY recommendedby
HAVING COUNT(recommendedby) > 0
ORDER BY recommendedby;



/*
Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
*/

SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;



/*
Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
*/

SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE starttime > '2012-09-01' AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY "Total Slots";



/*
Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
*/

SELECT facid, EXTRACT(month FROM starttime) AS Month, SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(year FROM starttime) = 2012
GROUP BY facid, Month
ORDER BY facid, Month;



/*
Find the total number of members who have made at least one booking.
*/

SELECT COUNT(DISTINCT memid)
FROM cd.bookings;



/*
Produce a list of facilities with more than 1000 slots booked. Produce an output table consisting of facility id and hours, sorted by facility id.
*/

SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) > 1000
ORDER BY facid;



/*
Produce a list of facilities along with their total revenue. The output table should consist of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
*/

SELECT fac.name, SUM(book.slots * 
	CASE
		WHEN book.memid = 0 THEN fac.guestcost
		ELSE fac.membercost
	END) AS revenue
FROM cd.bookings AS book
JOIN cd.facilities AS fac
	ON book.facid = fac.facid
GROUP BY fac.name
ORDER BY revenue;



/*
Produce a list of facilities with a total revenue less than 1000. Produce an output table consisting of facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
*/

SELECT name, revenue
FROM
	(SELECT fac.name AS name, SUM(book.slots * 
		CASE
			WHEN book.memid = 0 THEN fac.guestcost
			ELSE fac.membercost
		END) AS revenue
	FROM cd.bookings AS book
	JOIN cd.facilities AS fac
		ON book.facid = fac.facid
	GROUP BY fac.name) AS sub
WHERE revenue < 1000
ORDER BY revenue;



/*
Output the facility id that has the highest number of slots booked. For bonus points, try a version without a LIMIT clause. This version will probably look messy!
*/

SELECT facid, SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY "Total Slots" DESC
LIMIT 1;



/*
Produce a list of the total number of slots booked per facility per month in the year of 2012. In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities. The output table should consist of facility id, month and slots, sorted by the id and month. When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
*/

SELECT facid, EXTRACT(month FROM starttime) AS month, SUM(slots) AS sum
	FROM cd.bookings
	WHERE EXTRACT(year FROM starttime) = 2012
	GROUP BY facid, month
UNION ALL
SELECT facid, NULL, SUM(slots) AS sum
	FROM cd.bookings
	WHERE EXTRACT(year FROM starttime) = 2012
	GROUP BY facid
UNION ALL
SELECT NULL, NULL, SUM(slots) AS sum
	FROM cd.bookings
	WHERE EXTRACT(year FROM starttime) = 2012
ORDER BY facid, month;



/*
Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour. The output table should consist of the facility id, name, and hours booked, sorted by facility id. Try formatting the hours to two decimal places.
*/

SELECT book.facid, fac.name, TRIM(TO_CHAR((SUM(book.slots) * 0.5), '999.99')) AS "Total Hours"
FROM cd.bookings AS book
JOIN cd.facilities AS fac
	ON book.facid = fac.facid
GROUP BY book.facid, fac.name
ORDER BY book.facid;



/*
Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
*/

SELECT mem.surname, mem.firstname, mem.memid, MIN(book.starttime) AS starttime
FROM cd.members AS mem
JOIN cd.bookings AS book
	ON mem.memid = book.memid
WHERE book.starttime > '2012-09-01'
GROUP BY mem.memid
ORDER BY memid;



/*
Produce a list of member names, with each row containing the total member count. Order by join date.
*/

SELECT COUNT(*) OVER(), firstname, surname
FROM cd.members
ORDER BY joindate;


/*
Produce a monotonically increasing numbered list of members, ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
*/

SELECT ROW_NUMBER() OVER(ORDER BY joindate), firstname, surname
FROM cd.members;



/*
Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
*/

SELECT facid, total
FROM (
	SELECT facid, SUM(slots) AS total, RANK() OVER(ORDER BY SUM(slots) DESC)
	FROM cd.bookings
	GROUP BY facid
	) AS sub
WHERE rank = 1;



/*
Produce a list of members, along with the number of hours they've booked in facilities, rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank. Sort by rank, surname, and first name.
*/

SELECT firstname, surname, hours, RANK() OVER(ORDER BY hours DESC)
FROM (
	SELECT mem.firstname, mem.surname, 
		ROUND(((SUM(slots) / 2) + 5) / 10) * 10 AS hours
	FROM cd.members AS mem
	JOIN cd.bookings AS book
		ON mem.memid = book.memid
	GROUP BY mem.firstname, mem.surname
	) AS sub
ORDER BY rank, surname, firstname;



/*
Produce a list of the top three revenue generating facilities (including ties). Output facility name and rank, sorted by rank and facility name.
*/

SELECT name, rank
FROM (
	SELECT name, RANK() OVER(ORDER BY revenue DESC)
	FROM (
		SELECT fac.name AS name, SUM(book.slots * 
			CASE
				WHEN book.memid = 0 THEN fac.guestcost
				ELSE fac.membercost
			END
		) AS revenue
		FROM cd.facilities AS fac
		JOIN cd.bookings AS book
			ON fac.facid = book.facid
		GROUP BY fac.name
		) AS sub1
	) AS sub2
WHERE rank < 4;



/*
Classify facilities into equally sized groups of high, average, and low based on their revenue. Order by classification and facility name.
*/

SELECT name, 
	CASE
		WHEN ntile = 1 THEN 'high'
		WHEN ntile = 2 THEN 'average'
		ELSE 'low'
	END AS revenue
FROM (	
	SELECT name, NTILE(3) OVER(ORDER BY total_revenue DESC) AS ntile
	FROM (
		SELECT fac.name AS name, SUM(book.slots * 
			CASE
				WHEN book.memid = 0 THEN fac.guestcost
				ELSE fac.membercost
			END) AS total_revenue
		FROM cd.facilities AS fac
		JOIN cd.bookings AS book
			ON fac.facid = book.facid
		GROUP BY fac.name
		) AS sub1
	) AS sub2
ORDER BY ntile, name;



/*
Based on the 3 complete months of data so far, calculate the amount of time each facility will take to repay its cost of ownership. Remember to take into account ongoing monthly maintenance. Output facility name and payback time in months, order by facility name. Don't worry about differences in month lengths, we're only looking for a rough value here!
*/

SELECT sub.name, fac.initialoutlay / ((sub.total_revenue / 3) - fac.monthlymaintenance) AS months
FROM (
	SELECT fac.facid AS facid, fac.name AS name, SUM(book.slots *
		CASE
			WHEN book.memid = 0 THEN fac.guestcost
			ELSE fac.membercost
		END) AS total_revenue
	FROM cd.facilities AS fac
	JOIN cd.bookings AS book
		ON fac.facid = book.facid
	GROUP BY fac.facid
	) AS sub
JOIN cd.facilities AS fac
	ON sub.facid = fac.facid
ORDER BY name;



/*
For each day in August 2012, calculate a rolling average of total revenue over the previous 15 days. Output should contain date and revenue columns, sorted by the date. Remember to account for the possibility of a day having zero revenue. This one's a bit tough, so don't be afraid to check out the hint!
*/

SELECT date, revenue
FROM (
	SELECT date, AVG(daily_rev) OVER(ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) AS revenue
	FROM (
		SELECT to_char(series, 'YYYY-MM-DD') AS date, rev_data.daily_rev AS daily_rev
		FROM generate_series('2012-07-14'::timestamp, '2012-08-31', '1 day') AS series
		JOIN (
			SELECT to_char(book.starttime, 'YYYY-MM-DD') AS date, SUM(book.slots * 
				CASE
					WHEN book.memid = 0 THEN fac.guestcost
					ELSE fac.membercost
				END) AS daily_rev
			FROM cd.bookings AS book
			JOIN cd.facilities AS fac
				ON book.facid = fac.facid
			GROUP BY date
			ORDER BY date
			) AS rev_data
			ON rev_data.date::text = series.date::text
		) AS sub1
	) AS sub2
WHERE date >= '2012-08-01';














/*************************************
			NOTES TO SELF
*************************************/


/*
Total revenue per month by facility
*/

SELECT fac.name, EXTRACT(month FROM book.starttime) AS month, SUM(book.slots * 
	CASE
		WHEN book.memid = 0 THEN fac.guestcost
		ELSE fac.membercost
	END) AS revenue
FROM cd.facilities AS fac
JOIN cd.bookings AS book
	ON fac.facid = book.facid
GROUP BY fac.name, month
ORDER BY fac.name, month;



/*
Get a table with facility name, total revenue, initial outlay, and monthly maintenance.
*/

SELECT sub.name, sub.total_revenue, fac.initialoutlay, fac.monthlymaintenance
FROM (
	SELECT fac.facid AS facid, fac.name AS name, SUM(book.slots *
		CASE
			WHEN book.memid = 0 THEN fac.guestcost
			ELSE fac.membercost
		END) AS total_revenue
	FROM cd.facilities AS fac
	JOIN cd.bookings AS book
		ON fac.facid = book.facid
	GROUP BY fac.facid
	) AS sub
JOIN cd.facilities AS fac
	ON sub.facid = fac.facid

