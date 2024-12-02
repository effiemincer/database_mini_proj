# database_mini_proj
Mini project for Database systems


# Stage 1

# ERD
![image](https://github.com/user-attachments/assets/7ea9b400-9193-4dca-854a-fdfc6a8af3b3)



### *Why These Entities Were Chosen*

1. *Readers*:
   - Represents the primary users of the library system. All interactions, including loans, notifications, and relationships, are centered around readers. The entity ensures each reader is uniquely identifiable by ReaderID.

2. *FamilyTies*:
   - Allows the library to establish and track family-based relationships between readers. This is particularly useful for family-oriented libraries that offer shared memberships, discounts, or policies based on familial connections (e.g., parental borrowing limits for children).

3. *ReaderCard*:
   - Captures the details of library cards issued to readers. Including attributes like ExpirationDate ensures that card usage is valid and allows the library to send reminders for renewal or deactivation of expired cards.

4. *BooksOnLoan*:
   - Tracks active loans, connecting specific readers to borrowed books. Attributes like LoanDate and DueDate allow the library to monitor borrowing periods and assess overdue penalties.

5. *BooksReturned*:
   - Captures return-related details, including the condition of the book and the date of return. This ensures proper inventory management and accountability for damages.

6. *Notifications*:
   - Central to the library’s communication system, Notifications tracks messages sent to readers. Notifications are used for:
     - Reminders about upcoming due dates for books.
     - Alerts about expired or expiring library cards.
     - General updates or announcements (e.g., new book arrivals).
   - Attributes like SentDate and IsRead ensure each notification is traceable and its status is tracked for better user engagement.

---

### *How the Design Was Built*

1. *Use Cases*:
   - *Readers*: Track user details for issuing loans, notifications, and library card management.
   - *FamilyTies*: Provide support for libraries with family-based borrowing privileges or discounts.
   - *ReaderCard*: Enable both physical and electronic access to library services, ensuring cards remain valid via expiration tracking.
   - *Books and Loans*: Allow seamless tracking of which books are borrowed, by whom, and when they are due or returned.
   - *Notifications*: Automate and track communication with readers, ensuring timely updates about their accounts and loans.

2. *Target Users*:
   - *Library Staff*: For managing books, loans, returns, and issuing cards.
   - *Readers*: For viewing their loan history, managing notifications, and using library cards.
   - *Library Management*: For maintaining accountability and ensuring compliance with borrowing policies.

3. *Normalization (3NF)*:
   - The design follows strict normalization rules:
     - Each entity is unique and stores only attributes directly related to it.
     - Relationships are properly represented using join tables (e.g., FamilyTies).
     - All attributes are atomic and depend only on the primary key of their respective entities.

4. *Notifications Integration*:
   - The Notifications entity is linked to the Readers entity through the "Notified" relationship.
   - Each notification is uniquely identified using NotificationID and captures:
     - *Who*: The ReaderID associated with the notification.
     - *What*: The Message content of the notification.
     - *When*: The SentDate of the notification.
     - *Status*: Whether the notification has been read (IsRead).

5. *Why Notifications Matter*:
   - Ensures proactive communication, reducing overdue books and keeping readers engaged.
   - Provides accountability by logging sent notifications and their read status.


# DSD
![image (3)](https://github.com/user-attachments/assets/d723f5ab-8abb-48d4-b187-5df511ac8272)

# SQL File Reflecting Database Build
The file titled DB1.sql has our database schema and build.

# Data Population Script and SQL Files
[Link to the folder with the population script and population sql files](https://github.com/effiemincer/database_mini_proj/tree/main/Population%20Script%20and%20Files)

# pg_dump
### pg_dump command: 
   pg_dump -U postgres -h localhost -d "Mini Project" > [MiniProjectDump.sql](https://github.com/effiemincer/database_mini_proj/blob/main/MiniProjectDump.sql)
   
Screenshots of the dump:
![image](https://github.com/user-attachments/assets/7fb5832f-ee11-4314-bea3-0591a2e70494)
![image](https://github.com/user-attachments/assets/b8016182-b651-40e2-bc54-02d06790b8a7)



# Stage 2
## Backup
Run these commands in windows powershell:

*Command for SQL backup:* Measure-Command {pg_dump -U postgres -h localhost -d "Mini Project" --file=backupSQL.sql --verbose --clean --if-exists 2> backupSQL.log}

*Command for PSQL backup:* Measure-Command {pg_dump -U postgres -h localhost -d "Mini Project" --file=backupPSQL.sql --verbose --clean --if-exists -F c 2> backupPSQL.log}

*Command for PSQL Restore:* Measure-Command {pg_restore -U postgres -h localhost -v -d "Mini Project" -F c --if-exists --clean backupPSQL.SQL 2> restorePSQL.log}

The files with timing information is stored in the folder titled: ["Backup for Stage 2"](https://github.com/effiemincer/database_mini_proj/tree/main/Backup%20for%20Stage%202).

![WhatsApp Image 2024-12-02 at 17 15 43_e289a98e](https://github.com/user-attachments/assets/f13a1715-7b19-4f43-96fc-b5613efce293)


## Queries
Any query or parameterized query that returned tables are stored as csv files in [Query Responses](https://github.com/effiemincer/database_mini_proj/tree/main/Query%20Responses). Responses that are just a message are commented in the sql file underneath the query.

![WhatsApp Image 2024-12-02 at 17 13 50_76a35d22](https://github.com/user-attachments/assets/0653f90d-1da0-43bc-aa86-6b6483f8a723)


Here are the queries in our own words, they are all available in full with timing information in [Queries.sql](https://github.com/effiemincer/database_mini_proj/blob/main/Queries.sql):
1. Retrieve a list of all readers along with the total number of books they have ever borrowed.
2. Find the last notification sent to each reader and its status.
3. Calculate the average number of books borrowed by readers for each card type ('Electronic' or 'Physical').
4. Retrieve a list of readers along with the number of their family members and the total number of books borrowed by their family members.
5. Update unread notifications older than a month to indicate follow-up is needed.
6. Extend the return date for all overdue loans by 14 days.
7. Delete all loan records with a ReturnDate older than one year.
8. Remove a specific reader from the system (and cascade delete related loans).

## Parameterized Queries
Any query or parameterized query that returned tables are stored as csv files in /Query Responses. Responses that are just a message are commented in the sql file underneath the query.

Here are the paramterized queries in our own words, they are all available in full with timing information in [ParamsQueries.sql](https://github.com/effiemincer/database_mini_proj/blob/main/ParamsQueries.sql):
1. Retrieve All Family Members for a Specific Reader.
2. Find Readers Who Borrowed More Than a Specified Number of Books Within a Date Range.
3. Update the expiration date of reader cards by extending them by one year for readers who have borrowed more than a specified number of books within the last year.
4. Delete readers who have not borrowed any books in the last x years.

## Indexes
The create queries for the above indices are stored in [Constraints.sql](https://github.com/effiemincer/database_mini_proj/blob/main/Constraints.sql).

### *Index 1: Optimize Reader and ReaderCard Relationships*
*Purpose*: Enhance performance for operations that join Readers and ReaderCard tables. This relationship is fundamental since every reader has an associated card.

sql
CREATE INDEX idx_reader_card_readerid
ON ReaderCard (ReaderID);


*Reason*:
- ReaderID in ReaderCard is frequently used for joining with the Readers table.
- This index ensures quick access to all cards associated with a specific reader.

---

### *Index 2: Optimize Book Borrowing and Returning Workflow*
*Purpose*: Support operations linking BooksOnLoan and BooksReturned. Since the loan and return tables are tightly coupled, efficient lookups between them are essential.

sql
CREATE INDEX idx_booksreturned_loanid
ON BooksReturned (LoanID);


*Reason*:
- LoanID is the foreign key linking BooksReturned and BooksOnLoan.
- This index optimizes queries that need to retrieve return records for a specific loan or join these two tables.

---

### *Index 3: Optimize Notifications for Recent Activity*
*Purpose*: Facilitate efficient access to notifications based on SentDate. Notifications are typically accessed in chronological order or filtered by date ranges.

sql
CREATE INDEX idx_notifications_sentdate
ON Notifications (SentDate DESC);


*Reason*:
- Sorting or filtering notifications by SentDate is a common use case.
- This index enables efficient retrieval of recent notifications without needing to scan the entire table.

---

### *Index 4: Optimize Notifications for Reader-Specific Lookups and Recent Activity*

sql
CREATE INDEX idx_notifications_readerid_sentdate
ON Notifications (ReaderID, SentDate DESC);

*Reason*:
- This index optimizes queries by enabling fast lookups, sorting, and aggregation of notifications based on ReaderID and the most recent SentDate.

---

### *Index 5: Optimize Book Loan Activity and Inactive Reader Filtering*

sql
CREATE INDEX idx_booksonloan_readerid_loandate
ON BooksOnLoan (ReaderID, LoanDate DESC);

*Reason*:
- This index speeds up joins and efficiently retrieves the most recent LoanDate for each ReaderID to optimize filtering inactive readers.

---

### *Summary of Indices*
1. **idx_reader_card_readerid**: Supports efficient joins between Readers and ReaderCard.
2. **idx_booksreturned_loanid**: Optimizes the workflow between loans and returns for books.
3. **idx_notifications_sentdate**: Enhances access to notifications, especially for recent or date-based queries.
4. **idx_notifications_readerid_sentdate**: Enables fast lookups, sorting, and aggregation of notifications based on ReaderID.
5. **idx_booksonloan_readerid_loandate**: Speeds up joins and efficiently retrieves the most recent LoanDate for each ReaderID.


## Constraints

To see Constraints see the file [Constraints.sql](https://github.com/effiemincer/database_mini_proj/blob/main/Constraints.sql). 

To see Tests done on the restraints as well as errors thrown see the file [ConstraintsErrorMessages.log](https://github.com/effiemincer/database_mini_proj/blob/main/ConstraintsErrorMessages.log). 

![WhatsApp Image 2024-12-02 at 17 39 36_a2b8ca57](https://github.com/user-attachments/assets/bea7f139-c143-46aa-a4eb-090aa22973be)

For a summary of the inputs and outputs, see below.

Here's a summary of the tests conducted along with the explanation of the errors thrown:

### **1. Readers Table Constraints**
#### **A. Invalid Phone Number Insertion**
- **Test**: Inserted a record with an invalid phone number.
- **Error**: Violates the `chk_phone_number` constraint, which ensures that the phone number follows a valid format.

#### **B. Duplicate Contact**
- **Test**: Inserted two identical records with the same name and phone number.
- **Error**: Violates the `unique_reader_contact` constraint, which enforces unique combinations of `FirstName`, `LastName`, and `PhoneNumber`.

---

### **2. FamilyTies Constraints**
#### **A. Self-Referencing Family Tie**
- **Test**: Attempted to create a family tie where a reader is related to themselves.
- **Error**: Violates the `chk_different_readers` constraint, which ensures `ReaderID` and `RelatedReaderID` are different.

#### **B. Invalid Relation Type**
- **Test**: Inserted a family tie with an invalid `RelationType` value.
- **Error**: Violates the `familyties_relationtype_check` constraint, which ensures `RelationType` contains predefined valid values.

#### **C. Duplicate Family Tie**
- **Test**: Inserted two identical family ties between the same `ReaderID` and `RelatedReaderID`.
- **Error**: Violates the `unique_family_relation` constraint, which prevents duplicate relationships.

---

### **3. ReaderCard Constraints**
#### **A. Expired Card**
- **Test**: Attempted to insert a card with an already expired `ExpirationDate`.
- **Error**: Not explicitly mentioned as invalid expiration date; error instead refers to a `unique_reader_card` constraint, possibly due to a pre-existing card of the same type.

#### **B. Multiple Cards of Same Type**
- **Test**: Inserted multiple cards of the same type for one reader.
- **Error**: Violates the `unique_reader_card` constraint, which ensures a reader can only have one card of each type.

---

### **4. BooksOnLoan Constraints**
#### **A. Invalid Date Range**
- **Test**: Created a loan where the `DueDate` is earlier than the `LoanDate`.
- **Error**: Violates the `chk_loan_dates` constraint, which ensures the `DueDate` is later than the `LoanDate`.

---

### **5. BooksReturned Constraints**
#### **A. Invalid Book Condition**
- **Test**: Returned a book with an invalid `ConditionOnReturn` value.
- **Error**: Violates the `chk_conditiononreturn` constraint, which restricts `ConditionOnReturn` to predefined acceptable values.

---

### **6. Update Constraint Violation Tests**
#### **Readers Table**
- **Test**: Updated a reader's phone number to an invalid value.
- **Error**: Violates the `chk_phone_number` constraint.

#### **FamilyTies**
- **Test**: Updated a family tie to make it self-referencing.
- **Error**: Violates the `chk_different_readers` constraint.

#### **BooksOnLoan**
- **Test**: Updated a loan record to have a `DueDate` earlier than `LoanDate`.
- **Error**: Violates the `chk_loan_dates` constraint.

#### **BooksReturned**
- **Test**: Updated the condition of a returned book to an invalid value.
- **Error**: Violates the `chk_conditiononreturn` constraint.

  Here is a screenshot of an example of a query that fails to follow our databases constraints.

  ![WhatsApp Image 2024-12-02 at 17 39 04_4f8eb440](https://github.com/user-attachments/assets/4f4bc2f2-8632-4756-a78c-a1701d83b176)

