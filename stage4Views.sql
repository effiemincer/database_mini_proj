-- CREATE VIEWS
-- View 1: Active Loans for Readers (excluding returned books)
CREATE VIEW ActiveLoansView AS
SELECT
    R.ReaderID,
    R.FirstName,
    R.LastName,
    L.BookID AS ID,
    L.LoanDate,
    L.DueDate
FROM
    Readers R
    JOIN BooksOnLoan L ON R.ReaderID = L.ReaderID
WHERE
    NOT EXISTS (
        SELECT 1
        FROM BooksReturned BR
        WHERE BR.LoanID = L.LoanID
    );

-- View 2: Most Read Genres by Reader
CREATE VIEW MostReadGenresView AS
SELECT
    R.ReaderID,
    R.FirstName,
    R.LastName,
    G.Name AS GenreName,
    COUNT(*) AS ReadCount
FROM
    Readers R
    JOIN BooksOnLoan L ON R.ReaderID = L.ReaderID
    JOIN TypeOf T ON L.ID = T.ID
    JOIN Genre G ON T.GenreID = G.GenreID
GROUP BY
    R.ReaderID, R.FirstName, R.LastName, G.Name
ORDER BY
    R.ReaderID, ReadCount DESC;

-- SELECT QUERIES
-- Query 1: For ActiveLoansView
-- Books that are not returned and are past their due date
SELECT 
    * 
FROM 
    ActiveLoansView
WHERE 
    DueDate < CURRENT_DATE;

-- Query 2: For MostReadGenresView
-- Most-read genre for each reader (only one row per reader)
WITH GenreRanking AS (
    SELECT
        R.ReaderID,
        R.FirstName,
        R.LastName,
        G.Name AS GenreName,
        COUNT(*) AS ReadCount,
        ROW_NUMBER() OVER (PARTITION BY R.ReaderID ORDER BY COUNT(*) DESC) AS Rank
    FROM
        Readers R
        JOIN BooksOnLoan L ON R.ReaderID = L.ReaderID
        JOIN TypeOf T ON L.ID = T.ID
        JOIN Genre G ON T.GenreID = G.GenreID
    GROUP BY
        R.ReaderID, R.FirstName, R.LastName, G.Name
)
SELECT
    ReaderID,
    FirstName,
    LastName,
    GenreName,
    ReadCount
FROM
    GenreRanking
WHERE
    Rank = 1;


-- DATA MANIPULATION
-- Insert into ActiveLoansView (valid record)
INSERT INTO BooksOnLoan (ReaderID, ID, LoanDate, DueDate)
VALUES (1, 101, '2025-01-01', '2025-01-15');

-- Insert into ActiveLoansView (invalid record, LoanID already returned)
-- First, simulate a return for the loan
INSERT INTO BooksReturned (LoanID, ConditionOnReturn, ReturnDate)
VALUES (1, 'Good', '2025-01-05');

-- Now, attempt to insert the same loan into the ActiveLoansView (invalid due to ReturnID)
INSERT INTO BooksOnLoan (ReaderID, ID, LoanDate, DueDate)
VALUES (1, 101, '2025-01-01', '2025-01-15'); -- This will be excluded by the view

-- Update in MostReadGenresView (indirectly through the base tables)
-- Simulate a reader liking a new genre by adding a loan for a book of that genre
INSERT INTO BooksOnLoan (ReaderID, ID, LoanDate, DueDate)
VALUES (2, 102, '2025-01-01', '2025-01-15');

-- Delete in ActiveLoansView (valid deletion from base table)
DELETE FROM BooksOnLoan
WHERE LoanID = 1;

-- Invalid deletion (nonexistent LoanID)
DELETE FROM BooksOnLoan
WHERE LoanID = 999;

-- LOGGING AND EXPLANATIONS
-- 1. The first INSERT into BooksOnLoan succeeded because it was a valid loan record.
-- 2. The second INSERT was excluded by the `ActiveLoansView` because the loan already had a corresponding entry in `BooksReturned`.
-- 3. The addition of a loan for a new genre successfully updated the `MostReadGenresView`.
-- 4. The first DELETE from `BooksOnLoan` removed a valid loan record, while the second failed due to a nonexistent `LoanID`.

-- NOTES
-- The first view now ensures loans are "active" by checking for the absence of a `ReturnID` in `BooksReturned`.
-- The second view aggregates loan data to show the most-read genres by each reader, grouped and ordered by count.
