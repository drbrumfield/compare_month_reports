import pandas as pd
import numpy as np
from datetime import datetime

jul = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/1. July FY 2023.xlsb", sheet_name = "TAB_REALPROP1", engine = "pyxlsb")
nov = pd.read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/9. November FY 2023.xlsb", sheet_name = "TAB_REALPROP_11072022", engine = "pyxlsb")

start = jul[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]
end = nov[["PIN", "PINRELATE", "BLOCKLOT","BLOCK", "LOT","PERMHOME", "FULLCASH", "USEGROUP", "ARTAXBAS", "DISTSWCH", "DIST_ID","STATETAX", "CITY_TAX", "SALEDATE", "OWNER_1"]]

start = start[start["PIN"].notnull()]
end = end[end["PIN"].notnull()]

cols = list(start.columns)
result = start.merge(end, indicator = True, how = 'outer', on = cols, suffixes = ("_Jul", "_Nov"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Month"] = output["_merge"].replace({"left_only":"Jul", "right_only":"Nov"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Month")
output.insert(0, "Month", label)
output = output.sort_values(by = ["PIN", "BLOCKLOT"])

output.to_excel("outputs/Real Property Revenue_FY23 Jul-Nov.xlsx", sheet_name = "Jul to Nov", index = False, freeze_panes = (1,2))
