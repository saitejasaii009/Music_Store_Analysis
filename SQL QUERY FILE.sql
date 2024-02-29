USE music_store;
SHOW TABLES;
-- Question Set 1 - Easy
-- 1. Who is the senior most employee based on job title?
SELECT 
	* 
FROM employee
ORDER BY levels DESC 
LIMIT 1;
# Output
-- employee_id, last_name, first_name, title, reports_to, levels, birthdate, hire_date, address, city, state, country, postal_code, phone, fax, email
-- 1	Adams	Andrew	General Manager	9	L6	18-02-1962 00:00	14-08-2016 00:00	11120 Jasper Ave NW	Edmonton	AB	Canada	T5K 2N1	+1 (780) 428-9482	+1 (780) 428-3457	andrew@chinookcorp.com

-- 2. Which countries have the most Invoices?
SELECT 
	billing_country,
    COUNT(*) AS Total_Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Total_Invoices DESC;
# Output
-- billing_country, Total_Invoices
-- USA	131
-- Canada	76
-- Brazil	61
-- France	50
-- Germany	41
-- Czech Republic	30
-- Portugal	29
-- United Kingdom	28
-- India	21
-- Ireland	13

-- 3. What are top 3 values of total invoice?
SELECT 
	* 
FROM invoice
ORDER BY total DESC
LIMIT 3;
-- Output
-- invoice_id, customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total
-- 183	42	2018-02-09 00:00:00	9, Place Louis Barthou	Bordeaux	None	France	33000	23.759999999999998
-- 92	32	2017-07-02 00:00:00	696 Osborne Street	Winnipeg	MB	Canada	R3L 2B9	19.8
-- 526	5	2020-06-08 00:00:00	Klanova 9/506	Prague	None	Czech Republic	14700	19.8

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT
	billing_city,
    SUM(total) AS Invoice_Total
FROM invoice
GROUP BY billing_city
ORDER BY Invoice_Total DESC
LIMIT 1;
-- # Output
-- billing_city, Invoice_Total
-- Prague	273.24000000000007

-- 5. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money 
SELECT 
	c.customer_id,
    concat(first_name," ",c.last_name) AS Full_name,
    SUM(i.total) AS Total_spent
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id,Full_name
ORDER BY Total_spent DESC
LIMIT 1;
# Output
-- customer_id, Full_name, Total_spent
-- 5	FrantiÅ¡ek WichterlovÃ¡	144.54000000000002

-- Question Set 2 – Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT
	c.email,
    CONCAT(c.first_name," ",c.last_name) AS Full_name
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
JOIN invoice_line il 
ON i.invoice_id = il.invoice_id
WHERE track_id IN(
				SELECT 
					track_id 
				FROM track t	
                JOIN genre g
                ON t.track_id = g.genre_id
                WHERE g.name LIKE 'Rock')
ORDER BY c.email;
# Output
-- email, Full_name
-- aaronmitchell@yahoo.ca	Aaron Mitchell
-- johavanderberg@yahoo.nl	Johannes Van der Berg
-- kachase@hotmail.com	Kathy Chase
-- phil.hughes@gmail.com	Phil Hughes
-- stanisÅ‚aw.wÃ³jcik@wp.pl	StanisÅ‚aw WÃ³jcik
-- steve.murray@yahoo.uk	Steve Murray
-- terhi.hamalainen@apple.fi	Terhi HÃ¤mÃ¤lÃ¤inen
-- wyatt.girard@yahoo.fr	Wyatt Girard 

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands
SELECT 
	a.name,
    COUNT(a.artist_id) AS Total_Tracks
FROM track t 
JOIN album2 a2 
ON t.album_id = a2.album_id
JOIN
artist a
ON a.artist_id = a2.artist_id
JOIN genre g 
ON t.genre_id = g.genre_id
WHERE g.name = "Rock"
GROUP BY a.artist_id,a.name
ORDER BY Total_Tracks DESC
LIMIT 10;
# Output
-- name, Total_Tracks
-- AC/DC	18
-- Aerosmith	15
-- Audioslave	14
-- Led Zeppelin	14
-- Alanis Morissette	13
-- Alice In Chains	12
-- Frank Zappa & Captain Beefheart	9
-- Accept	4

