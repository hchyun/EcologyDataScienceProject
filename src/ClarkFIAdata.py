import csv
import pandas as pd
import sqlite3

database = 'fia.sqlite'
conn = sqlite3.connect(database)

sql = "SELECT STATECD, unitcd, plot, lat, lon,  AVG(STDAGE) as stand_age as statecd FROM forest_inventory_analysis_COND WHERE STDAGE IS NOT NULL OR STDAGE != '' GROUP BY COUNTYCD, STATECD"
fia = pd.read_sql_query(sql, conn)

csv_input = pd.read_csv('data/FIA_Counties_db.csv')

new_csv = pd.merge(csv_input, fia, on=["unitcd", "statecd"], how='left')
stand_age = new_csv["stand_age"]

new_csv.to_csv('data/FIA_Counties_db2.csv', index=False)

conn.close()
