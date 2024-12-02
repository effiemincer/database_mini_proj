-- Table for Readers
CREATE TABLE Readers (
    ReaderID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Address TEXT NOT NULL,
    PhoneNumber VARCHAR(25)
);

-- Table for FamilyTies
CREATE TABLE FamilyTies (
    TieID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    RelatedReaderID INT NOT NULL,
    RelationType VARCHAR(8) CHECK (RelationType IN ('Parent', 'Child', 'Spouse', 'Sibling')),
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (RelatedReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

-- Table for ReaderCard
CREATE TABLE ReaderCard (
    CardID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    CardType VARCHAR(20) CHECK (CardType IN ('Electronic', 'Physical')),
    ExpirationDate DATE NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

-- Table for BooksOnLoan
CREATE TABLE BooksOnLoan (
    LoanID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    BookID INT NOT NULL,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

-- Table for BooksReturned
CREATE TABLE BooksReturned (
    ReturnID SERIAL PRIMARY KEY,
    LoanID INT NOT NULL,
    ConditionOnReturn TEXT NOT NULL,
    ReturnDate DATE NOT NULL,
    FOREIGN KEY (LoanID) REFERENCES BooksOnLoan(LoanID) ON DELETE CASCADE
);

-- Table for Notifications
CREATE TABLE Notifications (
    NotificationID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    Message TEXT NOT NULL,
    SentDate DATE NOT NULL,
    IsRead BOOLEAN NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);
