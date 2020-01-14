import pandas as pd
import sqlite3
import numpy as np
import os
import sys
import math

#Database obtained from FIA website
database = '../fia.sqlite'
conn = sqlite3.connect(database)

sql="""SELECT plott.statecd, plott.unitcd, plott.countycd, plott.plot, lat, lon, slope, aspect, elev, CARBON_SOIL_ORG, plott.watercd, cond.PHYSCLCD, cond.invyr
    FROM (SELECT * FROM forest_inventory_analysis_COND GROUP BY statecd, unitcd, countycd, plot, invyr) cond
    JOIN
    (SELECT statecd, unitcd, countycd, plot, MAX(invyr) AS invyr, lat, lon, elev, watercd FROM forest_inventory_analysis_PLOT
    WHERE statecd < 60 GROUP BY statecd, countycd, plot) as plott
    ON cond.statecd == plott.statecd AND cond.unitcd == plott.unitcd AND cond.countycd == plott.countycd
    AND cond.plot == plott.plot AND cond.invyr == plott.invyr
    WHERE slope != '' AND elev != '' AND aspect != '' AND CARBON_SOIL_ORG != '' AND plott.watercd != ''
    AND cond.PHYSCLCD != ''
    """
fia_climate = pd.read_sql_query(sql, conn)

sql ="""SELECT spcq.ct, spcq.spcd, spcq.statecd, spcq.unitcd, spcq.countycd, spcq.plot, spcq.invyr FROM
    (SELECT COUNT(*) as ct,spcd, statecd, unitcd, countycd, plot, invyr
    FROM forest_inventory_analysis_TREE WHERE statecd < 60 and statuscd == 1
    and subp BETWEEN 1 and 4
    GROUP BY statecd, unitcd, countycd, plot, invyr, spcd
    HAVING COUNT(DISTINCT subp) == 4) spcq
    JOIN
    (SELECT statecd, unitcd, countycd, plot, MAX(invyr) as invyr
    FROM forest_inventory_analysis_PLOT WHERE statecd < 60
    GROUP BY statecd, unitcd, countycd, plot) AS myrq
    ON spcq.statecd == myrq.statecd AND spcq.unitcd == myrq.unitcd AND spcq.countycd == myrq.countycd AND myrq.plot == spcq.plot
    AND spcq.invyr == myrq.invyr
    """
fia_response = pd.read_sql_query(sql, conn)

conn.close()

cont_climate = format_predictors(fia_climate)

cont_climate.to_csv('../data/climate_fia.csv',index=False)
fia_response.to_csv('../data/response_fia.csv',index=False)
