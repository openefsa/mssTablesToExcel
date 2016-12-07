tidyDF <- function() {

dfs=mssTablesToExcel::extractTables("./044312_Dinotefuran_Apple_Draft_Dul_RCK_June_7_2016.xml")


columns <- dfs[[3]] %>%
  head(2) %>%
  t() %>%
  tbl_df() %>%
  slice(2:n()) %>%
  select(1,2) %>%
  mutate(V=paste0("V",1:n()))


long_df <- dfs[[3]]  %>%
  tbl_df() %>%
  slice(3:n()) %>%
  gather(key,value,V1:V14) %>%
  left_join(columns,by=c("key"="V"))


tidy_df <- long_df %>%
  select(-key) %>%
  mutate(value=as.numeric(value)) %>%
  select(value,everything())



}

