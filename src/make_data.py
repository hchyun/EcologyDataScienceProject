import csv
import pandas as pd
import sqlite3
import numpy as np
import os
import sys
import math

database = '../fia.sqlite'
conn = sqlite3.connect(database)

sql = "SELECT plott.statecd, plott.unitcd, plott.countycd, plott.plot, lat, lon, AVG(slope), AVG(aspect), MAX(elev) FROM forest_inventory_analysis_COND as cond JOIN forest_inventory_analysis_PLOT as plott ON cond.statecd == plott.statecd AND cond.unitcd == plott.unitcd AND cond.countycd == plott.countycd AND cond.plot == plott.plot WHERE slope != '' AND elev != '' AND aspect != '' GROUP BY plott.statecd, plott.unitcd, plott.countycd, plott.plot"
fia_climate = pd.read_sql_query(sql, conn)

#Getting all predictor values
Neon_Domain3 = pd.read_csv("../data/domain3.csv")
bioclim = pd.read_csv("../data/bioclim_fia.csv")
bioclim.drop('Unnamed: 0', axis=1, inplace=True)

sql = "SELECT COUNT(*) ,spcd, statecd, unitcd, countycd, plot, invyr FROM forest_inventory_analysis_TREE GROUP BY spcd, statecd, unitcd, countycd, plot"
fia_response = pd.read_sql_query(sql, conn)
conn.close()

'''
@param 
df: the left data frame
df2: the right data frame
merge: the colunms to merge the data frames
join_kind: type of join on the two data frames (left, inner, right, outer)
@return 
final_df: a data frame that is a combination of the two data frames
'''
def format_predictors(df, df2=None, merge=["statecd","unitcd","countycd","plot"], join_kind="left"):
    df.columns = map(str.lower, df.columns)
    if(df2.equals(None)):
        #merging all of the duplicate rows
        final_df = df.groupby(merge, as_index=False).mean()
    else:
        #renaming columns to lowercase
        df2.columns = map(str.lower, df2.columns)
        final_df = pd.merge(df, df2, on=merge, how=join_kind)
        final_df = final_df.groupby(merge, as_index=False).mean()
        #adding primary key for the plots
        final_df['id_coords'] = final_df.apply(lambda row: str(int(row.statecd)) + '_' + str(int(row.unitcd)) + '_' + str(int(row.countycd)) + '_' + str(int(row[3])), axis=1)
        #for duplicate lat and lon in the data frames dropping one of them and renaming the other
    if "lat_x" in final_df.columns:
        final_df.drop(["lat_y", "lon_y"], axis=1, inplace=True)
        final_df.rename(columns={"lat_x":"lat","lon_x":"lon"},inplace=True)
    return final_df

neon_domain3 = format_predictors(Neon_Domain3, fia_climate)
neon_climate = format_predictors(neon_domain3, bioclim)
cont_climate = format_predictors(fia_climate,bioclim)

neon_climate.to_csv('../data/neon_climate.csv', index=False)
cont_climate.to_csv('../data/cont_climate.csv',index=False)
fia_response.to_csv('../data/fia_response.csv',index=False)