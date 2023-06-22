import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_date" : "06-14",
"start_phase" : "Cou",
"start_yr" : "24",
"end_date" : "06-20",
"end_phase" : "Cou",
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

line_end = pd.read_excel(params["line.end"] + phases.get(params.get("end_phase")) + "/1. Line Item Reports/line_items_2023-"+ params.get("end_date") + ".xlsx", sheet_name = "Details")
if params.get("start_phase") != params.get("end_phase") :
  line_end = line_end.drop(["FY24 " + params.get("end_phase").upper()], axis = 1)
else:
  pass

try:
  print("Columns are the same for both files: ")
  assert(line_start.columns.all() == line_end.columns.all())
  print(line_start.columns.all() == line_end.columns.all())
except AssertionError as msg:
  print(msg)
  
# baps = pd.read_excel("inputs/FY22 Actuals BAPS.xlsx")
# bpfs = pd.read_excel("inputs/FY22 Actuals BPFS.xlsx")
# 
# cols = list(baps)
# 
# result = baps.merge(bpfs, how = "outer", indicator = True, on = cols, suffixes = ("BAPS", "BPFS"))
# output = result.loc[lambda x : x['_merge'] != 'both']
# output["Phase"] = output["_merge"].replace({"left_only":"BAPS", "right_only":"BPFS"})
# output = output.drop(labels = ["_merge"], axis = 1)
# 
# label = output.pop("Phase")
# output.insert(0, "Phase", label)
# output = output.sort_values(by = ["Agency ID", "Service ID", "Activity ID", "Fund ID", "Object ID", "Subobject ID"])


##compare ================= 
cols = list(line_start.columns)
try:
  result = line_start.merge(line_end, how = "outer", indicator = True, on = cols, suffixes = (params.get("start_phase"), params.get("end_phase")))
  print("All good.")
except KeyError as e:
  if str(e) == "FY24 PROP":
    line_end = line_end.rename(columns = {"FY24 Proposal":"FY24 PROP"})
    result = line_start.merge(line_end, how = "outer", indicator = True, on = cols, suffixes = (params.get("start_phase"), params.get("end_phase")))
  else:
    print(e)
  
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
print("FinRec Starting Total: ", line_start["FY24 FINREC"].sum(), "FinRec Ending Total: ", line_end["FY24 FINREC"].sum(), "\n", "Difference of: ", line_end["FY24 FINREC"].sum()- line_start["FY24 FINREC"].sum())
print("BoE Starting Total: ", line_start["FY24 BOE"].sum(), "BoE Ending Total: ", line_end["FY24 BOE"].sum(), "\n", "Difference of: ", line_end["FY24 BOE"].sum()- line_start["FY24 BOE"].sum())
print("COU Starting Total: ", line_start["FY24 COU"].sum(), "COU Ending Total: ", line_end["FY24 COU"].sum(), "\n", "Difference of: ", line_end["FY24 COU"].sum()- line_start["FY24 COU"].sum())

##export =======
if params.get("start_phase") == params.get("end_phase"):
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/1. Line Item Reports/Line Item Change Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " " + params.get("start_date") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + " " + params.get("end_date") + ".xlsx", sheet_name = params.get("start_phase") + params.get("start_date") + " - " + params.get("end_phase") + params.get("end_date"), index = False)
else:
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/1. Line Item Reports/Line Item Change Reports/Line Item Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + ".xlsx", sheet_name = params.get("start_phase") + " - " + params.get("end_phase"), index = False)
