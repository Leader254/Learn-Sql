-- Find books in the fantasy genre whose title starts with the letter T. Display two columns: the title of the book, the publication year of the book. 
SELECT title, pub_year
FROM books
WHERE genre = 'fantasy' AND title LIKE 'T%'
ORDER BY title;

-- Find books in the romance genre that do not contain the word love in any case (uppercase or lowercase) in their titles. Display one column: the title of the book. in schema title	genre	pub_year	author

SELECT title
FROM books
WHERE genre = 'romance' AND LOWER(title) NOT LIKE '%love%'
ORDER BY title;

-- Retrieve information on which treatments have been performed by which doctors. For each treatment, display four columns: the name of the treatment, the type of the treatment, the first name of the doctor who performed it, the last name of the doctor who performed it.
-- Ensure that each treatment is listed only once for each doctor. Include all treatments that are offered by the clinic but have not been performed so far, leaving the doctor's name as NULL for these entries.

SELECT t.name AS treatment_name,
       t.type AS treatment_type,
       d.first_name AS doctor_first_name,
       d.last_name AS doctor_last_name
FROM (
    SELECT t.name, t.type, d.doctor_id, d.first_name, d.last_name
    FROM treatment t
    CROSS JOIN doctor d
) AS potential_treatments
LEFT JOIN visit v ON potential_treatments.doctor_id = v.doctor_id
                 AND potential_treatments.name = v.treatment_id
LEFT JOIN doctor d ON v.doctor_id = d.doctor_id
ORDER BY treatment_name, doctor_last_name, doctor_first_name;

-- Get details of all readers and their current book loans from the book_loan table. A book is considered currently loaned if the return_date column is NULL. Display four columns:
-- the reader's first name,
-- the reader’s last name,
-- the book title,
-- the borrow date.
-- If a reader doesn’t currently have any books on loan, show NULL for the book title and borrow date.
SELECT r.first_name AS reader_first_name,
       r.last_name AS reader_last_name,
       b.title AS book_title,
       bl.borrow_date
FROM reader r
LEFT JOIN book_loan bl ON r.id = bl.reader_id AND bl.return_date IS NULL
LEFT JOIN book b ON bl.book_id = b.id
ORDER BY r.last_name, r.first_name, bl.borrow_date;

-- Find patients who share the same email address with one of the doctors in the clinic. Display four columns:
-- the first name of the patient, label it patient_first_name,
-- the last name of the patient, label it patient_last_name,
-- the first name of the doctor, label it doctor_first_name,
-- the last name of the doctor, label it doctor_last_name. 
SELECT p.first_name AS patient_first_name,
       p.last_name AS patient_last_name,
       d.first_name AS doctor_first_name,
       d.last_name AS doctor_last_name
FROM patient p
JOIN doctor d ON p.email = d.email
ORDER BY p.last_name, p.first_name, d.last_name, d.first_name;

-- Using a database of sales transactions, find yearly sales statistics. Display three columns:
-- the year; label it year.
-- the total revenue for this year; label it revenue.
-- the average sales value in this year, rounded to two decimal places; label it avg_sale.

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(price) AS revenue,
    ROUND(AVG(price), 2) AS avg_sale
FROM sale
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Find orders that have been shipped more than 5 days after the order date. Display four columns:
-- the order ID,
-- the customer,
-- the order date,
-- the shipped date.
SELECT 
    order_id,
    customer,
    order_date,
    shipped_date
FROM 
    orders
WHERE 
    shipped_date > order_date + INTERVAL '5' DAY
ORDER BY 
    order_id;
-- Doctors have the option to include a brief biography which is showcased on the clinic's website. This information is stored in a column biography in our database, and it may either contain text, be empty, or have a NULL value.
-- Compute one column: the average character count of the doctors' biographies in our database.
-- If a biography is either empty or has a NULL value, its character count should be considered as 0. Round the result to two decimal places.
SELECT 
    ROUND(AVG(CASE 
                WHEN biography IS NULL OR LENGTH(biography) = 0 THEN 0 
                ELSE LENGTH(biography) 
              END), 2) AS avg_char_count
