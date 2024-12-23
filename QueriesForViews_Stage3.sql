-- This query retrieves information about overdue loans, including the number of days each loan is overdue.
-- It is useful for library staff to identify and prioritize follow-up actions on overdue loans.
-- The results are ordered by the number of days overdue in descending order.
SELECT 
    LoanID, ReaderID, BookID, LoanDate, DueDate, 
    (CURRENT_DATE - DueDate) AS DaysOverdue 
FROM OverdueLoansView 
ORDER BY DaysOverdue DESC;


-- This query retrieves information about electronic card holders, including the number of days left until their card expires.
-- It is useful for library staff to notify readers about upcoming expirations and encourage them to renew their cards.
-- The results are ordered by the number of days left until expiration in ascending order.
SELECT 
    CardID, ReaderID, ExpirationDate, 
    (ExpirationDate - CURRENT_DATE) AS DaysLeft 
FROM ElectronicCardHoldersView 
ORDER BY DaysLeft ASC;


-- This query retrieves information about family ties between readers, including the type of relationship.
-- It is useful for library staff to understand family connections among readers, which can be helpful for family-oriented services and programs.
-- The results are ordered by ReaderID and RelatedReaderID.
SELECT 
    TieID, ReaderID, RelatedReaderID, RelationType 
FROM FamilyChildTiesView 
ORDER BY ReaderID, RelatedReaderID;


-- This query retrieves information about unread notifications sent to readers, including the number of days since the notification was sent.
-- It is useful for library staff to identify and follow up on unread notifications to ensure readers are aware of important messages.
-- The results are ordered by the number of days since the notification was sent in descending order.
SELECT 
    NotificationID, ReaderID, Message, SentDate, 
    (CURRENT_DATE - SentDate) AS DaysUnseen 
FROM UnreadNotificationsView 
ORDER BY DaysUnseen DESC;
