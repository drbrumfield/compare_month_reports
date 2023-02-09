import pandas as pd
import numpy as np
from datetime import datetime
from pandas.testing import assert_frame_equal

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_phase" : "Prop",
"start_yr" : 23,
"end_phase" : "TLS",
"end_yr" : 24,
"fy" : 24,
#most up-to-date position files for planning year
"position.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/PositionsSalariesOpcs_2023-02-03_TLS.xlsx",
"position.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/PositionsSalariesOpcs_2023-02-07_TLS_After_Positions_Update.xlsx"}

##positions =======

position_start = pd.read_excel(params["position.start"], sheet_name = "PositionsSalariesOPCs")
position_start = position_start.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_start = position_start.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_start = position_start.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_start = position_start.loc[:, "JOB NUMBER":"TOTAL COST"]
position_start = position_start.infer_objects()


# applying whitespace_remover function on dataframe
# def whitespace_remover(df):
  # for i in df.columns:
  #   if df[i].dtype == "object":
  #     df[i] = df[i].astype(str).apply(lambda x: x.strip())
  #   else:
  #     pass
  # return df
# whitespace_remover(position_start)

position_end = pd.read_excel(params["position.end"], sheet_name = "PositionsSalariesOPCs")
position_end = position_end.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_end = position_end.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_end = position_end.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_end = position_end.loc[:, "JOB NUMBER":"TOTAL COST"]
position_end = position_end.infer_objects()

# whitespace_remover(position_end)

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
result = position_start.merge(position_end, how = "outer", indicator = True, on = cols, suffixes = ("_TLSBefore", "_TLSAfter"))

output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"TLSBefore", "right_only":"TLSAfter"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["JOB NUMBER"])

#duplicate check
no_phase = output.drop(columns = ["Phase"])
test = no_phase.drop_duplicates(subset = ['JOB NUMBER', 'CLASSIFICATION ID', 'CLASSIFICATION NAME', 'GRADE', 'UNION ID', 'UNION NAME', 'AGENCY ID', 'AGENCY NAME', 'PROGRAM ID', 'PROGRAM NAME', 'ACTIVITY ID', 'ACTIVITY NAME', 'FUND ID', 'FUND NAME', 'DETAILED FUND ID', 'DETAILED FUND NAME', 'SI ID', 'SI ID NAME', 'STATUS', 'SALARY', 'OSO 201', 'OSO 202', 'OSO 203', 'OSO 205', 'OSO 210', 'OSO 212', 'OSO 213', 'OSO 231', 'OSO 233', 'OSO 235', 'TOTAL COST'], keep = False, inplace = True)
test = no_phase.loc[no_phase.duplicated()==True]


##export ============
output.to_excel("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/AllPosition Changes FY24 TLSBefore-FY24 TLSAfter.xlsx", sheet_name = "TLS to TLS", index = False, freeze_panes = (1,2))

