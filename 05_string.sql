/*
Output the names of all members, formatted as 'Surname, Firstname'
*/

SELECT surname || ', ' || firstname AS name
FROM cd.members;



/*
Find all facilities whose name begins with 'Tennis'. Retrieve all columns.
*/

SELECT *
FROM cd.facilities
WHERE name LIKE 'Tennis%';



/*
Perform a case-insensitive search to find all facilities whose name begins with 'tennis'. Retrieve all columns.
*/

SELECT * 
FROM cd.facilities
WHERE name ILIKE 'tennis%';

SELECT *
FROM cd.facilities
WHERE UPPER(name) LIKE 'TENNIS%';



/*
You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
*/

SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '(%)%'
ORDER BY memid;

/* WITH REGEX: match any symbol inside square brackets */
SELECT memid, telephone
FROM cd.members
WHERE telephone ~ '[()]';



/*
The zip codes in our example dataset have had leading zeroes removed from them by virtue of being stored as a numeric type. Retrieve all zip codes from the members table, padding any zip codes less than 5 characters long with leading zeroes. Order by the new zip code.
*/

SELECT LPAD(zipcode::text, 5, '0') AS zip
FROM cd.members
ORDER BY zip;



/*
You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.
*/

SELECT SUBSTR(surname, 1, 1) AS letter, COUNT(*) AS count
FROM cd.members
GROUP BY letter
ORDER BY letter;



/*
The telephone numbers in the database are very inconsistently formatted. You'd like to print a list of member ids and numbers that have had '-','(',')', and ' ' characters removed. Order by member id.
*/

SELECT memid, TRANSLATE(telephone, '()- ', '') AS telephone
FROM cd.members
ORDER BY memid;






