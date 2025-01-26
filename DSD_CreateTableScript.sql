CREATE TABLE Readers (
    Address INT NOT NULL,
    ReaderID INT PRIMARY KEY NOT NULL,
    FirstName INT NOT NULL,
    LastName INT NOT NULL,
    PhoneNumber INT NOT NULL
);

CREATE TABLE Notifications (
    NotificationID INT PRIMARY KEY NOT NULL,
    Message INT NOT NULL,
    SentDate INT NOT NULL,
    IsRead INT NOT NULL,
    ReaderID INT NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID)
);

CREATE TABLE ReadCard (
    CardID INT PRIMARY KEY NOT NULL,
    CardType INT NOT NULL,
    ExpirationDate INT NOT NULL,
    ReaderID INT NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID)
);

CREATE TABLE BooksOnLoan (
    LoanID INT PRIMARY KEY NOT NULL,
    LoanDate INT NOT NULL,
    DueDate INT NOT NULL,
    ReaderID INT NOT NULL,
    ID INT NOT NULL,
    ReturnID INT NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (ID) REFERENCES Book(ID),
    FOREIGN KEY (ReturnID) REFERENCES BooksReturned(ReturnID)
);

CREATE TABLE BooksReturned (
    ReturnID INT PRIMARY KEY NOT NULL,
    ReturnDate INT NOT NULL,
    ConditionOnReturn INT NOT NULL
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

CREATE TABLE FamilyRelationship (
    ReaderID INT NOT NULL,
    RelatedReaderID INT NOT NULL,
    TieID INT PRIMARY KEY NOT NULL,
    RelationshipType TEXT NOT NULL,
    FOREIGN KEY (ReaderID) REFERENCES Readers(ReaderID),
    FOREIGN KEY (RelatedReaderID) REFERENCES Readers(ReaderID)
);
