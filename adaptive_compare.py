import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

old = pd.read_excel(r"C:\Users\sara.brumfield2\Downloads\FY25 Proposal Line Items 11-29.xlsx", sheet_name = "Report Data")
old.drop(columns=["FY2023 Actuals", "FY2024 Actuals"], inplace = True)
new = pd.read_excel(r"C:\Users\sara.brumfield2\Downloads\FY25 Proposal Line Items 11-30.xlsx", sheet_name = "Report Data")
new.drop(columns=["FY2023 Actuals", "FY2024 Actuals"], inplace = True)

cols = list(new.columns)

old = old[cols]

try:
  result = new.merge(old, how = "outer", indicator = True, on = cols, suffixes = ("New", "Old"))
  print("All good.")
except KeyError as e:
    print(e)
    
# output = result.copy()
output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"New", "right_only":"Old"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["Agency", "Service", "Fund", "Object", "Spend Category"])

output.to_excel("outputs/FY25 Line Item Comparison 11-29 to 11-30.xlsx", index = False)
