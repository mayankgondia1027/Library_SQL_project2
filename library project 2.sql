create database library;
use library;
select * from library.branch;
select * from library.books;
select * from library.employees;
select * from library.members;
select * from library.return_status;
select * from library.issued_status;

-- insert a book record 9781601294562 to kill a mockingbird classic 6.00 yes harper lee JB lippincott and co
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values("978-1-60129-456-2","to kill a mockingbird","classic",6.00,"yes","harper lee","JB lippincott and co");
select * from books;

-- update an existing members address
update members
set member_address = "123 Rohtak"
where member_id = "C101";
select * from members;

-- delete a record from the issued status table
delete from issued_status
where issued_id = "IS106";
select * from issued_status;

-- retrieve all books issued by E101
select * from issued_status
where issued_emp_id = "E101";

-- list members who have issued more than one book
select issued_emp_id, count(issued_book_name) as Bookscount from issued_status 
group by issued_emp_id
having count(issued_book_name)>2
order by Bookscount desc;

-- CTAS
-- create summary table used CTAS to generate new tabless based on query results each book and total book_issued_count
-- joining books and issued_status;
create table books_count
as
select  books.isbn, books.book_title, count(issued_status.issued_id)
from books join issued_status
on books.book_title=issued_status.issued_book_name
group by books.book_title, books.isbn;
select* from books_count; 

-- all books in a specific category
select book_title,category from books
group by book_title,category
order by category;

select category, count(book_title) from books
group by 1 
order by 2 desc;

-- find the total rental income by category
select books.category, sum(books.rental_price), count(*)
from books join issued_status
on books.book_title = issued_status.issued_book_name
group by 1
order by 3 desc;

-- list members who registered in last 180 days
select * 
from members
where reg_date >= current_date - interval 365 day;

-- list the employees with the branch manager name and their branc details
select employees.*,branch.manager_id, e.emp_name as manager 
from employees join branch
on branch.branch_id = employees.branch_id
join employees as e
on e.emp_id = branch.manager_id;

-- create a table of books with rental price above 7 dollar
create table CostlyBooks
as 
select * from books
where rental_price >7;
select * from CostlyBooks;

-- retrive the list of books not returned 
select distinct issued_book_name,return_id
from issued_status left join return_status
on issued_status.issued_id = return_status.issued_id
where return_id is null;

-- create new column in return status
alter table return_status
add column book_quality varchar(15) default("Good");
select * from return_status;


update return_status
set book_quality = "Damaged"
where issued_id in ("IS112","IS117","IS118");

-- Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 550-day return period).
-- Display the member's_id, member's name, book title, issue date, and days overdue.
select current_date();
select issued_status.issued_member_id,
	   members.member_name,
	   books.book_title,
       issued_status.issued_date,
      --  return_status.return_date,
       datediff(current_date, issued_status.issued_date) as over_dues_days
       
from members join issued_status
on members.member_id = issued_status.issued_member_id
join books
on books.isbn = issued_status.issued_book_isbn
left join return_status
on return_status.issued_id = issued_status.issued_id
where return_status.return_date is null
and datediff(current_date, issued_status.issued_date)>550
order by over_dues_days desc;

-- Branch Performance Report
-- Create a query that generates a performance report for each branch,showing the number of
-- books issued, the number of books returned, and the total revenue generated from book rentals.
create table branch_reports 
as
select branch.branch_id,
       branch.manager_id,
	   count(issued_status.issued_id) as books_issued,
       count(return_status.return_id) as books_returned,
       sum(books.rental_price)
       from issued_status join employees
on employees.emp_id = issued_status.issued_emp_id
join branch
on employees.branch_id = branch.branch_id
left join return_status
on return_status.issued_id = issued_status.issued_id
join books
on issued_status.issued_book_isbn = books.isbn
group by 1,2;
select * from branch_reports;

-- CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
-- members who have issued at least one book in the last 18 months.
create table active_members 
as
select * from  members 
where member_id in (select distinct issued_member_id from issued_status
where issued_date >= current_date - interval 18 month);

-- Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.
select employees.emp_name, count(issued_status.issued_book_name), branch.branch_id
from employees join issued_status
on employees.emp_id = issued_status.issued_emp_id
join branch
on branch.branch_id = employees.branch_id
group by 1,3;

-- Identify Members Issuing High-Risk Books Write a query to identify members who have 
-- issued books more than once with the status "damaged" in the books table. Display the member 
-- name, book title, and the number of times they've issued damaged books.
select members.member_name, books.book_title, count(return_status.book_quality)
from members join issued_status
on members.member_id = issued_status.issued_member_id
join books
on issued_status.issued_book_isbn = books.isbn
join return_status
on issued_status.issued_id = return_status.issued_id
where return_status.book_quality = "Damaged"
group by 1,2
Having count(return_status.book_quality)>=1;





















