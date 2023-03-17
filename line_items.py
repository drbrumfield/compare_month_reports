import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_date" : "03-16",
"start_phase" : "TLS",
"start_yr" : "24",
"end_date" : "03-17",
"end_phase" : "TLS",
"end_yr" : "24",
"fy" : "24",
"yr" : "23", #calendar year for file names
#most up-to-date line item or planning year
#verify with William for most current version
"line.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/",
"line.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/"}

phases = {"CLS" : "1. CLS",
"Prop" : "2. Prop",
"TLS" : "3. TLS",
"FinRec" : "4. FinRec",
"BoE" : "5. BoE",
"Cou" : "6. Council"}

##import ====
line_start = pd.read_excel(params["line.start"] + phases.get(params.get("start_phase")) + "/1. Line Item Reports/line_items_2023-" + params.get("start_date") + ".xlsx", sheet_name = "Details")
# line_start = line_start.drop(["FY24 TLS"], axis = 1)

line_end = pd.read_excel(params["line.end"] + phases.get(params.get("end_phase")) + "/1. Line Item Reports/line_items_2023-"+ params.get("end_date") + ".xlsx", sheet_name = "Details")
##if different phases
# line_end = line_end.rename(columns = {"FY24 Proposal":"FY24 PROP"})
# line_end = line_end.drop(["FY24 TLS"], axis = 1)

try:
  assert line_start.columns == line_end.columns
except AssertionError as msg:
  print(msg)

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
print("CLS Starting Total: ", line_start["FY24 CLS"].sum(), "CLS Ending Total: ", line_end["FY24 CLS"].sum(), "\n", "Difference of: ", line_end["FY24 CLS"].sum()- line_start["FY24 CLS"].sum())
print("Proposal Starting Total: ", line_start["FY24 PROP"].sum(), "Proposal Ending Total: ", line_end["FY24 PROP"].sum(), "\n", "Difference of: ", line_end["FY24 PROP"].sum()- line_start["FY24 PROP"].sum())
print("TLS Starting Total: ", line_start["FY24 TLS"].sum(), "TLS Ending Total: ", line_end["FY24 TLS"].sum(), "\n", "Difference of: ", line_end["FY24 TLS"].sum()- line_start["FY24 TLS"].sum())

##export =======
if params.get("start_phase") == params.get("end_phase"):
  output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/1. Line Item Reports/Line Item Change Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " " + params.get("start_date") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + " " + params.get("end_date") + ".xlsx", sheet_name = params.get("start_phase") + params.get("start_date") + " - " + params.get("end_phase") + params.get("end_date"), index = False)
else:
  output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/1. Line Item Reports/Line Item Change Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + ".xlsx", sheet_name = params.get("start_phase") + " - " + params.get("end_phase")," index = False)
