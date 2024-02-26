# Comparing files
This repo contains R and Python code developed to compare Finance-related files of the same structure. This is often a point-in-time comparison. The subfolder "balt" includes code developed for Baltimore City's Department of Finance.
- assessment.py compares last year's Munis report for assessments and exemptions with a recreated SQL query to show differences between the two Excel files. It outputs an Excel file with differences by row.
- crystal_compare.R compares the Scanline report extracted from Munis using Crystal Reports against the Scanline report extracted using Python. It uses the package compareR to generated a dataframe and/or file output of differences by row.