FROM 
    doctor;

-- For each reader registered at the library display three columns:
-- the first name of the reader,
-- the last name of the reader,
-- the total number of books they have ever borrowed from the library; label it books.
-- For those who have not borrowed any books, show a 0 in the books column.
-- Sort the results in descending order by the count of borrowed books and then alphabetically by last name and first name of the reader.
SELECT 
    r.first_name,
    r.last_name,
    COALESCE(COUNT(bl.book_id), 0) AS books
FROM 
    reader r
LEFT JOIN 
    book_loan bl ON r.id = bl.reader_id
GROUP BY 
    r.id, r.first_name, r.last_name
ORDER BY 
    books DESC,
    r.last_name,
    r.first_name;

-- For each product category find out how many different customers bought a product from this category. Display:
-- the name of the category; name the column category.
-- how many different customers bought a product from this category; name it customers.
-- Make sure to include each category only once. Include product categories that have never been sold. Show 0 for those categories.
-- Remember that the same customer may have made multiple orders.

SELECT 
    p.category AS category,
    COALESCE(COUNT(DISTINCT o.customer_id), 0) AS customers
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.id = oi.product_id
LEFT JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    customers DESC, category;

-- We are interested in patients who have visited the same doctor more than once. Select six columns:
-- the first name of the patient; label it patient_first_name.
-- the last name of the patient; label it patient_last_name.
-- the first name of the doctor; label it doctor_first_name.
-- the last name of the doctor; label it doctor_last_name.
-- the specialization of the doctor.
-- the number of visits the patient had with the doctor; label it visits.
-- Sort the results alphabetically by the patient’s last and first name, and then by doctor’s last and first name.
-- Make sure to display only the patient-doctor combinations with more than one visit.
SELECT 
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    d.specialization,
    COUNT(v.id) AS visits
FROM 
    visit v
JOIN 
    patient p ON v.patient_id = p.id
JOIN 
    doctor d ON v.doctor_id = d.id
GROUP BY 
    p.id, p.first_name, p.last_name, d.id, d.first_name, d.last_name, d.specialization
HAVING 
    COUNT(v.id) > 1
ORDER BY 
    p.last_name, p.first_name, d.last_name, d.first_name;

-- Find treatments with the price higher than the average for their type. Display two columns:
-- the name of the treatment,
-- the type of the treatment.
SELECT 
    treatment.name AS treatment_name,
    treatment.type AS treatment_type
FROM 
    treatment
JOIN 
    (SELECT type, AVG(price) AS avg_price
     FROM treatment
     GROUP BY type) avg_treatment
ON 
    treatment.type = avg_treatment.type
WHERE 
    treatment.price > avg_treatment.avg_price
ORDER BY 
    treatment.name;

-- Find books that have been borrowed from the library as many times or more than the most frequently borrowed book written by author Stephen King. Display one column only:
-- the title of the book.
-- Make sure to include each book only once. Order the results alphabetically by book titles.
SELECT 
    b.title AS title_of_book
FROM 
    book b
JOIN 
    book_loan bl ON b.id = bl.book_id
JOIN 
    author a ON b.author_id = a.id
WHERE 
    b.id IN (
        SELECT 
            b2.id
        FROM 
            book b2
        JOIN 
            author a2 ON b2.author_id = a2.id
        JOIN 
            book_loan bl2 ON b2.id = bl2.book_id
        WHERE 
            a2.first_name = 'Stephen' AND a2.last_name = 'King'
        GROUP BY 
            b2.id
        ORDER BY 
            COUNT(bl2.id) DESC
        LIMIT 1
    )
GROUP BY 
    b.id
HAVING 
    COUNT(bl.id) >= (
        SELECT 
            COUNT(bl2.id)
        FROM 
            book b2
        JOIN 
            author a2 ON b2.author_id = a2.id
        JOIN 
            book_loan bl2 ON b2.id = bl2.book_id
        WHERE 
            a2.first_name = 'Stephen' AND a2.last_name = 'King'
        GROUP BY 
            b2.id
        ORDER BY 
            COUNT(bl2.id) DESC
        LIMIT 1
    )
