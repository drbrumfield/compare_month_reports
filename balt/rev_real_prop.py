import pandas as pd
import numpy as np
from datetime import datetime
import openpyxl

#engine = "pyxlsb" not working / convert to xlsx first
start = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/12. June 2023.xlsx", sheet_name = "TAB_REALPROP_06012023")
end = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2024/1. July 2024.xlsx", sheet_name = "TAB_REALPROP_07012024")

start = start[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]
end = end[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]

start = start[start["PIN"].notnull()]
end = end[end["PIN"].notnull()]

cols = list(start.columns)
result = start.merge(end, indicator = True, how = 'outer', on = cols, suffixes = ("_start", "_end"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Month"] = output["_merge"].replace({"left_only":"Start", "right_only":"End"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Month")
output.insert(0, "Month", label)
output = output.sort_values(by = ["PIN", "BLOCKLOT"])

output.to_excel("outputs/Real Property Revenue_FY24 Jun-Jul.xlsx", sheet_name = "Nov - Jan", index = False, freeze_panes = (1,2))
