from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

# Generate sample data for Readers
with open("readers.sql", "w") as file:
    for _ in range(33333):
        first_name = fake.first_name()
        last_name = fake.last_name()
        address = fake.address().replace("\n", ", ")
        phone = fake.phone_number()
        file.write(f"INSERT INTO Readers (FirstName, LastName, Address, PhoneNumber) "
                   f"VALUES ('{first_name}', '{last_name}', '{address}', '{phone}');\n")


CARDTYPE = ['Physical', 'Electronic']
# Generate sample data for ReaderCard
with open("readerCard.sql", "w") as file:
    for _ in range(33333):  
        readerID = _ + 1
        cardType = CARDTYPE[random.randint(0,1)]
        expiryDate = fake.date_this_decade(before_today=True, after_today=True)
        file.write(f"INSERT INTO ReaderCard (ReaderID, CardType, ExpirationDate) "
                   f"VALUES ('{readerID}', '{cardType}', '{expiryDate}');\n")
        

RELATIONTPYE = ['Parent', 'Child', 'Spouse', 'Sibling']
# Generate sample data for FamilyTies
with open("familyTies.sql", "w") as file:
    for _ in range(10000):  
        readerID = random.randint(1, 33333) * 37 % 33333  # Randomly select a readerID
        relationReaderID = random.randint(1, 33333) * 37 % 33333
        while relationReaderID == readerID:
            relationReaderID = random.randint(1, 33333) * 2 % 33333
        relation = RELATIONTPYE[random.randint(0,3)]
        file.write(f"INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType) "
                   f"VALUES ('{readerID}', '{relationReaderID}', '{relation}');\n")

loanDates = []
returnDates = []

# Generate sample data for BooksOnLoan
with open("booksOnLoan.sql", "w") as file:
    # loans that were fulfilled (will have the loanID in BooksReturned)
    for _ in range(50000):  
        readerID = random.randint(1, 33333)
        bookID = random.randint(1, 100000)
        loanDate = fake.date_between(start_date='-15y', end_date='-1m')
        loanDates.append(loanDate)
        returnDate = loanDate + timedelta(weeks=4)
        returnDates.append(returnDate)
        file.write(f"INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, ReturnDate) "
                   f"VALUES ('{readerID}', '{bookID}', '{loanDate}', '{returnDate}');\n")
        
    
    # all loans are still outstanding
    for _ in range(50000):  
        readerID = random.randint(1, 33333)
        bookID = random.randint(1, 100000)
        loanDate = fake.date_between(start_date='-1m', end_date='today')
        returnDate = loanDate + timedelta(weeks=4)
        returnDates.append(returnDate)
        file.write(f"INSERT INTO BooksOnLoan (ReaderID, BookID, LoanDate, ReturnDate) "
                   f"VALUES ('{readerID}', '{bookID}', '{loanDate}', '{returnDate}');\n")
        
    
CONDITION = ['Excellent', 'Good', 'Fair', 'Poor', 'Damaged']
# Generate sample data for BooksReturned
with open("booksReturned.sql", "w") as file:
    # books that were on loan and are now returned (may be on loan again but now to a new reader)
    for _ in range(50000):  
        loanID = _ + 1
        conditionOnReturn = CONDITION[random.randint(0, 4)]
        startDate = loanDates[_]
        returnDate = fake.date_between(start_date=startDate, end_date='today')
        file.write(f"INSERT INTO BooksReturned (LoanID, ConditionOnReturn, ReturnDate) "
                   f"VALUES ('{loanID}', '{conditionOnReturn}', '{returnDate}');\n")
        


# Generate sample data for Notifications
with open("notifications.sql", "w") as file:
    # books that were on loan and are now returned (may be on loan again but now to a new reader)
    for _ in returnDates:
        if _ <= (datetime.today() + timedelta(weeks=1)).date():
            readerID = random.randint(1, 33333)
            message = "Your book is due in 1 week! Please return it on time."
            sentDate = _ - timedelta(weeks=1)
            isRead = fake.boolean(chance_of_getting_true=50)
            file.write(f"INSERT INTO Notifications (ReaderID, Message, SentDate, IsRead) "
                    f"VALUES ('{readerID}', '{message}', '{sentDate}', '{isRead}');\n")
        

        

