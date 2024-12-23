\timing

-- Function to get the total books borrowed by a reader
DROP FUNCTION IF EXISTS GetTotalBooksBorrowed(integer);

CREATE OR REPLACE FUNCTION GetTotalBooksBorrowed(reader_id INT)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(LoanID)
        FROM BooksOnLoan
        WHERE ReaderID = reader_id
    );
END;
$$ LANGUAGE plpgsql;

-- Function to retrieve the last notification details for a reader
DROP FUNCTION IF EXISTS GetLastNotificationDetails(integer);

CREATE OR REPLACE FUNCTION GetLastNotificationDetails(reader_id INT)
RETURNS TABLE (Message_ TEXT, SentDate DATE, IsRead BOOLEAN) AS $$
BEGIN
    RETURN QUERY
    SELECT Notifications.Message AS Message_, Notifications.SentDate, Notifications.IsRead
    FROM Notifications
    WHERE ReaderID = reader_id
    ORDER BY SentDate DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate the average books borrowed by card type
DROP FUNCTION IF EXISTS GetAverageBooksByCardType(text);

CREATE OR REPLACE FUNCTION GetAverageBooksByCardType(card_type TEXT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT AVG(BooksBorrowed)
        FROM (
            SELECT COUNT(b.LoanID) AS BooksBorrowed
            FROM ReaderCard rc
            LEFT JOIN BooksOnLoan b ON rc.ReaderID = b.ReaderID
            WHERE rc.CardType = card_type
            GROUP BY rc.ReaderID
        ) AS BorrowCounts
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get family books borrowed
DROP FUNCTION IF EXISTS GetFamilyBooksBorrowed(integer);

CREATE OR REPLACE FUNCTION GetFamilyBooksBorrowed(reader_id INT)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(bol.LoanID)
        FROM FamilyTies ft
        LEFT JOIN BooksOnLoan bol ON ft.RelatedReaderID = bol.ReaderID
        WHERE ft.ReaderID = reader_id OR ft.RelatedReaderID = reader_id
    );
END;
$$ LANGUAGE plpgsql;
