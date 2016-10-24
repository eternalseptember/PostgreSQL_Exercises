/*
Find the upward recommendation chain for member ID 27: that is, the member who recommended them, and the member who recommended that member, and so on. Return member ID, first name, and surname. Order by descending member id.
*/

WITH RECURSIVE rec AS (
	SELECT recommendedby
	FROM cd.members
	WHERE memid = 27
	UNION
	SELECT mem.recommendedby
	FROM cd.members AS mem
	JOIN rec AS r
		ON r.recommendedby = mem.memid
)

SELECT rec.recommendedby AS recommender, mem.firstname, mem.surname
FROM rec
JOIN cd.members AS mem
	ON rec.recommendedby = mem.memid
ORDER BY recommender DESC



/*
Find the downward recommendation chain for member ID 1: that is, the members they recommended, the members those members recommended, and so on. Return member ID and name, and order by ascending member id.
*/

WITH RECURSIVE rec_chain AS (
	SELECT memid
	FROM cd.members
	WHERE recommendedby = 1
	UNION
	SELECT mem.memid
	FROM cd.members AS mem
	JOIN rec_chain AS r
		ON r.memid = mem.recommendedby
)

SELECT rec.memid, mem.firstname, mem.surname
FROM rec_chain AS rec
JOIN cd.members AS mem
	ON rec.memid = mem.memid
ORDER BY memid ASC



/*
Produce a CTE that can return the upward recommendation chain for any member. You should be able to select recommender from recommenders where member=x. Demonstrate it by getting the chains for members 12 and 22. Results table should have member and recommender, ordered by member ascending, recommender descending.
*/

WITH RECURSIVE rec_table(member, recommender) AS (
	SELECT memid, recommendedby
	FROM cd.members
	UNION
	SELECT r.member, mem.recommendedby
	FROM cd.members AS mem
	JOIN rec_table AS r
		ON r.recommender = mem.memid
)

SELECT rec.member, rec.recommender, mem.firstname, mem.surname
FROM rec_table AS rec
JOIN cd.members AS mem
	ON rec.recommender = mem.memid
WHERE rec.member IN (12, 22)
ORDER BY rec.member ASC, rec.recommender DESC



