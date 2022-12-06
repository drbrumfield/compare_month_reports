import pandas as pd
import numpy as np
from datetime import datetime
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_phase" : "Adopted",
"start_yr" : 23,
"end_phase" : "CLS",
"end_yr" : 24,
"fy" : 24,
#most up-to-date line item and position files for planning year
#verify with William for most current version
"line.start" : "G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_Change_Tables.xlsx",
"line.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-11-2_CLS FINAL AFTER BPFS.xlsx",
"position.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/2. Position Reports/PositionsSalariesOPCs_2022-11-30.xlsx",
"position.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/2. Position Reports/PositionsSalariesOpcs_2022-11-2b_CLS FINAL AFTER BPFS.xlsx"}

position_start = pd.read_excel(params["position.start"], sheet_name = "PositionsSalariesOPCs")
position_start = position_start.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_start = position_start.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_start = position_start.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_start = position_start.loc[:, "JOB NUMBER":"TOTAL COST"]
position_start = position_start.infer_objects()
# position_start["JOB NUMBER"] = position_start["JOB NUMBER"].astype("Int64")

# start_cols = list(position_start.columns)

# start_ID_cols = [s for s in start_cols if s.endswith("ID")]

position_end = pd.read_excel(params["position.end"], sheet_name = "PositionsSalariesOPCs")
position_end = position_end.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_end = position_end.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_end = position_end.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_end = position_end.loc[:, "JOB NUMBER":"TOTAL COST"]
position_end = position_end.infer_objects()
# position_end["JOB NUMBER"] = position_end["JOB NUMBER"].astype("Int64")

##add empty dummy rows to get same # of rows
x = len(position_start)
y = len(position_end)


##test comparability
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

cols = list(position_start.columns)
result = position_start.merge(position_end, indicator = True, how = 'outer', on = ['JOB NUMBER', 'CLASSIFICATION ID', 'CLASSIFICATION NAME', 'GRADE',
       'UNION ID', 'UNION NAME', 'AGENCY ID', 'AGENCY NAME', 'PROGRAM ID',
       'PROGRAM NAME', 'ACTIVITY ID', 'ACTIVITY NAME', 'FUND ID', 'FUND NAME',
       'DETAILED FUND ID', 'DETAILED FUND NAME', 'SI ID', 'SI ID NAME',
       'STATUS', 'SALARY', 'OSO 201', 'OSO 202', 'OSO 203', 'OSO 205',
       'OSO 210', 'OSO 212', 'OSO 213', 'OSO 231', 'OSO 233', 'OSO 235',
       'TOTAL COST'], suffixes = ("_CLs", "_Proposal"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"CLS", "right_only":"Proposal"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["AGENCY ID", "JOB NUMBER"])

output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/2. Position Reports/Position Changes FY24 CLS-FY24 Prop.xlsx", sheet_name = "CLS to Prop", index = False, freeze_panes = (1,2))

