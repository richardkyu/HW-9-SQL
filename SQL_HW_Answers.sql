-- Reference that we are using the sakila database -- 
USE sakila;
SET SQL_SAFE_UPDATES=0;
-- 1a. First and Last Names--
SELECT first_name, last_name
FROM actor;

-- 1b. String manipulation of actor names --
SELECT upper(concat(first_name,' ',last_name)) as 'Actor Name'
FROM actor;

-- 2a. Actors with the first name Joe. Search using where...like... method --
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe';


-- 2b. Find all actors whose last name contain the letters "GEN", surround with % to query. --
SELECT first_name, last_name 
FROM actor 
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters. Order by rows first and last name respectively --
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Display country ID and column of specific countries. --
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3c. Delete middle name column, I put this first so results all display.--
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT *
FROM actor;


-- 3a. Work with the alter command --
ALTER TABLE actor
ADD COLUMN middle_name varchar(30) AFTER first_name;

SELECT *
FROM actor;

-- 3b. Change type of middle_name to blob --
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

SELECT *
FROM actor;


-- 4a. List counts of last names of actors --
SELECT last_name as 'Last Name', count(last_name) as 'Last Name Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names and number of actors sharing the same last name, but only for count >1. --
SELECT last_name as 'Last Name', 
COUNT(last_name) as 'Last Name Count'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c. Modify specific names, task to test comprehension of table element, show specific names--
SELECT first_name, last_name
FROM actor
WHERE first_name = 'Groucho' and last_name = 'Williams';

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'Groucho' and last_name = 'Williams';

SELECT *
FROM actor
WHERE last_name = 'Williams';

-- 4d. Change names again, work with conditionals. --
SELECT first_name
FROM actor
WHERE first_name = 'Harpo';

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'Harpo';

UPDATE actor
SET first_name = case
	when first_name = 'Harpo' THEN 'GROUCHO'
when first_name = 'Groucho' THEN 'MUCHO GROUCHO'
else first_name
END;
	
SELECT *
FROM actor;

-- 5a. Recreate a table -- 
DROP TABLE IF EXISTS address_new;
CREATE TABLE address_new (
	address_id integer(11) NOT NULL,
	address varchar(30) NOT NULL,
	address2 varchar(30) NOT NULL,
	district varchar(30) NOT NULL,
	city_id integer(11) NOT NULL,
	postal_code integer(11) NOT NULL,
	phone integer(10) NOT NULL,
	location varchar(30) NOT NULL,
	last_update datetime
);

-- 6a. Join to display first and last name, address of staff members. --
SELECT s.first_name as 'First Name', s.last_name as 'Last Name', a.address as 'Address'
FROM staff as s
JOIN address as a 
ON a.address_id = s.address_id;


-- 6b. Use join displays on staff and payment --
SELECT concat(s.first_name,' ',s.last_name) as 'Staff Member', sum(p.amount) as 'Total Amount'
FROM payment as p
JOIN staff as s
ON p.staff_id = s.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY p.staff_id;

-- 6c. Inner join--
SELECT f.title as 'Film', count(fa.actor_id) as 'Number of Actors'
FROM film as f
JOIN film_actor as fa
ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d. Check "Hunchback impossible" amount in inventory --
SELECT f.title as Film, count(i.inventory_id) as 'Inventory Count'
FROM film as f
JOIN inventory as i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.film_id;

-- 6e. Joins payment and customer, list by customer last name alphabetically. --
SELECT concat(c.first_name,' ',c.last_name) as 'Customer Name', sum(p.amount) as 'Total Paid'
FROM payment as p
JOIN customer as c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id;

-- 7a. Display titles with K or Q from film table--
SELECT f.title
FROM film as f
WHERE f.language_id = (select language_id from language where name = 'English')
AND f.title like 'K%' or 'Q%';

-- 7b. Subqueries to display actors in alone trip --
SELECT CONCAT(first_name,' ',last_name) as 'Actors Appearing in Alone Trip'
FROM actor
WHERE actor_id in 
(select actor_id from film_actor where film_id = 
(select film_id from film where title = 'Alone Trip'));

-- 7c. Email marketing campaign in Canada, retrieve Canadian addresses. --
SELECT concat(c.first_name,' ',c.last_name) as 'Name', c.email as 'E-mail'
FROM customer as c
JOIN address as a on c.address_id = a.address_id
JOIN city as cy on a.city_id = cy.city_id
JOIN country as ct on ct.country_id = cy.country_id
WHERE ct.country = 'Canada';

-- 7d. Identify family films. --
SELECT f.title as 'Movie Titles that are Family Films'
FROM film as f
JOIN film_category as fc on fc.film_id = f.film_id
JOIN category as c on c.category_id = fc.category_id
WHERE c.name = 'Family';

-- 7e. Most frequented rented movies in descending order. --
SELECT f.title as 'Movie', count(r.rental_date) as 'Times Rented'
FROM film as f
JOIN inventory as i on i.film_id = f.film_id
JOIN rental as r on r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY count(r.rental_date) desc;

-- 7f. Display business brought in by stores ($), hard --
SELECT store as 'Store', total_sales as 'Total Sales' 
FROM sales_by_store;
SELECT concat(c.city,', ',cy.country) as `Store`, s.store_id as 'Store ID', sum(p.amount) as `Total Sales` 
FROM payment as p
JOIN rental as r on r.rental_id = p.rental_id
JOIN inventory as i on i.inventory_id = r.inventory_id
JOIN store as s on s.store_id = i.store_id
JOIN address as a on a.address_id = s.address_id
JOIN city as c on c.city_id = a.city_id
JOIN country as cy on cy.country_id = c.country_id
GROUP BY s.store_id;

-- 7g. Show store information: ID, city, and country --
SELECT s.store_id as 'Store ID', c.city as 'City', cy.country as 'Country'
FROM store as s
JOIN address as a on a.address_id = s.address_id
JOIN city as c on c.city_id = a.city_id
JOIN country as cy on cy.country_id = c.country_id
ORDER BY s.store_id;

-- 7h. List the top five genres by gross revenue, descending order. --
SELECT c.name as 'Film', sum(p.amount) as 'Gross Revenue'
FROM category as c
JOIN film_category as fc on fc.category_id = c.category_id
JOIN inventory as i on i.film_id = fc.film_id
JOIN rental as r on r.inventory_id = i.inventory_id
JOIN payment as p on p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum(p.amount) desc
LIMIT 5;

-- 8a. Create a view? Just add one line to 7h. --
CREATE VIEW top_5_genre_revenue as 
SELECT c.name as 'Film', sum(p.amount) as 'Gross Revenue'
FROM category as c
JOIN film_category as fc on fc.category_id = c.category_id
JOIN inventory as i on i.film_id = fc.film_id
JOIN rental as r on r.inventory_id = i.inventory_id
JOIN payment as p on p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum(p.amount) desc
LIMIT 5;

-- 8b. Display data --
SELECT *
FROM top_5_genre_revenue;

-- 8c. Delete data using drop. --
DROP VIEW top_5_genre_revenue;
