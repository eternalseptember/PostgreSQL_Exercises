/*
Find the upward recommendation chain for member ID 27: that is, the member who recommended them, and the member who recommended that member, and so on. Return member ID, first name, and surname. Order by descending member id.
*/

WITH RECURSIVE rec AS (
	SELECT recby0.memid AS memid, recby0.firstname, recby0.surname, recby0.recommendedby
	FROM cd.members AS mem
	JOIN cd.members AS recby0
		ON mem.recommendedby = recby0.memid
	WHERE mem.memid = 27

	UNION
	
	SELECT recby1.memid, recby1.firstname, recby1.surname, recby1.recommendedby
	FROM cd.members AS recby1
	JOIN rec AS r
		ON r.recommendedby = recby1.memid
)
SELECT memid, firstname, surname
FROM rec;