ORDER BY 
    b.title;

-- We want to know the books at the library the readers have enjoyed the most. Select two columns:
-- the title of the book.
-- a column labeled book_rating.
-- Display the following values in the book_rating column:
-- 'bad' for books with a rating below 3.
-- 'okay' for books with a rating between 3 and 4.5.
-- 'great' for books with a rating score equal to or above 4.5.
SELECT
    title AS title_of_book,
    CASE
        WHEN rating < 3 THEN 'bad'
        WHEN rating >= 3 AND rating <= 4.5 THEN 'okay'
        WHEN rating > 4.5 THEN 'great'
    END AS book_rating
FROM
    book
ORDER BY
    title_of_book;

-- Compute the running total for each order. The running total is the cumulative sum of the revenue, which includes the total order amount of the current order and all preceding orders. Display:
-- the order ID,
-- the order date,
-- the total order amount,
-- the running total of the orders, label it running_total.
-- Sort the results chronologically by order_date. 

SELECT
    o.order_id,
    o.order_date,
    o.total_price AS total_order_amount,
    SUM(o.total_price) OVER (ORDER BY o.order_date, o.order_id) AS running_total
FROM
    orders o
ORDER BY
    o.order_date, o.order_id;

-- Generate a ranking of the top-selling products in each product category. Show four columns:
-- the name of the product; label it name,
-- the category of the product; label it category,
-- the total number of units of the product sold; label this column as total_quantity,
-- the rank of the product with its category based on the total number of units sold; label it category_rank.
-- Rank the products within each category based on the total number of items sold, from highest to lowest. The ranking should follow these rules:
-- The product with the highest number of units sold in each category should be assigned a rank of 1.
-- The next highest should have a rank of 2, and so on.
-- In case of a tie in the number of units sold, products should share the same rank, and the next product should be assigned a rank that is incremented by the number of tied products.
-- Sort the results first by product category in alphabetical order, by the ranking in ascending order and then by the product name in alphabetical order.

WITH category_ranked_products AS (
    SELECT
        p.name AS name,
        p.category AS category,
        SUM(oi.quantity) AS total_quantity,
        DENSE_RANK() OVER(PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS category_rank
    FROM
        product p
    JOIN
        order_items oi ON p.id = oi.product_id
    JOIN
        orders o ON oi.order_id = o.order_id
    GROUP BY
        p.name, p.category
)
SELECT
    name,
    category,
    total_quantity,
    category_rank
FROM
    category_ranked_products
ORDER BY
    category ASC,
    category_rank ASC,
    name ASC;

-- Find doctors who have performed more visits than the average for their specialization. Display two columns:
-- the first name of the doctor,
-- the last name of the doctor
WITH avg_visits_per_specialization AS (
    SELECT
        doctor.specialization,
        AVG(visit_count) AS avg_visits
    FROM
        doctor
    LEFT JOIN (
        SELECT
            doctor_id,
            COUNT(*) AS visit_count
        FROM
            visit
        GROUP BY
            doctor_id
    ) AS v ON doctor.id = v.doctor_id
    GROUP BY
        doctor.specialization
),
doctor_visits AS (
    SELECT
        doctor.first_name,
        doctor.last_name,
        doctor.specialization,
        COUNT(visit.id) AS num_visits
    FROM
        doctor
    JOIN
        visit ON doctor.id = visit.doctor_id
    GROUP BY
        doctor.id, doctor.first_name, doctor.last_name, doctor.specialization
)
SELECT
    doctor_visits.first_name,
    doctor_visits.last_name
FROM
    doctor_visits
JOIN
    avg_visits_per_specialization ON doctor_visits.specialization = avg_visits_per_specialization.specialization
WHERE
    doctor_visits.num_visits > avg_visits_per_specialization.avg_visits
ORDER BY
    doctor_visits.specialization ASC,
    doctor_visits.last_name ASC,
    doctor_visits.first_name ASC;
