import pandas as pd
import requests


def download_files(statecd):
    url = 'https://apps.fs.usda.gov/fia/datamart/CSV/{}_TREE.zip'.format(statecd)
    r = requests.get(url)
    with open('{}_TREE.zip'.format(statecd) , 'wb') as f:  
        f.write(r.content)
    url = 'https://apps.fs.usda.gov/fia/datamart/CSV/{}_PLOT.zip'.format(statecd)
    r = requests.get(url)
    with open('{}_PLOT.zip'.format(statecd) , 'wb') as f:  
        f.write(r.content)
    url = 'https://apps.fs.usda.gov/fia/datamart/CSV/{}_COND.zip'.format(statecd)
    r = requests.get(url)
    with open('{}_COND.zip'.format(statecd) , 'wb') as f:  
        f.write(r.content)

def get_last_year(plot, tree):
    design1 = tree.merge(plot, how='left', on=['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT', 'INVYR'])
    groups = design1.groupby(['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT'])
    
    final_df = pd.DataFrame(columns=["STATECD","UNITCD", "COUNTYCD", "PLOT", "SPCD", "COUNT", "INVYR"])
    for n, g in groups:
        small = g.loc[g.INVYR == g.INVYR.max()]
        small_agg = small.groupby(["STATECD","UNITCD", "COUNTYCD", "PLOT", "SPCD", "INVYR"]).SPCD.agg('count').to_frame('COUNT').reset_index()
        final_df = final_df.append(small_agg, sort=False)
    
    return final_df

def get_climate(cond, plot, data):
    cond_gb = cond.groupby(['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT'], as_index=False).mean()
    plot_gb = plot.groupby(['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT'], as_index=False).mean()
    me = pd.merge(df, cond_gb, how='left', on=['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT'])
    me = pd.merge(me, plot_gb, how='left', on=['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT'])
    me = me[['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT', 'INVYR_x', 'SLOPE', 'ASPECT', 'CARBON_SOIL_ORG', 'PHYSCLCD', 'LAT', 'LON', 'ELEV']]
    return me


def get_response(plot, tree):
    print("Calculating abundance", end=" ")
    tree = tree.loc[(tree.STATUSCD == 1) & (tree.INVYR >= 2015)]
    plot = plot.loc[(plot.DESIGNCD == 1) & (plot.INVYR >= 2015)]
    fia_response = get_last_year(plot, tree)
    print(fia_response.shape[0])
    return fia_response


if __name__ == "__main__":

    fia_response = pd.DataFrame()
    fia_climate = pd.DataFrame()


    state_codes = [
        'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL',
        'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA',
        'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE',
        'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK',
        'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT',
        'VA', 'WA', 'WV', 'WI', 'WY'
    ]

    for state in state_codes:
        print("Downloading", state)
        download_files(state)
        plot = pd.read_csv('{}_PLOT.zip'.format(state), usecols=['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT', 'DESIGNCD', 'INVYR'])
        tree = pd.read_csv('{}_TREE.zip'.format(state), usecols=['INVYR', 'STATECD', "UNITCD", "COUNTYCD", "PLOT", "SUBP", "TREE", "SPCD", "STATUSCD"])
        cond = pd.read_csv('{}_COND.zip'.format(state), usecols=['STATECD', 'UNITCD', 'COUNTYCD', 'PLOT', 'SLOPE', 'ASPECT', 'CARBON_SOIL_ORG', 'PHYSCLCD', 'INVYR'])
        fia_response = fia_response.append(get_response(plot, tree))
        data = tree.groupby(['UNITCD', 'COUNTYCD', 'PLOT'], as_index=False).mean()
        fia_climate = fia_climate.append(get_climate(cond, plot, data))
        os.remove('{}_PLOT.zip'.format(state))
        os.remove('{}_TREE.zip'.format(state))
        os.remove('{}_COND.zip'.format(state))


    print("writing files")
    fia_response.to_csv("../../data/response_fia.csv", index=False)
    fia_climate.to_csv("../../data/climate_fia.csv", index=False)

