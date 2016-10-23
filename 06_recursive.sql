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



