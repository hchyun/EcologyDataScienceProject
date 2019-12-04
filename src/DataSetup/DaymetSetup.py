"""
The script is to set up Daymet data used for this project. The data must be downloaded separetly
"""

import pandas as pd
from netCDF4 import Dataset

def extract_climate_month(array, start, end, func):
    climate_values = []
    for a in array:
        data = a[start+1:end+1]
        for i, d in enumerate(data):
            if d == -9999:
                data[i] = 0
        climate_values.append(func(data))
    return climate_values

def mean(arr):
    return sum(arr)/len(arr)

directory = "data"
file_base = "stnsxval"
file_type = "nc4"

climate_vars = {"tmax": [212, 242, max],"prcp" : [151, 180, sum, 181, 211], "tmin": [0, 31, min]}

for climate in climate_vars:
    print(climate)
    df_total = pd.DataFrame()
    for year in range(2000, 2016):
        filename = "{}/daymet_v3_{}_{}_{}.{}".format(directory,file_base,climate,year,file_type)
        data = Dataset(filename, mode='r')
        lon = data.variables['stn_lon'][:]
        lat = data.variables['stn_lat'][:]
        climate_data = data.variables['obs'][:].data
        parameters = climate_vars[climate]
        climate_vals = extract_climate_month(climate_data, parameters[0], parameters[1], parameters[2])
        df = pd.DataFrame({'lon':lon, 'lat':lat, climate: climate_vals})
        if len(parameters) > 3:
            climate_vals = extract_climate_month(climate_data, parameters[3], parameters[4], parameters[2])
            df_ = pd.DataFrame({'lon':lon, 'lat':lat, climate:climate_vals})
            df = df.append(df_)
        df['year'] = year
        df_total = df_total.append(df)
        data.close()
    print("Writing")
    df_total.to_csv("{}.csv".format(climate), index=False)