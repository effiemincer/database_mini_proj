CREATE TABLE Readers (
    ReaderID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Address TEXT NOT NULL,
    PhoneNumber VARCHAR(25)
);

CREATE TABLE Notifications (
    NotificationID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    Message TEXT NOT NULL,
    SentDate DATE NOT NULL,
    IsRead BOOLEAN NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

CREATE TABLE ReaderCard (
    CardID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    CardType VARCHAR(20) CHECK (CardType IN ('Electronic', 'Physical')),
    ExpirationDate DATE NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

CREATE TABLE BooksOnLoan (
    LoanID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    ID INT NOT NULL,                --> book ID
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);

CREATE TABLE BooksReturned (
    ReturnID SERIAL PRIMARY KEY,
    LoanID INT NOT NULL,
    ConditionOnReturn TEXT NOT NULL,
    ReturnDate DATE NOT NULL,
    FOREIGN KEY (LoanID) REFERENCES BooksOnLoan(LoanID) ON DELETE CASCADE
);

CREATE TABLE Book (
    ISBN INT UNIQUE NOT NULL,
    Description INT NOT NULL,
    Format INT NOT NULL,
    PageCount INT NOT NULL,
    Title INT NOT NULL,
    ID INT PRIMARY KEY NOT NULL,
    ReleaseDate INT NOT NULL
);

CREATE TABLE Location (
    Condition INT NOT NULL,
    Quantity INT NOT NULL,
    Floor INT NOT NULL,
    Shelf INT NOT NULL,
    LocationID INT PRIMARY KEY NOT NULL,
    ID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES Book(ID)
);

CREATE TABLE Author (
    AuthorID INT PRIMARY KEY NOT NULL,
    FirstName INT NOT NULL,
    LastName INT NOT NULL,
    Biography INT,
    DateOfBirth INT NOT NULL
);

CREATE TABLE Genre (
    GenreID INT PRIMARY KEY NOT NULL,
    Description INT,
    Name INT NOT NULL
);

CREATE TABLE Publisher (
    PhoneNumber INT UNIQUE NOT NULL,
    PublisherID INT PRIMARY KEY NOT NULL,
    Name INT NOT NULL,
    Website INT
);

CREATE TABLE Country (
    CountryID INT PRIMARY KEY NOT NULL,
    Name INT NOT NULL
);

CREATE TABLE WrittenBy (
    ID INT NOT NULL,
    AuthorID INT NOT NULL,
    PRIMARY KEY (ID, AuthorID),
    FOREIGN KEY (ID) REFERENCES Book(ID),
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

CREATE TABLE TypeOf (
    ID INT NOT NULL,
    GenreID INT NOT NULL,
    PRIMARY KEY (ID, GenreID),
    FOREIGN KEY (ID) REFERENCES Book(ID),
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

CREATE TABLE PublishedBy (
    ID INT NOT NULL,
    PublisherID INT NOT NULL,
    PRIMARY KEY (ID, PublisherID),
    FOREIGN KEY (ID) REFERENCES Book(ID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);

CREATE TABLE IsIn (
    PublisherID INT NOT NULL,
    CountryID INT NOT NULL,
    PRIMARY KEY (PublisherID, CountryID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID),
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

CREATE TABLE FamilyTies(
    TieID SERIAL PRIMARY KEY,
    ReaderID INT NOT NULL,
    RelatedReaderID INT NOT NULL,
    RelationType VARCHAR(8) CHECK (RelationType IN ('Parent', 'Child', 'Spouse', 'Sibling')),
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE,
    FOREIGN KEY (RelatedReaderID) REFERENCES Readers(ReaderID) ON DELETE CASCADE
);
