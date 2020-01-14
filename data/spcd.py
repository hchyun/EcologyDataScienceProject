import csv
import sqlite3

#name of fia data
database = 'fia.sqlite'
conn = sqlite3.connect(database)
cursor = conn.cursor()

sql = 'SELECT spcd, common_name FROM forest_inventory_analysis_species order by spcd'

cursor.execute(sql)
row = cursor.fetchall()


#Writing query to a csv file
with open('spcd.csv', 'w') as fp:
        a = csv.writer(fp, delimiter=',')
        a.writerow([i[0] for i in cursor.description])
        a.writerows(row)

cursor.close()