import pandas as pd
import numpy as np
from datetime import datetime
import openpyxl

#engine = "pyxlsb" not working / convert to xlsx first
nov = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/6.1. November FY 2023.xlsx", sheet_name = "TAB_REALPROP_11072022")
jan = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/7.1 January FY 2023.xlsx", sheet_name = "TAB_REALPROP_01062023")

start = nov[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]
end = jan[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]

start = start[start["PIN"].notnull()]
end = end[end["PIN"].notnull()]

cols = list(start.columns)
result = start.merge(end, indicator = True, how = 'outer', on = cols, suffixes = ("_Nov", "_Jan"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Month"] = output["_merge"].replace({"left_only":"Nov", "right_only":"Jan"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Month")
output.insert(0, "Month", label)
output = output.sort_values(by = ["PIN", "BLOCKLOT"])

output.to_excel("outputs/Real Property Revenue_FY23 Nov-Jan.xlsx", sheet_name = "Nov - Jan", index = False, freeze_panes = (1,2))
