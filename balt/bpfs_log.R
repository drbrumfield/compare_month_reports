library(janitor)


log <- import("C:/Users/sara.brumfield2/Downloads/Position_Move_Audit.xlsx") %>%
  mutate(old_cls_rec_status = as.numeric(old_cls_rec_status),
         new_cls_rec_status = as.numeric(new_cls_rec_status),
         old_proposal1_rec_status = as.numeric(old_proposal1_rec_status),
         new_proposal1_rec_status = as.numeric(new_proposal1_rec_status),
         old_tls_rec_status = as.numeric(old_tls_rec_status),
         new_tls_rec_status = as.numeric(new_tls_rec_status),
         date = lubridate::as_date(transaction_date))

job_number <- log %>%
  group_by(job_number) %>%
  summarise(count = n())

phase <- log %>%
  group_by(job_number) %>%
  summarise(start = min(date),
            end = max(date),
            old_cls_rec_status = sum(old_cls_rec_status, na.rm = TRUE),
            new_cls_rec_status = sum(new_cls_rec_status, na.rm = TRUE),
            old_proposal1_rec_status = sum(old_proposal1_rec_status, na.rm = TRUE),
            new_proposal1_rec_status = sum(new_proposal1_rec_status, na.rm = TRUE),
            old_tls_rec_status = sum(old_tls_rec_status, na.rm = TRUE),
            new_tls_rec_status = sum(new_tls_rec_status, na.rm = TRUE)) %>%
  adorn_totals(where = c("row", "col")) %>%
  filter(Total %% 2 != 0 & start != end)


mar_2 <- log %>%
  filter(date > "2023-03-02")


william <- log %>%
  filter(date > "2023-03-02" & owner == "wkyei")

export_excel(william, "WK Mar Changes", "BPFS Changes by William after Mar 1.xlsx")
  group_by(job_number) %>%
  summarise(start = min(date),
            end = max(date)) %>%
  filter((start == lubridate::as_date("2023-03-06") | end == lubridate::as_date("2023-03-06")) )
  
act_19 <- log %>%
  filter(program_id == 788 & activity_id == 19)

t_code <- log