library(tidyverse)

election_data = read_csv("data/election-data-2020.csv") %>%
  rbind(read_csv("data/election-data-2024.csv"))

write_csv(election_data, "data/election-data-mn.csv")

unemployment = read_csv("data/unemployment-mn.csv") %>% filter(
  Year != "P : Preliminary"
)

colnames(unemployment) <- c("Year", "Month", "LF", "E", "U", "UR", "County")

unemployment <- unemployment %>% mutate(
  Year = as.numeric(Year),
  LF = as.numeric(LF),
  U = as.numeric(U),
  UR = as.numeric(UR)
) %>% filter(Year >= 2016) %>% na.omit()

unemployment$State = "MN"

unemployment$County <- unemployment$County %>% sapply(function(c){
  c %>% str_split(" County, MN") %>% .[[1]] %>% .[1]
})

write_csv(unemployment, "data/unemployment-mn.csv")
