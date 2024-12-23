
/*---------------------------------------------------
  1) OverdueLoansView
  - For librarians: shows only overdue, unreturned books.
  - A row is considered overdue if:
    (DueDate < CURRENT_DATE) AND (the book not in BooksReturned).
-----------------------------------------------------*/
DROP VIEW IF EXISTS OverdueLoansView CASCADE;

CREATE VIEW OverdueLoansView AS
SELECT
    bol.LoanID,
    bol.ReaderID,
    bol.BookID,
    bol.LoanDate,
    bol.DueDate
FROM
    BooksOnLoan bol
    LEFT JOIN BooksReturned br ON bol.LoanID = br.LoanID
WHERE
    br.LoanID IS NULL  -- Book not returned
    AND bol.DueDate < CURRENT_DATE;

-- SELECT: Retrieves overdue books, calculates how many days each is overdue,
-- and sorts results by the most overdue first.
SELECT
    LoanID,
    ReaderID,
    BookID,
    LoanDate,
    DueDate,
    (CURRENT_DATE - DueDate) AS DaysOverdue
FROM OverdueLoansView
ORDER BY DaysOverdue DESC;

-- TIME: 00.153s

-- This view is not updatable because it contains a LEFT JOIN.




Thought for 10 seconds
sql
Copy code
/*
-------------------------------------------------------------------------------------
 (a) CREATE FOUR VIEWS + ONE SELECT QUERY EACH + INSERT/UPDATE/DELETE STATEMENTS
-------------------------------------------------------------------------------------
 Explanation:

  We have four distinct views corresponding to four different user sub-groups:
    1. OverdueLoansView         (for librarians managing overdue books)
    2. ElectronicCardHoldersView (for card managers overseeing electronic card usage)
    3. FamilyChildTiesView       (for family-services staff focusing on parent-child relationships)
    4. UnreadNotificationsView   (for staff managing unread notifications)

  Each view:
    1. Is created with relevant SELECT logic, optionally with filtering conditions.
    2. Has one demonstration SELECT to show how the view is used.
    3. Has at least one DML (INSERT, UPDATE, or DELETE) command to demonstrate view manipulation.

  We optionally demonstrate correct and invalid attempts to manipulate the data in each view,
  illustrating how the DBMS handles view updates and constraints.

-------------------------------------------------------------------------------------
  PREREQUISITES:
    - Assumes existing tables: Readers, ReaderCard, BooksOnLoan, BooksReturned,
      FamilyTies, Notifications, with the schema you provided.
    - Assumes relevant foreign key and check constraints are in place.
    - The WITH CHECK OPTION is only applicable if a view is updatable; we use it
      in an example view to illustrate restricting updates that violate the WHERE clause.
-------------------------------------------------------------------------------------
*/


/*---------------------------------------------------
  1) OverdueLoansView
  - For librarians: shows only overdue, unreturned books.
  - A row is considered overdue if:
    (DueDate < CURRENT_DATE) AND (the book not in BooksReturned).
-----------------------------------------------------*/
DROP VIEW IF EXISTS OverdueLoansView CASCADE;

CREATE VIEW OverdueLoansView AS
SELECT
    bol.LoanID,
    bol.ReaderID,
    bol.BookID,
    bol.LoanDate,
    bol.DueDate
FROM
    BooksOnLoan bol
    LEFT JOIN BooksReturned br ON bol.LoanID = br.LoanID
WHERE
    br.LoanID IS NULL  -- Book not returned
    AND bol.DueDate < CURRENT_DATE;

/*
  (a2) SELECT Query from OverdueLoansView
*/
-- Example usage: List all overdue loans
SELECT * FROM OverdueLoansView;

/*
  (a3) DML Statements on OverdueLoansView
  - We'll demonstrate an UPDATE that extends the DueDate (an attempt to resolve overdue).
  - We'll also show an invalid DELETE attempt (due to no real row removal logic or constraints).
*/

/* Correct UPDATE: Extend DueDate by 7 days for a specific overdue loan (LoanID=1 as example). */
UPDATE OverdueLoansView
SET DueDate = DueDate + INTERVAL '7 days'
WHERE LoanID = 1;  -- Adjust LoanID as appropriate for your data

/* 
   Example Invalid DELETE Attempt:
   Since OverdueLoansView is derived primarily from BooksOnLoan records, 
   deleting from the view would try to delete from BooksOnLoan. That may 
   or may not be logically permissible if constraints or application rules 
   forbid removing an active overdue record. We'll try it here and note
   possible error or warning.
*/
DELETE FROM OverdueLoansView
WHERE LoanID = 999;  -- If no such record or constraints forbid it, we'd see an error or zero rows deleted.

-------------------------------------------------------------------------------------


/*---------------------------------------------------
  2) ElectronicCardHoldersView
  - For card managers: list only those readers holding 
    an electronic card type, along with expiration details.
  - Demonstrate WITH CHECK OPTION so that updates that make
    a row fall outside the view (e.g., changing CardType to Physical) are rejected.
-----------------------------------------------------*/
DROP VIEW IF EXISTS ElectronicCardHoldersView CASCADE;

