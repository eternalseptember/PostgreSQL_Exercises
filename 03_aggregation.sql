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
ORDER BY revenue



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
ORDER BY revenue



/*
Output the facility id that has the highest number of slots booked. For bonus points, try a version without a LIMIT clause. This version will probably look messy!
*/













