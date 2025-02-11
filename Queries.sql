\timing

-- COMMAND TO RUN THIS FILE: psql -U postgres -d "Mini Project" -f Queries.sql > QueriesWithFunctions.log


-- 1. Retrieve a list of all readers along with the total number of books they have ever borrowed.
SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    GetTotalBooksBorrowed(r.ReaderID) AS TotalBooksBorrowed
FROM Readers r
ORDER BY TotalBooksBorrowed DESC;

    -- TIMING

/* Query before functions were created:
SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COUNT(b.LoanID) AS TotalBooksBorrowed
FROM
    Readers r
    LEFT JOIN BooksOnLoan b ON r.ReaderID = b.ReaderID
GROUP BY
    r.ReaderID,
    r.FirstName,
    r.LastName
ORDER BY
    TotalBooksBorrowed DESC;

    -- TIME: 00.169s
*/


-- 2. Find the last notification sent to each reader and its status.

SELECT 
    r.ReaderID, 
    r.FirstName, 
    r.LastName, 
    n.Message_, 
    n.SentDate, 
    n.IsRead
FROM Readers r
CROSS JOIN LATERAL GetLastNotificationDetails(r.ReaderID) n
ORDER BY n.SentDate DESC;

/* Query before functions were created:
SELECT 
    Readers.ReaderID, 
    Readers.FirstName, 
    Readers.LastName, 
    Notifications.Message, 
    Notifications.SentDate, 
    Notifications.IsRead
FROM Readers
JOIN Notifications ON Readers.ReaderID = Notifications.ReaderID
WHERE Notifications.SentDate = (
    SELECT MAX(SentDate)
    FROM Notifications AS SubNotifications
    WHERE SubNotifications.ReaderID = Readers.ReaderID
)
ORDER BY Notifications.SentDate DESC;

    -- TIME: 02:15.844s
*/


-- 3. Calculate the average number of books borrowed by readers for each card type ('Electronic' or 'Physical').

SELECT
    rc.CardType,
    GetAverageBooksByCardType(rc.CardType) AS AverageBooksBorrowed
FROM ReaderCard rc
GROUP BY rc.CardType;

/* Query before functions were created:
WITH ReaderBorrowCounts AS (
    SELECT
        rc.ReaderID,
        rc.CardType,
        COUNT(b.LoanID) AS BooksBorrowed
    FROM
        ReaderCard rc
        LEFT JOIN BooksOnLoan b ON rc.ReaderID = b.ReaderID
    GROUP BY
        rc.ReaderID,
        rc.CardType
)
SELECT
    CardType,
    AVG(BooksBorrowed) AS AverageBooksBorrowed
FROM
    ReaderBorrowCounts
GROUP BY
    CardType;

    -- TIME: 00.112s
*/


-- 4. Retrieve a list of readers along with the number of their family members
-- and the total number of books borrowed by their family members.

SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COALESCE((
        SELECT COUNT(RelatedReaderID)
        FROM FamilyTies
        WHERE ReaderID = r.ReaderID
    ), 0) AS FamilyMemberCount,
    COALESCE(GetFamilyBooksBorrowed(r.ReaderID), 0) AS TotalFamilyBooksBorrowed
FROM Readers r
ORDER BY FamilyMemberCount DESC, TotalFamilyBooksBorrowed DESC;

/* Query before functions were created:
WITH AllFamilyTies AS (
    -- Combine family ties in both directions to account for bidirectional relationships
    SELECT ReaderID, RelatedReaderID FROM FamilyTies
    UNION
    SELECT RelatedReaderID AS ReaderID, ReaderID AS RelatedReaderID FROM FamilyTies
),
FamilyMemberCounts AS (
    -- Calculate the number of family members for each reader
    SELECT
        aft.ReaderID,
        COUNT(DISTINCT aft.RelatedReaderID) AS FamilyMemberCount
    FROM
        AllFamilyTies aft
    GROUP BY
        aft.ReaderID
),
FamilyBooksBorrowed AS (
    -- Calculate the total number of books borrowed by each reader's family members
    SELECT
        aft.ReaderID,
        COUNT(bol.LoanID) AS TotalFamilyBooksBorrowed
    FROM
        AllFamilyTies aft
        LEFT JOIN BooksOnLoan bol ON aft.RelatedReaderID = bol.ReaderID
    GROUP BY
        aft.ReaderID
)
SELECT
    r.ReaderID,
    r.FirstName,
    r.LastName,
    COALESCE(fmc.FamilyMemberCount, 0) AS FamilyMemberCount,
    COALESCE(fbb.TotalFamilyBooksBorrowed, 0) AS TotalFamilyBooksBorrowedByFamily
FROM
    Readers r
    LEFT JOIN FamilyMemberCounts fmc ON r.ReaderID = fmc.ReaderID
    LEFT JOIN FamilyBooksBorrowed fbb ON r.ReaderID = fbb.ReaderID
ORDER BY
    FamilyMemberCount DESC,
    TotalFamilyBooksBorrowedByFamily DESC;

    -- TIME: 00.125s

*/


-- 5. Update unread notifications older than a month to indicate follow-up is needed.
UPDATE Notifications
SET Message = CONCAT(Message, ' - Follow-Up Required')
WHERE IsRead = FALSE
  AND SentDate < CURRENT_DATE - INTERVAL '1 month';

--  RES:
--         UPDATE 23704

--         Query returned successfully in 422 msec.

  -- TIME: 00.422s


-- 6. Extend the return date for all overdue loans by 14 days.
UPDATE BooksOnLoan
SET DueDate = CURRENT_DATE + INTERVAL '14 days'
WHERE DueDate < CURRENT_DATE
  AND DueDate IS NOT NULL;

--  RES:
--         UPDATE 50977

--         Query returned successfully in 432 msec.

  -- TIME: 00.432s

-- 7. Delete all loan records with a ReturnDate older than one year.
DELETE FROM BooksOnLoan
WHERE DueDate < CURRENT_DATE - INTERVAL '1 year';

-- RES:

--      DELETE 0

--      Query returned successfully in 45 msec.

    -- TIME: 00.045s

-- 8. Remove a specific reader from the system (and cascade delete related loans).
DELETE FROM Readers
WHERE ReaderID = 1; -- Replace with specific ReaderID

-- RES:

--      DELETE 1

--      Query returned successfully in 50 msec.

    -- TIME: 00.050