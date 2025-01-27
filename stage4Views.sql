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

-- Timing: 00.084


-- View 2: Most Read Genres by Reader
CREATE VIEW MostReadGenresView AS
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
        JOIN Type_of T ON L.BookID = T.ID
        JOIN Genre G ON T.Genre_ID = G.Genre_ID
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

    -- Timing : 0.085

-- SELECT QUERIES
-- Query 1: ActiveLoansView
-- Books that are not returned and are past their due date
SELECT DISTINCT
    L.LoanID,
    R.ReaderID,
    R.FirstName,
    R.LastName,
    L.BookID,
    B.Title AS BookTitle,
    L.LoanDate,
    L.DueDate
FROM 
    Readers R
    JOIN BooksOnLoan L ON R.ReaderID = L.ReaderID
    JOIN Book B ON L.BookID = B.ID
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM BooksReturned BR
        WHERE BR.LoanID = L.LoanID
    )
    AND L.DueDate < CURRENT_DATE;

--> Timing: 00.794

-- Query 2: MostReadGenresView
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
        JOIN Type_of T ON L.BookID = T.ID
        JOIN Genre G ON T.Genre_ID = G.Genre_ID
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

--> Timing 01.887

-- DATA MANIPULATION
-- Insert into ActiveLoansView (valid record)
INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate)
VALUES (100, 101, '2025-01-01', '2025-01-15');

--> timing 0.090

-- Delete in ActiveLoansView 
DELETE FROM BooksOnLoan
WHERE LoanID = 10001;
-- Timing 0.082

-- Update in MostReadGenresView (indirectly through the base tables)
-- Simulate a reader liking a new genre by adding a loan for a book of that genre
INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate)
VALUES (2, 102, '2025-01-01', '2025-01-15');
--> Timing 0.092

-- Delete in ActiveLoansView (valid deletion from base table)
DELETE FROM BooksOnLoan
WHERE LoanID = 1;
-- Timing : 00.128