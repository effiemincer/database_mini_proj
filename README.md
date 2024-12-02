# database_mini_proj
Mini project for Database systems


# Stage 1

# ERD
![ERD](https://github.com/user-attachments/assets/07aa464f-10e5-4968-a0fc-585dcc354261)

### *Why These Entities Were Chosen*

1. *Readers*:
   - Represents the primary users of the library system. All interactions, including loans, notifications, and relationships, are centered around readers. The entity ensures each reader is uniquely identifiable with attributes like ReaderID and PhoneNumber.

2. *FamilyTies*:
   - Allows the library to establish and track family-based relationships between readers. This is particularly useful for family-oriented libraries that offer shared memberships, discounts, or policies based on familial connections (e.g., parental borrowing limits for children).

3. *ReaderCard*:
   - Captures the details of library cards issued to readers. Including attributes like ExpirationDate ensures that card usage is valid and allows the library to send reminders for renewal or deactivation of expired cards.

4. *Books*:
   - Represents the library's inventory, ensuring that every book is uniquely identifiable. Attributes like ISBN and Genre allow efficient categorization and retrieval.

5. *BooksOnLoan*:
   - Tracks active loans, connecting specific readers to borrowed books. Attributes like LoanDate and DueDate allow the library to monitor borrowing periods and assess overdue penalties.

6. *BooksReturned*:
   - Captures return-related details, including the condition of the book and the date of return. This ensures proper inventory management and accountability for damages.

7. *Notifications*:
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

6. *What Parts Are Not Covered*:
   - Notifications currently do not include automation logic (e.g., generating notifications based on due dates or card expiration). This could be added later as part of a task scheduler or trigger system.
   - Advanced notification categories (e.g., promotional messages) are not part of the current implementation but could be added as an attribute.


# DSD
![image (3)](https://github.com/user-attachments/assets/d723f5ab-8abb-48d4-b187-5df511ac8272)

# pg_dump
pg_dump -U postgres -h localhost -d "Mini Project" > MiniProjectDump.sql
Screenshots of the dump:
![image](https://github.com/user-attachments/assets/7fb5832f-ee11-4314-bea3-0591a2e70494)
![image](https://github.com/user-attachments/assets/b8016182-b651-40e2-bc54-02d06790b8a7)



# Stage 2
## Backup
Run these commands in windows powershell as Administrator:

*Command for SQL backup:* Measure-Command {pg_dump -U postgres -h localhost -d "Mini Project" --file=backupSQL.sql --verbose --clean --if-exists 2> backupSQL.log}

*Command for PSQL backup:* Measure-Command {pg_dump -U postgres -h localhost -d "Mini Project" --file=backupPSQL.sql --verbose --clean --if-exists -F c 2> backupPSQL.log}

*Command for PSQL Restore:* Measure-Command {pg_restore -U postgres -h localhost -v -d "Mini Project" -F c --if-exists --clean backupPSQL.SQL 2> restorePSQL.log}

The files with timing information is stored in the folder titled: "Backup for Stage 2".

## Indexes
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

### *Summary of Indices*
1. **idx_reader_card_readerid**: Supports efficient joins between Readers and ReaderCard.
2. **idx_booksreturned_loanid**: Optimizes the workflow between loans and returns for books.
3. **idx_notifications_sentdate**: Enhances access to notifications, especially for recent or date-based queries.

These indices are designed to address the key relationships and patterns inherent in your database design, ensuring better performance across typical operations. Let me know if you'd like to tailor these further!



## Constraints

To see Constraints see the file Constraints.sql. 

To see Tests done on the restraints as well as errors thrown see the file ConstraintsErrorMessages.log. For a summary of the inputs and outputs, see below.

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
