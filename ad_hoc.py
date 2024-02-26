open_budget = pd.read_excel(r"G:\Analyst Folders\Sara Brumfield\planning_year\open_budget_v2\OpenBaltimore FY24.xlsx", sheet_name = "Sheet 1")
open_budget = open_budget[open_budget["FY24 Budget"] != 0]

columns_to_drop = [col for col in open_budget.columns if col.endswith('Name')]
open_budget = open_budget.drop(columns = columns_to_drop)

bpfs = pd.read_excel(r"G:\Fiscal Years\Fiscal 2024\Planning Year\6. Council\1. Line Item Reports\line_items_2023-06-23.xlsx", sheet_name = "Details")

bpfs = bpfs[["Agency ID", "Program ID", "Activity ID", "Subactivity ID", "Fund ID", "DetailedFund ID", "Object ID", "Subobject ID", "Objective ID", "FY24 COU"]]

bpfs.rename(columns ={"FY24 COU":"FY24 Budget", "Program ID":"Service ID", "DetailedFund ID":"Detailed Fund ID"}, inplace = True)

bpfs = bpfs[bpfs["Fund ID"] != 2000]
bpfs = bpfs[bpfs["FY24 Budget"] != 0]

cols = list(bpfs.columns)
try:
  result = bpfs.merge(open_budget, how = "outer", indicator = True, on = cols, suffixes = ("BPFS", "OpenBudget"))
  print("All good.")
except KeyError as e:
    print(e)
  
output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"BPFS", "right_only":"OpenBudget"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["Agency ID", "Service ID", "Activity ID", "Fund ID", "Detailed Fund ID", "Object ID", "Subobject ID"])

output.to_excel("G:\Analyst Folders\Sara Brumfield\planning_year\open_budget_v2\FY24 BPFS vs OpenBudget.xlsx", index = False)
