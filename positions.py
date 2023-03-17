import pandas as pd
import numpy as np
from datetime import datetime
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
#All positions or OPCs
params = {"type" : "All",
"tab" : "AllPositions",
"start_date" : "03-16_TLS",
"start_phase" : "TLS",
"start_yr" : "24",
"end_date" : "03-17",
"end_phase" : "TLS",
"end_yr" : "24",
"fy" : "24",
"yr" : "23", #calendar year for file names
#most up-to-date position files for planning year
"position.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/",
"position.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/"}

phases = {"CLS" : "1. CLS",
"Prop" : "2. Prop",
"TLS" : "3. TLS",
"FinRec" : "4. FinRec",
"BoE" : "5. BoE",
"Cou" : "6. Council"}

# applying whitespace_remover function on dataframe
def whitespace_remover(df):
  for i in df.columns:
    if df[i].dtype == "object":
      df[i] = df[i].astype(str).apply(lambda x: x.strip())
    else:
      pass
  return df

##positions =======
###start
if params.get("type") == "All":
  position_start = pd.read_excel(params["position.start"] + phases.get(params.get("start_phase")) + "/2. Position Reports/AllPositions_2023-" + params.get("start_date") + ".xlsx", sheet_name = params.get("tab"))
  position_start = position_start.drop_duplicates(subset = "JOB NUMBER", keep = "last")
  position_start = position_start.drop(['ADOPTED'], axis = 1)
  position_start.columns = position_start.columns.str.upper()
  position_start = position_start.rename(columns = {"BUDGETED SALARY ": "BUDGETED SALARY", "PROJECTED SALARY": "SALARY", "DETAILED FUND NAME ": "DETAILED FUND NAME", "JOB  NUMBER": "JOB NUMBER", "SI NAME":"SI ID NAME", "T CODE":"STATUS", "FY24 PROPOSAL" : "BUDGETED SALARY", "PORJECTED SALARY" : "SALARY", "TOTAL BUDGED COST" : "TOTAL COST"})
  position_start = position_start.infer_objects()
  position_start["GRADE"] = position_start["GRADE"].astype(str).str.pad(width=3, side='left', fillchar='0')
  whitespace_remover(position_start)

  
else:
  position_start = pd.read_excel(params["position.start"] + phases.get(params.get("start_phase")) + "/2. Position Reports/PositionsSalariesOPCs_2023-" + params.get("start_date") + ".xlsx", sheet_name = params.get("tab"))
  position_start = position_start.drop_duplicates(subset = "JOB NUMBER", keep = "last")
  position_start = position_start.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
  position_start = position_start.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
  position_start = position_start.loc[:, "JOB NUMBER":"TOTAL COST"]
  position_start = position_start.infer_objects()
  # position_start = position_start[position_start["Phase"]==params.get("start_phase")]
  # position_start = position_start.drop(["Phase"], axis = 1)
  position_start["GRADE"] = position_start["GRADE"].astype(str).str.pad(width=3, side='left', fillchar='0')
  whitespace_remover(position_start)
  position_start.columns = position_start.columns.str.upper()


###end
if params.get("type") == "All":
  position_end = pd.read_excel(params["position.end"]  + phases.get(params.get("end_phase")) + "/2. Position Reports/AllPositions_2023-" + params.get("end_date") + ".xlsx", sheet_name = params.get("tab"))
  position_end = position_end.drop_duplicates(subset = "JOB NUMBER", keep = "last")
  position_end = position_end.drop(['ADOPTED'], axis = 1)
  position_end.columns = position_end.columns.str.upper()
  position_end = position_end.rename(columns = {"BUDGETED SALARY ": "BUDGETED SALARY", "PROJECTED SALARY": "SALARY", "DETAILED FUND NAME ": "DETAILED FUND NAME", "JOB  NUMBER": "JOB NUMBER", "SI NAME":"SI ID NAME", "T CODE":"STATUS", "FY24 PROPOSAL" : "BUDGETED SALARY", "PORJECTED SALARY" : "SALARY", "TOTAL BUDGED COST" : "TOTAL COST"})
  position_end = position_end.infer_objects()
  position_end["GRADE"] = position_end["GRADE"].astype(str).str.pad(width=3, side='left', fillchar='0')
  whitespace_remover(position_end)
  
