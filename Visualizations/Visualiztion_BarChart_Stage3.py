import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# PostgreSQL connection details
connection = psycopg2.connect(
    host="localhost",
    database="Mini Project",
    user="postgres",
    password="9990"
)

# Query: Count loans grouped by days overdue
query = """
SELECT 
    (CURRENT_DATE - DueDate) AS DaysOverdue, 
    COUNT(*) AS LoanCount
FROM OverdueLoansView
GROUP BY DaysOverdue
ORDER BY DaysOverdue DESC
LIMIT 25;
"""

# Fetch data into a Pandas DataFrame
data = pd.read_sql_query(query, connection)
connection.close()

print(data.head())  # Display the fetched data

# Bar chart for overdue loans grouped by days overdue
plt.figure(figsize=(12, 6))
sns.barplot(x='daysoverdue', y='loancount', data=data, palette='viridis')
plt.title('Number of Overdue Loans by Days Overdue')
plt.xlabel('Days Overdue')
plt.ylabel('Number of Loans')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig('overdue_loans_grouped_bar_chart.png')  # Save the chart as an image
plt.show()

