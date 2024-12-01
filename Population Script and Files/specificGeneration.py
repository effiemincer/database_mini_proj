from faker import Faker
import random
from datetime import datetime, timedelta


RELATIONTPYE = ['Parent', 'Child', 'Spouse', 'Sibling']
# Generate sample data for FamilyTies
with open("familyTies.sql", "w") as file:
    for _ in range(10000):  
        readerID = random.randint(1, 33333) * 37 % 33333 + 1  # Randomly select a readerID
        relationReaderID = random.randint(1, 33333) * 37 % 33333 + 1
        while relationReaderID == readerID:
            relationReaderID = random.randint(1, 33333) * 2 % 33333 + 1
        relation = RELATIONTPYE[random.randint(0,3)]
        file.write(f"INSERT INTO FamilyTies (ReaderID, RelatedReaderID, RelationType) "
                   f"VALUES ('{readerID}', '{relationReaderID}', '{relation}');\n")