CREATE VIEW ElectronicCardHoldersView
AS
SELECT
    rc.CardID,
    rc.ReaderID,
    rc.CardType,
    rc.ExpirationDate
FROM
    ReaderCard rc
WHERE
    rc.CardType = 'Electronic'
WITH CHECK OPTION; 
-- The WITH CHECK OPTION ensures that any INSERT/UPDATE
-- that breaks the WHERE condition is not allowed.


-- SELECT: Shows electronic card holders, calculates days until expiration,
-- and orders them starting with soonest-to-expire cards.
SELECT
    CardID,
    ReaderID,
    ExpirationDate,
    (ExpirationDate - CURRENT_DATE) AS DaysLeft
FROM ElectronicCardHoldersView
ORDER BY DaysLeft ASC;

    -- TIME:  00.060s

-- UPDATE: Automatically extends card expiration for those expiring in under 30 days.
UPDATE ElectronicCardHoldersView
SET ExpirationDate = CURRENT_DATE + INTERVAL '1 year'
WHERE CardID IN (
    SELECT CardID
    FROM ElectronicCardHoldersView
    WHERE ExpirationDate < CURRENT_DATE + INTERVAL '30 days'
);

    -- TIME:  00.263s

-- DELETE: Removes an electronic card entry for a specific reader (ReaderID = 10).
DELETE FROM ElectronicCardHoldersView
WHERE CardID IN (
    SELECT CardID
    FROM ElectronicCardHoldersView
    WHERE ReaderID = 10
);


    -- TIME:  00.056s


/*---------------------------------------------------
  3) FamilyChildTiesView
  - For family-services staff focusing on parent-child ties.
  - Filter FamilyTies to only show "Child" relationships.
  - Updatable if columns map to base table columns without complex aggregates.
-----------------------------------------------------*/
DROP VIEW IF EXISTS FamilyChildTiesView CASCADE;

CREATE VIEW FamilyChildTiesView
AS
SELECT
    ft.TieID,
    ft.ReaderID,
    ft.RelatedReaderID,
    ft.RelationType
FROM
    FamilyTies ft
WHERE
    ft.RelationType = 'Child'
WITH CHECK OPTION;  
-- We use WITH CHECK OPTION so that any change that sets 
-- RelationType to something else is rejected.


-- SELECT: Lists child relationships, sorting by parent (ReaderID) then child (RelatedReaderID).
SELECT
    TieID,
    ReaderID,
    RelatedReaderID,
    RelationType
FROM FamilyChildTiesView
ORDER BY ReaderID, RelatedReaderID;

    -- TIME:  00.077s

-- UPDATE: Extends the DueDate by 7 days for books borrowed by children of a family.
UPDATE BooksOnLoan b
SET DueDate = b.DueDate + INTERVAL '7 days'
WHERE b.DueDate >= CURRENT_DATE
  AND b.ReaderID IN (
      SELECT fct.RelatedReaderID
      FROM FamilyChildTiesView fct
  );

    -- TIME:  00.143s

-- DELETE: Removes child ties for a reader determined by name, using a subquery on Readers.
DELETE FROM FamilyChildTiesView
WHERE TieID IN (
    SELECT ft.TieID
    FROM FamilyChildTiesView ft
    WHERE ft.ReaderID IN (
        SELECT r.ReaderID
        FROM Readers r
        WHERE r.FirstName = 'Matthew'
          AND r.LastName  = 'Wilson'
    )
);

    -- TIME:  00.053s


/*---------------------------------------------------
  4) UnreadNotificationsView
  - For staff managing unread notifications. 
  - Lists notifications where IsRead = false. 
  - They can mark them read or remove old notifications.
-----------------------------------------------------*/
DROP VIEW IF EXISTS UnreadNotificationsView CASCADE;

CREATE VIEW UnreadNotificationsView
AS
SELECT
    NotificationID,
    ReaderID,
    Message,
    SentDate,
    IsRead
FROM
    Notifications
WHERE
    IsRead = FALSE;

-- SELECT: Retrieves unread notifications, calculates how many days they’ve been unread,
-- and sorts by the longest unread duration first.
SELECT
    NotificationID,
    ReaderID,
    Message,
    SentDate,
    IsRead,
    (CURRENT_DATE - SentDate) AS DaysUnseen
FROM UnreadNotificationsView
ORDER BY DaysUnseen DESC;

    -- TIME:  00.092s

-- UPDATE: Marks notifications as read if older than 14 days, for a specific reader.
UPDATE UnreadNotificationsView
SET IsRead = TRUE
WHERE NotificationID IN (
    SELECT NotificationID
    FROM UnreadNotificationsView
    WHERE ReaderID = 25626
      AND (CURRENT_DATE - SentDate) > 14
);

    -- TIME:  00.059s

-- DELETE: Removes notifications for a reader determined by name, using a subquery on Readers.
DELETE FROM UnreadNotificationsView
WHERE NotificationID IN (
    SELECT un.NotificationID
    FROM UnreadNotificationsView un
    WHERE un.ReaderID = (
        SELECT r.ReaderID
        FROM Readers r
        WHERE r.FirstName = 'Hector'
          AND r.LastName  = 'Stark'
    )
);

-- TIME:  00.079s