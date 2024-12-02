-- Indicies
-- Supports efficient joins between Readers and ReaderCard.
CREATE INDEX idx_reader_card_readerid
ON ReaderCard (ReaderID);

-- Optimizes the workflow between loans and returns for books.
CREATE INDEX idx_booksreturned_loanid
ON BooksReturned (LoanID);

-- Enhances access to notifications, especially for recent or date-based queries.
CREATE INDEX idx_notifications_sentdate
ON Notifications (SentDate DESC);

-- Enables fast lookups, sorting, and aggregation of notifications based on ReaderID.
CREATE INDEX idx_notifications_readerid_sentdate
ON Notifications (ReaderID, SentDate DESC);

-- Speeds up joins and efficiently retrieves the most recent LoanDate for each ReaderID.
CREATE INDEX idx_booksonloan_readerid_loandate
ON BooksOnLoan (ReaderID, LoanDate DESC);

-----------------------------------------------------------------------------------------------------------------

-- Constraints.sql: Additional Constraints and Validation Queries

-- 1. Additional Constraints for Readers Table
ALTER TABLE Readers
ADD CONSTRAINT chk_phone_number 
CHECK (
    PhoneNumber ~ '^((\+?\d{1,3}|001)[-. ]?)?(\(\d{3}\)|\d{3})[-. ]?\d{3}[-. ]?\d{4}(x\d+)?$'
),
ADD CONSTRAINT unique_reader_contact 
UNIQUE (FirstName, LastName, PhoneNumber);

-- 2. Additional Constraints for FamilyTies Table
ALTER TABLE FamilyTies
ADD CONSTRAINT chk_different_readers 
CHECK (ReaderID != RelatedReaderID),
ADD CONSTRAINT valid_family_relation
CHECK (RelationType IN ('Parent', 'Child', 'Spouse', 'Sibling')),
ADD CONSTRAINT unique_family_tie
UNIQUE (ReaderID, RelatedReaderID);

-- 3. Additional Constraints for ReaderCard Table
ALTER TABLE ReaderCard
ADD CONSTRAINT unique_reader_card 
UNIQUE (ReaderID, CardType);

-- 4. Additional Constraints for BooksOnLoan Table
ALTER TABLE BooksOnLoan
ADD CONSTRAINT chk_loan_dates 
CHECK (LoanDate <= DueDate);

-- 5. Additional Constraints for BooksReturned Table
ALTER TABLE BooksReturned
ADD CONSTRAINT chk_conditionOnReturn
CHECK (ConditionOnReturn IN ('Excellent', 'Good', 'Fair', 'Poor', 'Damaged'));

-- Test Queries for Constraint Violations

-- 1. Readers Table Constraints
-- A. Attempt to insert invalid phone number
INSERT INTO Readers (FirstName, LastName, Address, PhoneNumber) 
VALUES ('John', 'Doe', '123 Main St', 'invalid');

-- B. Attempt to insert duplicate contact
INSERT INTO Readers (FirstName, LastName, Address, PhoneNumber) 
VALUES ('John', 'Doe', '456 Elm St', '+19234567890');
INSERT INTO Readers (FirstName, LastName, Address, PhoneNumber) 
VALUES ('John', 'Doe', '456 Elm St', '+19234567890');

-- 2. FamilyTies Constraints
-- A. Attempt to create a family tie with same reader
INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType)
VALUES (1, 1, 'Sibling');

-- B. Attempt to create a family tie with invalid relation type
INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType)
VALUES (19, 55, 'Sister');

-- C. Attempt to create duplicate family tie
INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType)
VALUES (230, 2, 'Sibling');
INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType)
VALUES (230, 2, 'Sibling');

-- 3. ReaderCard Constraints
-- A. Attempt to insert expired card
INSERT INTO ReaderCard (ReaderID, CardType, ExpirationDate)
VALUES (1, 'Electronic', '2023-01-01');

-- B. Attempt to create multiple cards of same type
INSERT INTO ReaderCard (ReaderID, CardType, ExpirationDate)
VALUES (1, 'Electronic', CURRENT_DATE + INTERVAL '1 year');

-- 4. BooksOnLoan Constraints
-- A. Attempt to create loan with invalid date range
INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate)
VALUES (1, 100, CURRENT_DATE + INTERVAL '1 day', CURRENT_DATE);


-- 5. BooksReturned Constraints
-- A. Attempt to return book with invalid condition
INSERT INTO BooksReturned (LoanID, ConditionOnReturn, ReturnDate)
VALUES (1, 'Gross', CURRENT_DATE);


-- UPDATE Constraint Violation Tests

-- 1. Readers Table - Invalid Phone Number Update
UPDATE Readers 
SET PhoneNumber = 'invalid' 
WHERE ReaderID = 1;

-- 2. FamilyTies - Attempt to Update to Self-Referencing Tie
UPDATE FamilyTies 
SET RelatedReaderID = ReaderID 
WHERE TieID = 1;

-- 3. BooksOnLoan - Invalid Date Update
UPDATE BooksOnLoan 
SET DueDate = LoanDate - INTERVAL '1 day' 
WHERE LoanID = 1;

-- 4. BooksReturned - Invalid Condition Update
UPDATE BooksReturned 
SET ConditionOnReturn = 'Destroyed' 
WHERE ReturnID = 1;

-- DELETE Constraint Impact Tests

-- 1. Delete Reader with Active Loans
DELETE FROM Readers 
WHERE ReaderID = 1;

-- 2. Delete Reader with Family Ties
DELETE FROM Readers 
WHERE ReaderID = 2;

-- 3. Delete Book Loan with Existing Return
DELETE FROM BooksOnLoan 
WHERE LoanID = 1;

-- 4. Attempt to Break Referential Integrity
DELETE FROM Readers 
WHERE ReaderID NOT IN (
    SELECT DISTINCT ReaderID FROM BooksOnLoan
    UNION
    SELECT DISTINCT ReaderID FROM Notifications
);