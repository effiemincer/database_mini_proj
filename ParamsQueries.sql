-- Query 1: Retrieve All Family Members for a Specific Reader
PREPARE get_family_members(INT) AS
SELECT
    r2.ReaderID,
    r2.FirstName,
    r2.LastName,
    ft.RelationType
FROM
    FamilyTies ft
    JOIN Readers r2 ON ft.RelatedReaderID = r2.ReaderID
WHERE
    ft.ReaderID = $1
ORDER BY
    ft.RelationType;

EXECUTE get_family_members(12620); -- Example ReaderID

    -- TIME: 00.046s

-- Query 2: Find Readers Who Borrowed More Than a Specified Number of Books Within a Date Range
PREPARE get_active_readers(DATE, DATE, INT) AS
SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COUNT(b.LoanID) AS BooksBorrowed
FROM
    Readers r
    JOIN BooksOnLoan b ON r.ReaderID = b.ReaderID
WHERE
    b.LoanDate BETWEEN $1 AND $2
GROUP BY
    r.ReaderID,
    r.FirstName,
    r.LastName
HAVING
    COUNT(b.LoanID) > $3
ORDER BY
    BooksBorrowed DESC;

EXECUTE get_active_readers('2015-01-01', '2023-12-31', 6);

    -- TIME: 00.060s

-- Query 3: Update the expiration date of reader cards by extending them by one year for 
-- readers who have borrowed more than a specified number of books within the last year.
PREPARE extend_card_expiration(INT) AS
UPDATE ReaderCard rc
SET ExpirationDate = rc.ExpirationDate + INTERVAL '1 year'
WHERE rc.ReaderID IN (
    SELECT r.ReaderID
    FROM Readers r
    JOIN BooksOnLoan b ON r.ReaderID = b.ReaderID
    WHERE b.LoanDate >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY r.ReaderID
    HAVING COUNT(b.LoanID) > $1
);

EXECUTE extend_card_expiration(5);  -- Replace 5 with the minimum number of books borrowed

-- RES:

--      UPDATE 190

--      Query returned successfully in 103 msec.

    -- TIME: 00.190s

-- Query 4: Delete readers who have not borrowed any books in the last x years .
PREPARE delete_inactive_readers(DATE) AS
WITH LastLoanDates AS (
    SELECT
        r.ReaderID,
        MAX(b.LoanDate) AS LastLoanDate
    FROM
        Readers r
        LEFT JOIN BooksOnLoan b ON r.ReaderID = b.ReaderID
    GROUP BY
        r.ReaderID
),
InactiveReaders AS (
    SELECT
        lld.ReaderID
    FROM
        LastLoanDates lld
    WHERE
        lld.LastLoanDate IS NULL OR lld.LastLoanDate < $1
)
DELETE FROM Readers r
USING InactiveReaders ir
WHERE r.ReaderID = ir.ReaderID
RETURNING r.ReaderID, r.FirstName, r.LastName;

EXECUTE delete_inactive_readers(CURRENT_DATE - INTERVAL '2 years');


    -- TIME: 01:06.616s
    -- TIME WITH INDEXES: 02.627s
    -- 