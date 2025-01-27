from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

# Generate sample data for FamilyTies
with open("booksOnLoan", "w") as file:
    loanDates = []
    dueDates = []

    # Generate sample data for BooksOnLoan
    with open("booksOnLoan.sql", "w") as file:
        # loans that were fulfilled (will have the loanID in BooksReturned)
        for _ in range(50000):  
            readerID = random.randint(1, 33333)
            bookID = random.randint(0, 100000)
            loanDate = fake.date_between(start_date='-15y', end_date='-1m')
            loanDates.append(loanDate)
            dueDate = loanDate + timedelta(weeks=4)
            dueDates.append(dueDate)
            file.write(f"INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate) "
                    f"VALUES ('{readerID}', '{bookID}', '{loanDate}', '{dueDate}');\n")

        # all loans are still outstanding, some will be overdue
        for _ in range(10000):  
            readerID = random.randint(1, 33333)
            bookID = random.randint(1, 100000)
            loanDate = fake.date_between(start_date='-1y', end_date='today')
            dueDate = loanDate + timedelta(weeks=4)
            dueDates.append(dueDate)
            file.write(f"INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate) "
                    f"VALUES ('{readerID}', '{bookID}', '{loanDate}', '{dueDate}');\n")
            
        # all loans are still outstanding, some will be overdue
        for _ in range(40000):  
            readerID = random.randint(1, 33333)
            bookID = random.randint(1, 100000)
            loanDate = fake.date_between(start_date='-4w', end_date='today')
            dueDate = loanDate + timedelta(weeks=4)
            dueDates.append(dueDate)
            file.write(f"INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, DueDate) "
                    f"VALUES ('{readerID}', '{bookID}', '{loanDate}', '{dueDate}');\n")