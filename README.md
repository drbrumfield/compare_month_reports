# Comparing files
This repo contains R and Python code developed to compare Finance-related files of the same structure. This is often a point-in-time comparison. The subfolder "balt" includes code developed for Baltimore City's Department of Finance.
- assessment.py compares last year's Munis report for assessments and exemptions with a recreated SQL query to show differences between the two Excel files. It outputs an Excel file with differences by row.
- compareR.R is a sandbox for testing different comparison libraries for R. Similar libraries do not exist for Python.
- crystal_compare.R compares the Scanline report extracted from Munis using Crystal Reports against the Scanline report extracted using Python. It uses the package compareR to generated a dataframe and/or file output of differences by row.
- SDAT_SQL_Comparison.R compares monthly SDAT files (rlfile14.zip --> PublicData14) with columns broken out by PDR layout. This code requires the package compareR to generated a dataframe and/or file output of differences by row.
- tax_roll.py compares last year's Munis report for the County tax roll with a recreated SQL query to show differences between the two Excel files. It outputs an Excel file with differences by row.
