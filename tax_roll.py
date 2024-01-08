import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

angie = pd.read_excel(r"C:\Users\sbrumfield\Downloads\2023 Tax Roll Report.xlsx", sheet_name = "Sheet1")
sql = pd.read_excel(r"C:\Users\sbrumfield\OneDrive - Howard County\Documents\Munis\2023 Tax Roll.xlsx", sheet_name = "Sheet1")

##make sure columns match before joining
cols = list(angie.columns)

sql = sql[cols]

##make sure data types in columns match before joining
for i in sql.columns:
  if sql[f'{i}'].dtype != angie[f'{i}'].dtype:
    sql[f'{i}'] = sql[f'{i}'].astype(angie[f'{i}'].dtype)
    print(i, "data types don't match.")
  else:
    pass
    

try:
  result = angie.merge(sql, how = "outer", indicator = True, on = cols, suffixes = ("Angie", "SQL"))
  print("All good.")
except KeyError as e:
    print(e)
    
output = result.copy()
output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"Angie", "right_only":"SQL"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["Agency", "Service", "Fund", "Object", "Spend Category"])

output.to_excel("outputs/FY25 Line Item Comparison 11-29 to 11-30.xlsx", index = False)
