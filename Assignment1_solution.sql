-- Run the create_rare_books.sql script found under Database
-- scripts in Canvas then answer each of the questions below.
-- Each question is worth 10 points.

use rarebooks;

-- Exercise 1
-- Show the count of books currently in stock for each 
-- condition description (i.e., Poor, Good, Fine, etc.).
SELECT c.condition_description, COUNT(ISBN) AS count
FROM   volume v JOIN condition_codes c USING (condition_code)
WHERE  v.sale_id IS NULL
GROUP BY c.condition_description;

-- Exercise 2
-- Show the total book sales for each condition code and
-- order the result by the highest sales first.
SELECT c.condition_description, SUM(v.selling_price) AS total_sales
FROM   volume v JOIN condition_codes c USING (condition_code)
WHERE  v.sale_id IS NOT NULL
GROUP BY c.condition_description
ORDER BY total_sales DESC;

-- Exercise 3
-- Find the inventory count for every book in stock by author name 
-- and book title.  Sort the result by author name then title, both
-- in ascending order.
SELECT a.author_last_first as author, w.title, SUM(t.count) as count
FROM author a JOIN work w USING (author_numb) JOIN
      (SELECT COUNT(*) AS count, b.isbn, b.work_numb
       FROM   volume v JOIN book b USING (isbn)
       WHERE  sale_id IS NULL
       GROUP BY b.isbn, b.work_numb) AS t
	 USING (work_numb)
GROUP BY a.author_last_first, w.title
ORDER BY a.author_last_first, w.title;

-- Exercise 4
-- Get the count of books in stock from each publisher.  Show the
-- ISBN, title, publisher name, edition, binding, copyright year,
-- and count of books in stock, ordered by publisher name ascending.
SELECT b.isbn, w.title, p.publisher_name, 
       b.edition, b.binding, b.copyright_year, t.count
FROM   publisher p JOIN book b USING (publisher_id)
       JOIN work w USING (work_numb)
       JOIN (SELECT COUNT(*) AS count, v.isbn
             FROM   volume v
             WHERE  sale_id IS NULL
             GROUP BY v.isbn) t
         USING (isbn)
ORDER BY p.publisher_name;

-- Exercise 5
-- Generate a sales report showing the daily sales for all book 
-- sales in the year 2021, with subtotals for month and year.
SELECT YEAR(sale_date) AS year, MONTH(sale_date) AS month,
	   DAY(sale_date) AS day, SUM(sale_total_amt) AS sales
FROM   sale
GROUP BY year, month, day WITH ROLLUP
HAVING year = 2021;

-- Exercise 6
-- Show the book inventory id, title, condition code and
-- selling price for books that had a selling price higher 
-- than the average selling price of books sold in July, 2021, 
-- sorted by title in ascending order.
SELECT v.inventory_id, w.title, c.condition_description, v.selling_price
FROM   volume v JOIN book b USING (isbn)
       JOIN work w USING(work_numb)
       JOIN condition_codes c USING (condition_code)
WHERE  v.selling_price > 
       (SELECT AVG(v1.selling_price)
        FROM   volume v1 JOIN sale s USING (sale_id)
        WHERE  YEAR(sale_date) = 2021 AND MONTH(sale_date) = 7)
ORDER BY w.title ASC;

-- Exercise 7
-- Generate the best seller list for July, 2021
-- Along with author and title, give the number of copies sold
-- and the total sales amount for each book.  Order the
-- result by copies sold in descending order.
-- Hint: You might try writing the query for copies sold first
SELECT a.author_last_first, w.title, COUNT(b.ISBN) AS copies_sold,
       SUM(v.selling_price) AS total_sales
FROM   author a JOIN work w USING (author_numb)
         JOIN book b USING (work_numb)
         JOIN volume v USING (ISBN)
         JOIN sale s USING (sale_id)
WHERE  v.selling_price IS NOT NULL
        AND MONTH(s.sale_date) = '7'
        AND YEAR(s.sale_date) = '2021'
GROUP BY a.author_last_first, w.title
ORDER BY copies_sold DESC;

-- Alternate solution - uses subquery
SELECT a.author_last_first as author, w.title, 
       SUM(t2.count) as copies_sold, 
	   SUM(t2.selling_price) AS total_sales
FROM author a JOIN work w USING (author_numb) JOIN
      (SELECT COUNT(t1.isbn) as count, 
              SUM(t1.selling_price) AS selling_price, 
              t1.isbn, t1.work_numb
       FROM (SELECT b.isbn, b.work_numb, v.selling_price
             FROM   volume v JOIN book b USING (isbn)
                     JOIN sale s USING (sale_id)
			 WHERE  YEAR(sale_date) = 2021 AND MONTH(sale_date) = 7) AS t1
       GROUP BY t1.isbn, t1.work_numb) AS t2
	 USING (work_numb)
GROUP BY a.author_last_first, w.title
ORDER BY copies_sold DESC;

-- Exercise 8
-- Give statements to insert a new sale for customer id 3 of the 
-- volume with inventory_id 67 on 11/3/2021 for $125 with credit 
-- card number 1234 5678 9101 4321, expiration month 7, expiration 
-- year 23.

BEGIN;

INSERT INTO sale
  (customer_numb, sale_date, sale_total_amt, 
   credit_card_numb, exp_month, exp_year)
VALUES 
  (3, '2021-03-11', 125.00, 
   '1234 5678 9101 4321', 7, 23);

UPDATE volume
SET    sale_id = LAST_INSERT_ID()
WHERE  inventory_id = 67;

COMMIT;

-- Exercise 9
-- Add the JK Rowling book "Harry Potter and Sorcerer's Stone"
-- to the rare book inventory.  This first edition book acquired
-- on 3/1/2018 is in excellent condition and has the ISBN 
-- 978-0-78622-272-8, a leather binding, the copyright year 1999 
-- from the publisher Thorndike Press and an asking price of $100.

BEGIN;

INSERT INTO author (author_last_first) 
VALUES ('Rowling, JK');

INSERT INTO work (author_numb, title)
VALUES (LAST_INSERT_ID(), "Harry Potter and the Sorcerer's Stone");

INSERT INTO book (isbn, work_numb, edition, binding, copyright_year)
VALUES ('978-0-78622-272-8', LAST_INSERT_ID(), 1, 'Leather', 1999);

INSERT INTO publisher (publisher_name) VALUES ('Thorndike Press');

UPDATE book
SET    publisher_id = LAST_INSERT_ID()
WHERE  isbn = '978-0-78622-272-8';

INSERT INTO volume (isbn, condition_code, date_acquired, asking_price)
VALUES ('978-0-78622-272-8', 2, '2018-03-01', 100);

COMMIT;

-- Exercise 10
-- Delete the publisher Thorndike Press from the Rare Books 
-- invetory.  Make sure to handle the case in which there are 
-- more than one book in inventory from Thorndike Press

BEGIN;

DELETE FROM volume
WHERE ISBN =
        (SELECT isbn
         FROM   book
         WHERE publisher_id = 
           (SELECT publisher_id
			FROM   publisher
            WHERE  publisher_name = 'Thorndike Press'));

DELETE FROM book 
WHERE publisher_id = 
        (SELECT publisher_id 
         FROM publisher
         WHERE publisher_name = 'Thorndike Press');
         
DELETE FROM publisher WHERE publisher_name = 'Thorndike Press';

COMMIT;