/* QUESTIONS 

-------------------------------------------------------------------------------------------------------------------------------
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT name
FROM Facilities
WHERE membercost != 0;


-------------------------------------------------------------------------------------------------------------------------------
/* Q2: How many facilities do not charge a fee to members? */
-------------------------------------------------------------------------------------------------------------------------------


SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0;


-------------------------------------------------------------------------------------------------------------------------------
/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost !=0
AND membercost < (monthlymaintenance * 0.20);


-------------------------------------------------------------------------------------------------------------------------------
/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT * 
FROM Facilities 
WHERE facid BETWEEN 1 AND 5;


-------------------------------------------------------------------------------------------------------------------------------
/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
     ELSE 'cheap' 
END AS label
FROM Facilities;


-------------------------------------------------------------------------------------------------------------------------------
/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT surname, firstname
FROM Members
ORDER BY joindate DESC 


-------------------------------------------------------------------------------------------------------------------------------
/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT DISTINCT f.name AS court_number, concat( m.firstname,' ', m.surname ) AS member_name
FROM Bookings AS b
JOIN Facilities AS f ON f.facid = b.facid
JOIN Members AS m ON m.memid = b.memid
WHERE f.name LIKE 'Tennis%'
ORDER BY member_name, court_number


-------------------------------------------------------------------------------------------------------------------------------
/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT concat( m.firstname, ' ', m.surname ) AS guest_name, f.name AS facility,
(CASE WHEN m.memid = 0 THEN b.slots * f.guestcost
      ELSE b.slots * f.membercost
      END) AS total_costs
FROM Bookings AS b
JOIN Facilities AS f ON f.facid = b.facid
JOIN Members AS m ON m.memid = b.memid
WHERE b.starttime LIKE '2012-09-14%'
AND
(CASE WHEN m.memid = 0 THEN b.slots * f.guestcost
      ELSE b.slots * f.membercost
      END) >30
ORDER BY total_costs DESC; 


-------------------------------------------------------------------------------------------------------------------------------
/* Q9: This time, produce the same result as in Q8, but using a subquery. */
-------------------------------------------------------------------------------------------------------------------------------


SELECT guest_name, facility, total_costs
FROM (
    SELECT concat( m.firstname, ' ', m.surname ) AS guest_name, f.name AS facility,
    (CASE WHEN m.memid = 0 THEN b.slots * f.guestcost
          ELSE b.slots * f.membercost
          END) AS total_costs
    FROM Bookings AS b
    JOIN Facilities AS f ON f.facid = b.facid
    JOIN Members AS m ON m.memid = b.memid
    WHERE b.starttime LIKE '2012-09-14%'
) AS subq
WHERE total_costs >= 30
ORDER BY total_costs DESC; 
 

-------------------------------------------------------------------------------------------------------------------------------
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
-------------------------------------------------------------------------------------------------------------------------------


SELECT facility, revenue
FROM (
    SELECT facility, SUM(total_cost) AS revenue
    FROM (
        SELECT F.name AS facility, 
            (CASE WHEN B.memid = 0 THEN B.slots*guestcost
             ELSE B.slots*membercost
             END) AS total_cost
        FROM Bookings AS B
        INNER JOIN Facilities AS F
        ON B.facid = F.facid ) AS subq_1
    GROUP BY facility ) AS subq_2
WHERE revenue < 1000
ORDER BY revenue DESC;


-------------------------------------------------------------------------------------------------------------------------------
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
-------------------------------------------------------------------------------------------------------------------------------


SELECT m1.surname ||', '|| m1.firstname AS member,
       m2.surname ||', '|| m2.firstname AS recommended_by
FROM Members AS m1
INNER JOIN Members AS m2
ON m1.recommendedby = m2.memid
ORDER BY member


-------------------------------------------------------------------------------------------------------------------------------
/* Q12: Find the facilities with their usage by member, but not guests */
-------------------------------------------------------------------------------------------------------------------------------


SELECT F.name AS facility, COUNT(*) AS member_usage
FROM Facilities as F
JOIN Bookings as B
ON F.facid = B.facid
WHERE B.memid != 0
GROUP BY F.name


-------------------------------------------------------------------------------------------------------------------------------
/* Q13: Find the facilities usage by month, but not guests */
-------------------------------------------------------------------------------------------------------------------------------


SELECT facility, 
       SUM(JULY) AS July,
       SUM(AUGUST) AS Aug, 
       SUM(SEPTEMBER) AS Sept
FROM (
    SELECT facility,
    CASE WHEN month = '07' THEN usages 
         ELSE 0 END AS 'JULY',
    CASE WHEN month = '08' THEN usages 
         ELSE 0 END AS 'AUGUST',
    CASE WHEN month = '09' THEN usages 
         ELSE 0 END AS 'SEPTEMBER'
    FROM (
        SELECT F.name AS facility,
                strftime('%m',starttime) AS month,
                COUNT(strftime('%m',starttime)) AS usages
        FROM Facilities AS F
        JOIN Bookings AS B
        ON F.facid = B.facid
        WHERE B.memid != 0 
        GROUP BY month, F.name
        ) as subq_1
    ) as subq_2
GROUP BY facility
