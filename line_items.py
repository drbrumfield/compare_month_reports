import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_date" : "03-06",
"start_phase" : "Prop",
"start_yr" : "24",
"end_date" : "03-07",
"end_phase" : "TLS",
"end_yr" : "24",
"fy" : "24",
#most up-to-date line item or planning year
#verify with William for most current version
"line.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/line_items_2023-",
"line.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/line_items_2023-"}


##import ====
line_start = pd.read_excel(params["line.start"] + params.get("start_date") + ".xlsx", sheet_name = "Details")

line_end = pd.read_excel(params["line.end"] + params.get("end_date") + ".xlsx", sheet_name = "Details")
line_end = line_end.rename(columns = {"FY24 PROP":"FY24 Proposal"})
line_end = line_end.drop(["FY24 TLS"], axis = 1)

##compare ================= 
cols = list(line_start.columns)
result = line_start.merge(line_end, how = "outer", indicator = True, on = cols, suffixes = (params.get("start_phase"), params.get("end_phase")))

output = result.loc[lambda x : x['_merge'] != 'both']

if params.get("start_phase") == params.get("end_phase"):
  output["Phase"] = output["_merge"].replace({"left_only":params.get("start_phase") + params.get("start_date"), "right_only":params.get("end_phase") + params.get("end_date")})
else:
  output["Phase"] = output["_merge"].replace({"left_only":params.get("start_phase"), "right_only":params.get("end_phase")})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["Agency ID", "Program ID", "Activity ID", "Fund ID", "DetailedFund ID", "Object ID", "Subobject ID"])

##totals check =====
print(line_start["FY24 CLS"].sum())
print(line_end["FY24 CLS"].sum())
print(line_start["FY24 Proposal"].sum())
print(line_end["FY24 Proposal"].sum())

##export =======
if params.get("start_phase") == params.get("end_phase"):
  output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + params.get("start_date") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + params.get("end_date") + ".xlsx", sheet_name = params.get("start_phase") + params.get("start_date") + " - " + params.get("end_phase") + params.get("end_date"), index = False, freeze_panes = (1,19))
else:
  output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/1. Line Item Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + ".xlsx", sheet_name = params.get("start_phase") + " - " + params.get("end_phase")," index = False, freeze_panes = (1,19))
