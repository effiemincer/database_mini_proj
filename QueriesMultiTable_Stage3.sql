-- 1. Query: List the Top 5 Readers with the Most Unreturned Books Borrowed in the Last Month
-- This query joins Readers, BooksOnLoan, and BooksReturned to identify readers who have
-- outstanding books borrowed within the past 30 days. It counts unreturned books and lists 
-- the top 5 readers with the most unreturned books.

SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COUNT(bol.LoanID) AS UnreturnedBooks
FROM
    Readers r
    JOIN BooksOnLoan bol ON r.ReaderID = bol.ReaderID
    LEFT JOIN BooksReturned br ON bol.LoanID = br.LoanID
WHERE
    bol.LoanDate >= CURRENT_DATE - INTERVAL '30 days'
    AND br.LoanID IS NULL  -- Books that have not been returned
GROUP BY
    r.ReaderID,
    r.FirstName,
    r.LastName
ORDER BY
    UnreturnedBooks DESC
LIMIT 5;

    -- TIME: 00.087

-- 2. Query: Count Family Members of Readers Who Have an Electronic Card
-- This query counts how many family members each reader has, but only for readers whose
-- card type is 'Electronic'. It joins Readers, FamilyTies, and ReaderCard tables, filtering
-- by card type and sorting by the total number of family members.

SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COUNT(ft.RelatedReaderID) AS TotalFamilyMembers
FROM
    Readers r
    JOIN ReaderCard rc ON r.ReaderID = rc.ReaderID
    LEFT JOIN FamilyTies ft ON r.ReaderID = ft.ReaderID
WHERE
    rc.CardType = 'Electronic'
GROUP BY
    r.ReaderID,
    r.FirstName,
    r.LastName
ORDER BY
    TotalFamilyMembers DESC;

    -- TIME: 00.071


-- 3. Query: Extend Card Expiration Date by One Year for Frequent Borrowers Using a Multi-Table Join
-- Explanation:
-- 1) We use a CTE called BorrowCounts that joins Readers (r) and BooksOnLoan (b) to compute how many books
--    each reader has borrowed in the past year.
-- 2) In the UPDATE, we join ReaderCard (rc) to BorrowCounts (bc) on ReaderID, then update the ExpirationDate
--    for those whose BorrowCount exceeds 3.

WITH BorrowCounts AS (
    SELECT
        r.ReaderID,
        COUNT(b.LoanID) AS BorrowCount
    FROM
        Readers r
        JOIN BooksOnLoan b ON r.ReaderID = b.ReaderID
    WHERE
        b.LoanDate >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY
        r.ReaderID
)
UPDATE ReaderCard rc
SET ExpirationDate = rc.ExpirationDate + INTERVAL '1 year'
FROM BorrowCounts bc
WHERE
    rc.ReaderID = bc.ReaderID
    AND bc.BorrowCount > 3;

    -- TIME: 00.140