-- 3. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first
SELECT 
	t.name,
    t.milliseconds
FROM track t
WHERE t.milliseconds >(
						SELECT AVG(milliseconds) FROM track
					  )
ORDER BY t.milliseconds DESC;
# Output 
-- name, milliseconds
-- How Many More Times	711836
-- Advance Romance	677694
-- Sleeping Village	644571
-- You Shook Me(2)	619467
-- Talkin' 'Bout Women Obviously	589531
-- Stratus	582086
-- No More Tears	555075
-- The Alchemist	509413

-- Question Set 3 – Advance
-- 1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
WITH CTE_1 AS(
			SELECT
            a.artist_id,
            a.name AS Artist_Name,
            SUM(il.unit_price*il.quantity) AS Total_sales
		FROM invoice_line il
        JOIN track t
        ON il.track_id = t.track_id
        JOIN album2 a2
        ON t.album_id = a2.album_id
        JOIN artist a 
        ON a2.artist_id = a.artist_id
        GROUP BY 1,2
        ORDER BY 3 DESC
        LIMIT 1)
SELECT
	c.customer_id,
    CONCAT(c.first_name," ",c.last_name) AS Full_Name,
    ct.Artist_Name,
    SUM(il.unit_price*il.quantity) AS Total_Amount_Spent
FROM invoice i
JOIN customer c
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON il.invoice_id = i.invoice_id
JOIN track t 
ON t.track_id = il.track_id
JOIN album2 a2
ON a2.album_id = t.album_id
JOIN CTE_1 ct
ON ct.artist_id = a2.artist_id
GROUP BY 1,2,3
ORDER BY Total_Amount_Spent DESC;
# Output
-- customer_id, Full_Name, Artist_Name, Total_Amount_Spent
-- 54	Steve Murray	AC/DC	17.82
-- 53	Phil Hughes	AC/DC	10.89
-- 21	Kathy Chase	AC/DC	10.89
-- 49	StanisÅ‚aw WÃ³jcik	AC/DC	9.9
-- 1	LuÃ­s GonÃ§alves	AC/DC	7.920000000000001
-- 24	Frank Ralston	AC/DC	7.920000000000001
-- 31	Martha Silk	AC/DC	3.96
-- 16	Frank Harris	AC/DC	2.9699999999999998

-- 2. We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres
WITH CTE_2 AS(
			SELECT 
				c.country,
                g.name,
                g.genre_id,
                COUNT(il.quantity) AS Purchases,
                ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Rk
			FROM invoice_line il
            JOIN invoice i ON il.invoice_id = i.invoice_id
            JOIN customer c ON i.customer_id = c.customer_id
            JOIN track t ON il.track_id = t.track_id
            JOIN genre g ON g.genre_id = t.genre_id
            GROUP BY 1,2,3
            ORDER BY c.country ASC,Purchases DESC)
SELECT * FROM CTE_2 WHERE Rk <= 1;
# Output
-- country, name, genre_id, Purchases, Rk
-- Argentina	Rock	1	1	1
-- Australia	Rock	1	18	1
-- Austria	Rock	1	6	1
-- Belgium	Rock	1	5	1
-- Brazil	Rock	1	26	1
-- Canada	Rock	1	57	1

-- 3. Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount
WITH Customter_with_country AS (
		SELECT 
			customer.customer_id,
            CONCAT(first_name," ",last_name) AS Full_name,
            billing_country,
            SUM(total) AS total_spending,
			ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS Rk 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE Rk <= 1
# Output
-- customer_id, Full_name, billing_country, total_spending, Rk
-- 9	Kara Nielsen	Denmark	37.61999999999999	1
-- 56	Diego GutiÃ©rrez	Argentina	39.6	1
-- 47	Lucas Mancini	Italy	50.49	1
-- 8	Daan Peeters	Belgium	60.38999999999999	1
-- 48	Johannes Van der Berg	Netherlands	65.34	1
-- 7	Astrid Gruber	Austria	69.3	1
-- 4	BjÃ¸rn Hansen	Norway	72.27000000000001	1
-- 51	Joakim Johansson	Sweden	75.24	1