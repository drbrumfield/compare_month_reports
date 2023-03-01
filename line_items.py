import pandas as pd
import numpy as np
from datetime import datetime
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_phase" : "TLS",
"start_yr" : 23,
"end_phase" : "TLS",
"end_yr" : 24,
"fy" : 24,
#most up-to-date line item or planning year
#verify with William for most current version
"line.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/line_items_2023-02-28.xlsx",
"line.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/line_items_2023-03-01.xlsx"}


##import ====
line_start = pd.read_excel(params["line.start"], sheet_name = "Details")

line_end = pd.read_excel(params["line.end"], sheet_name = "Details")
line_end = line_end.rename(columns = {"FY24 Proposal":"FY24 PROP"})

##compare ================= 
cols = list(line_start.columns)
result = line_start.merge(line_end, how = "outer", indicator = True, on = cols, suffixes = ("_TLS0228", "_TLS0301"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"TLS0228", "right_only":"TLS0301"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["Agency ID", "Program ID", "Activity ID", "Fund ID", "DetailedFund ID", "Object ID", "Subobject ID"])

##export =======
output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/Line Item Changes FY24 TLS 0228-FY24 TLS 0301.xlsx", sheet_name = "TLS to TLS", index = False, freeze_panes = (1,19))
