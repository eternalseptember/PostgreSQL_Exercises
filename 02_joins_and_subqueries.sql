/*
How can you produce a list of the start times for bookings by members named 'David Farrell'?
*/

SELECT starttime
FROM cd.bookings
	JOIN cd.members
		ON cd.bookings.memid = cd.members.memid
WHERE firstname = 'David' AND surname = 'Farrell';



/*
How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
*/

SELECT starttime AS start, name
FROM cd.bookings AS bookings
	JOIN cd.facilities
		ON bookings.facid = cd.facilities.facid
WHERE starttime > '2012-09-21' AND starttime < '2012-09-22' AND name LIKE 'Tennis%'
ORDER BY starttime;



/*
How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
*/

SELECT DISTINCT mem.firstname, mem.surname
FROM cd.members AS mem
	JOIN cd.members AS rec
		ON rec.recommendedby = mem.memid
ORDER BY surname;



/*
How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
*/

SELECT mem.firstname AS memfname, mem.surname AS memsname, rec.firstname AS recfname, rec.surname AS recsname
FROM cd.members AS mem
	LEFT JOIN cd.members AS rec
		ON mem.recommendedby = rec.memid
ORDER BY memsname, memfname;



/*
How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name.
*/

SELECT DISTINCT mem.firstname || ' ' || mem.surname AS member, fac.name AS facility
FROM cd.members AS mem
	JOIN cd.bookings AS book 
		ON mem.memid = book.memid
	JOIN cd.facilities AS fac
		ON book.facid = fac.facid
WHERE fac.facid IN (0,1)
ORDER BY member;



/*
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.
*/

SELECT mem.firstname || ' ' || mem.surname AS member, fac.name AS facility,
	CASE
		WHEN mem.memid = 0 THEN (book.slots * fac.guestcost)
		ELSE (book.slots * fac.membercost)
	END AS cost
FROM cd.bookings AS book
	JOIN cd.members AS mem 
		ON book.memid = mem.memid
	JOIN cd.facilities AS fac
		ON book.facid = fac.facid
WHERE starttime > '2012-09-14' AND starttime < '2012-09-15' 
AND (
	(mem.memid = 0 AND (book.slots * fac.guestcost > 30)) OR 
	(mem.memid > 0 AND (book.slots * fac.membercost > 30))
	)
ORDER BY cost DESC;



/*
How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
*/

SELECT DISTINCT mem.firstname || ' ' || mem.surname AS member, 
	(SELECT rec.firstname || ' ' || rec.surname AS recommender
	 FROM cd.members as rec
	 WHERE mem.recommendedby = rec.memid)
FROM cd.members AS mem
ORDER BY member;



/*
The Produce a list of costly bookings exercise contained some messy logic: we had to calculate the booking cost in both the WHERE clause and the CASE statement. Try to simplify this calculation using subqueries. For reference, the question was:
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost.
*/

SELECT member, facility, cost
FROM 
	(SELECT mem.firstname || ' ' || mem.surname AS member, fac.name AS facility, 
		CASE
			WHEN mem.memid = 0 THEN (book.slots * fac.guestcost)
			ELSE (book.slots * fac.membercost)
		END AS cost
	FROM cd.bookings AS book
		JOIN cd.members AS mem
			ON book.memid = mem.memid
		JOIN cd.facilities AS fac
			ON book.facid = fac.facid
	WHERE book.starttime > '2012-09-14' AND book.starttime < '2012-09-15') AS sub
WHERE cost > 30
ORDER BY cost DESC;







