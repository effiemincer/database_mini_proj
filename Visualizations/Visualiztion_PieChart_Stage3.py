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


query = """
SELECT 
    CardType, COUNT(*) AS Count
FROM ReaderCard
GROUP BY CardType;
"""

data = pd.read_sql_query(query, connection)
connection.close()

print(data.head())  # Display the fetched data

# Pie chart for card types
plt.figure(figsize=(8, 8))
plt.pie(data['count'], labels=data['cardtype'], autopct='%1.1f%%', startangle=140, colors=sns.color_palette("pastel"))
plt.title('Distribution of Card Types')
plt.savefig('card_types_pie_chart.png')  # Save the chart as an image
plt.show()


