
CREATE TABLE fact_booksales (
  sale_id INT PRIMARY KEY,
  book_id INT,
  store_id INT,
  time_id INT,
  quantity INT,
  total_price DECIMAL(10, 2),
  FOREIGN KEY (book_id) REFERENCES dim_book(book_id),
  FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
  FOREIGN KEY (time_id) REFERENCES dim_time(time_id)
);

CREATE TABLE dim_book (
  book_id INT PRIMARY KEY,
  title VARCHAR(255),
  author VARCHAR(255),
  publisher VARCHAR(255),
  genre VARCHAR(100)
);


CREATE TABLE dim_store (
  store_id INT PRIMARY KEY,
  store_name VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100)
);


CREATE TABLE dim_time (
  time_id INT PRIMARY KEY,
  year INT,
  quarter INT,
  month INT,
  day INT
);


INSERT INTO dim_book (book_id, title, author, publisher, genre) VALUES
(1, 'Kindred', 'Octavia E. Butler', 'Doubleday', 'Science Fiction'),
(2, 'Dune', 'Frank Herbert', 'Chilton Books', 'Science Fiction'),
(3, 'The Hobbit', 'J.R.R. Tolkien', 'George Allen & Unwin', 'Fantasy');


INSERT INTO dim_store (store_id, store_name, city, country) VALUES
(1, 'Book Haven', 'Vancouver', 'Canada'),
(2, 'Read Corner', 'Toronto', 'Canada'),
(3, 'Page Turners', 'Seattle', 'USA');

INSERT INTO dim_time (time_id, year, quarter, month, day) VALUES
(1, 2018, 4, 12, 15),
(2, 2019, 1, 1, 5),
(3, 2018, 4, 11, 30);

INSERT INTO fact_booksales (sale_id, book_id, store_id, time_id, quantity, total_price) VALUES
(1, 1, 1, 1, 50, 500.00),
(2, 2, 2, 2, 30, 300.00),
(3, 3, 3, 3, 70, 700.00);



-- 1. إجمالي عدد الكتب المباعة لكل كاتب في كل مدينة
SELECT dim_book.author, dim_store.city, SUM(fact_booksales.quantity) AS total_books
FROM fact_booksales
LEFT JOIN dim_book ON fact_booksales.book_id = dim_book.book_id
LEFT JOIN dim_store ON fact_booksales.store_id = dim_store.store_id
GROUP BY dim_book.author, dim_store.city;

-- 2. الكتب الأكثر مبيعًا في متجر معين خلال الربع الثاني
SELECT dim_book.title, dim_store.store_name, SUM(fact_booksales.quantity) AS total_books
FROM fact_booksales
LEFT JOIN dim_book ON fact_booksales.book_id = dim_book.book_id
LEFT JOIN dim_store ON fact_booksales.store_id = dim_store.store_id
LEFT JOIN dim_time ON fact_booksales.time_id = dim_time.time_id
WHERE dim_time.quarter = 2
GROUP BY dim_book.title, dim_store.store_name
ORDER BY total_books DESC;

-- 3. الكاتب صاحب أعلى مبيعات خلال سنة محددة
SELECT dim_book.author, SUM(fact_booksales.quantity) AS total_books
FROM fact_booksales
LEFT JOIN dim_book ON fact_booksales.book_id = dim_book.book_id
LEFT JOIN dim_time ON fact_booksales.time_id = dim_time.time_id
WHERE dim_time.year = 2018
GROUP BY dim_book.author
ORDER BY total_books DESC;

-- 4. المدن التي حققت مبيعات تفوق 150 كتابًا خلال فترة محددة
SELECT dim_store.city, SUM(fact_booksales.quantity) AS total_books
FROM fact_booksales
LEFT JOIN dim_store ON fact_booksales.store_id = dim_store.store_id
GROUP BY dim_store.city
HAVING SUM(fact_booksales.quantity) > 150;
