library(tidyverse)

election_data = read_csv("data/election-data-2020.csv") %>%
  rbind(read_csv("data/election-data-2024.csv"))

write_csv(election_data, "data/election-data-mn.csv")

employment = read_csv("data/unemployment-mn.csv") %>% filter(
  Year != "P : Preliminary"
)

colnames(employment) <- c("Year", "Month", "LF", "E", "U", "UR", "County")

employment <- employment %>% mutate(
  Year = as.numeric(Year),
  LF = as.numeric(LF),
  E = as.numeric(E),
  U = as.numeric(U),
  ER = E/LF*100,
  UR = as.numeric(UR)
) %>% filter(Year >= 2016) %>% na.omit()

employment$State = "MN"

employment$County <- employment$County %>% sapply(function(c){
  county <- c %>% str_split(" County, MN") %>% .[[1]] %>% .[1]
  ifelse(county == "Lac qui Parle", "Lac Qui Parle", county)
})

write_csv(employment, "data/employment-mn.csv")