else:
  position_end = pd.read_excel(params["position.end"]  + phases.get(params.get("end_phase")) + "/2. Position Reports/PositionsSalariesOPCs_2023-" + params.get("end_date") + ".xlsx", sheet_name = params.get("tab"))
  position_end = position_end.drop_duplicates(subset = "JOB NUMBER", keep = "last")
  position_end = position_end.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
  position_end = position_end.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
  position_end = position_end.loc[:, "JOB NUMBER":"TOTAL COST"]
  position_end = position_end.infer_objects()
  position_end["GRADE"] = position_end["GRADE"].astype(str).str.pad(width=3, side='left', fillchar='0')
  whitespace_remover(position_end)
  position_end.columns = position_end.columns.str.upper()


##add empty dummy rows to get same # of rows ======
# x = len(position_start)
# y = len(position_end)


##test comparability ==============
# position_end = position_end.reindex(list(range(0, x))).reset_index(drop = True)
# 
# assert_frame_equal(position_start.reset_index(drop=True), position_end.reset_index(drop=True))
# 
# position_start.equals(position_end)
# 
##compare() function doesn't use unique ID, so takes df in whatever order the rows are in
# result = position_start.reset_index(drop=True).compare(position_end.reset_index(drop=True), align_axis = 1, result_names = ("CLS", "Proposal"))
# 
# output = result.replace(np.nan, None, regex = True)

##compare ================= 
cols = list(position_start.columns)
result = position_start.merge(position_end, how = "outer", indicator = True, on = cols, suffixes = (params.get("start_phase"), params.get("end_phase")))

output = result.loc[lambda x : x['_merge'] != 'both']

if params.get("start_phase") == params.get("end_phase"):
  output["Phase"] = output["_merge"].replace({"left_only":params.get("start_phase") + params.get("start_date"), "right_only":params.get("end_phase") + params.get("end_date")})
else:
  output["Phase"] = output["_merge"].replace({"left_only":params.get("start_phase"), "right_only":params.get("end_phase")})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["JOB NUMBER"])

#duplicate check
no_phase = output.drop(columns = ["Phase"])
# test = no_phase.drop_duplicates(subset = ['JOB NUMBER', 'CLASSIFICATION ID', 'CLASSIFICATION NAME', 'GRADE', 'UNION ID', 'UNION NAME', 'AGENCY ID', 'AGENCY NAME', 'PROGRAM ID', 'PROGRAM NAME', 'ACTIVITY ID', 'ACTIVITY NAME', 'FUND ID', 'FUND NAME', 'DETAILED FUND ID', 'DETAILED FUND NAME', 'SI ID', 'SI ID NAME', 'STATUS', 'SALARY', 'OSO 201', 'OSO 202', 'OSO 203', 'OSO 205', 'OSO 210', 'OSO 212', 'OSO 213', 'OSO 231', 'OSO 233', 'OSO 235', 'TOTAL COST'], keep = False, inplace = True)
test = no_phase.loc[no_phase.duplicated()==True]

if len(test) == 0:
  print("No duplicates found.")
else:
  print("Duplicates in data set.")


##export ============
if params.get("start_phase") == params.get("end_phase"):
  if params.get("type") == "All":
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/2. Position Reports/Position Change Reports/All Position Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + params.get("start_date") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + params.get("end_date") + ".xlsx", sheet_name = params.get("start_phase") + params.get("start_date") + " - " + params.get("end_phase") + params.get("end_date"), index = False)
  else:
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/2. Position Reports/Position Change Reports/Position Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + params.get("start_date") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + params.get("end_date") + ".xlsx", sheet_name = params.get("start_phase") + params.get("start_date") + " - " + params.get("end_phase") + params.get("end_date"), index = False)
else:
  if params.get("type") == "All":
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/2. Position Reports/Position Change Reports/All Position Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + ".xlsx", sheet_name = params.get("start_phase") + " - " + params.get("end_phase"), index = False)
  else:
    output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/" + phases.get(params.get("end_phase")) + "/2. Position Reports/Position Change Reports/Position Changes FY" + params.get("start_yr") + " " + params.get("start_phase") + " - FY" + params.get("end_yr") + " " + params.get("end_phase") + ".xlsx", sheet_name = params.get("start_phase") + " - " + params.get("end_phase"), index = False)

