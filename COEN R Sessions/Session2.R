#COEN R and RMarkdown Professional Development Series
#Session 2: Data Manipulation and Introduction to the tidyverse

#Fist Authored: 2/13/2021 Nicole Harty
#Last Updated: 3/06/2021 Nicole Harty

#Session Objectives
## Explain the purpose and function of key tidyverse packages (dplyr, lubridate, stringr, forcats, ggplot2)
## Author code to manipulate data using the pipe operator
## Generate summary statistics and aggregations using the tidyverse
## Perform common factor manipulations (reordering, collapsing factors) and work with strings (truncating, matching)
## Create new variables using criteria in the data using case_when and if_else


#Key tidyverse packages
##dplyr - it all starts here! data manipulation and wrangling; create new columns/variables, select columns, filter data, aggregations
  ##dplyr functions: SELECT = choose columns, FILTER = choose rows based upon criteria, MUTATE = create new column, SUMMARISE = aggregation
##lubridate - working with dates is tricky. lubridate makes it easier. work with date parts, durations, and intervals; calculate with dates
##stringr - manipulate string variables; identify substrings, parse a string, etc
##forcats - factors/categorical variables; coerce strings to factors, relevel or rename factors, collapse factors, etc
##ggplot2 - grammar of graphics for data visualization; start with a basic plot and add detail and layers


#First, load packages and dataset/s
library(openxlsx)
library(googlesheets4)
library(tidyverse)
library(lubridate)

SurveyXLSX <- read.xlsx("R Workshop (Responses).xlsx")
SurveyGSheetAPI <- read_sheet("https://docs.google.com/spreadsheets/d/17uyz1A90D6XgGKi_Qer-ssgkWRdPmKACEOHzk0FhjiI/edit#gid=790590919")


#Clean up the data frame - more usable column names, set data types
##change datetime column to be datetime
##2 ways to do the same thing
SurveyXLSX$Timestamp <- as.Date.numeric(SurveyXLSX$Timestamp, origin = "1899-12-30") #this gives just the DATE
SurveyXLSX$Timestamp <- as.POSIXct(SurveyXLSX$Timestamp) #Now we get the full timestamp

SurveyXLSX[,c(1)] <- as.Date.numeric(SurveyXLSX[,c(1)], origin = "1899-12-30")
SurveyXLSX[,c(1)] <- as.POSIXct(SurveyXLSX[,c(1)])


#the PIPE operator
#read the pipe as "AND THEN": "Take the SurveyXLSX data frame AND THEN select a few columns AND THEN filter to rows where column __ is ___"
SurveyXLSX %>%
  select(Timestamp) %>%
  filter(Timestamp > "2021-03-01")

#alternative, base R, no PIPE: read inside to outside parenthesis - UCK!
filter(select(SurveyXLSX, Timestamp), Timestamp > "2021-03-01")

##Change column names using RENAME function from DPLYR package (use Help window to look up function arguments)
SurveyXLSX <- SurveyXLSX %>%
  rename(SessionsAttend = `What.session(s).are.you.attending?.(Check.all.that.apply)`,
         ExperienceProgCode = `What.is.your.experience.with.programming/coding.(such.as.SQL,.SAS,.VBA,.or.complex.excel.functions)?`,
         ExperienceR = `What.is.your.level.of.experience.with.R?`,
         ExperienceDataNumeric = `What.is.your.level.of.experience.working.with.the.following.data.types?.[Numeric]`,
         ExperienceDataCategorical = `What.is.your.level.of.experience.working.with.the.following.data.types?.[Categorical]`,
         ExperienceDataFactor = `What.is.your.level.of.experience.working.with.the.following.data.types?.[Factor]`,
         ## Type in additional columns in real time for demonstration##
         )


#Data Aggregations
##How many total responses?
SurveyXLSX %>%
  count()
##Save the number as a VALUE
TotalResponses <- SurveyXLSX %>%
  count() %>%
  ##if just run through count() it will save as a df
  pull()

##How many responses each day?
###This won't "save" anywhere because it hasn't been assigned. 
SurveyXLSX %>%
  group_by(date(Timestamp)) %>%
  count()

##How many responses each week
###Weeks are "number of complete seven day periods that have occurred between the date and January 1, plus one" (See Help: Week)
SurveyXLSX %>%
  group_by(week(Timestamp)) %>%
  count()


#Factors
##Most questions in this survey are factors - categorical responses in which the respondent selects 1 item
##forcats package helps work with factors

##First, change the columns to factors from character, use lapply
colnames(SurveyXLSX) #get column names and index number to reference
SurveyXLSX[,c(2:9)] <- lapply(SurveyXLSX[,c(2:9)], as.factor)

#change order of factor levels: FCT_RELEVEL
##check levels
levels(SurveyXLSX$ExperienceProgCode)
fct_relevel(SurveyXLSX$ExperienceProgCode, c("Novice", "Basic knowledge or little to none", "Intermediate", "Advanced"))
##need to assign to "save" the relevel:
SurveyXLSX$ExperienceProgCode <- fct_relevel(SurveyXLSX$ExperienceProgCode, 
                                             c("Novice", "Basic knowledge or little to none", "Intermediate", "Advanced"))

#change values of levels or collapse levels: FCT_RECODE or FCT_COLLAPSE
##check levels
levels(SurveyXLSX$ExperienceProgCode)
fct_recode(SurveyXLSX$ExperienceProgCode, "minimal" = "Basic knowledge or little to none")
##Levels in the survey options aren't truly discrete. "Basic knowledge or little to none" overlaps with "Novice"
fct_collapse(SurveyXLSX$ExperienceProgCode, Low = c("Basic knowledge or little to none", "Novice"),
                                            Medium = "Intermediate",
                                            High = "Advanced")

#Create new variables: MUTATE
SurveyXLSX <- SurveyXLSX %>%
  mutate(NewColumnExampleText = "manually add column data",
         NewColumnExampleFormula = week(Timestamp))

#Create new variables based upon criteria: CASE_WHEN and IFELSE
##CASE_WHEN 2 examples. 1) more code, less complex Boolean operators 2) less code, more complex Boolean operators
SurveyXLSX %>%
  mutate(ExpRcat = case_when(ExperienceR=="Novice" ~ "Low",
                             ExperienceR=="Basic knowledge or little to none" ~ "Low",
                             # ExperienceR=="Intermediate" ~ "High",
                             # ExperienceR=="Advanced" ~ "High",
                             TRUE ~ as.character(NA)))
SurveyXLSX %>%
  mutate(ExpRcat = case_when(ExperienceR=="Novice"|ExperienceR=="Basic knowledge or little to none" ~ "Low",
                             ExperienceR=="Advanced"|ExperienceR=="Intermediate" ~ "High",
                             TRUE ~ as.character(NA)))
#Note: new column is character/string as default. Will need to convert to factor if want to use as factor

##IFELSE 2 examples. 1) more code, less complex Boolean operators 2) less code, more complex Boolean operators
SurveyXLSX %>%
  mutate(ExpRcat = if_else(ExperienceR=="Novice","Low",
                         #  "other",
                           if_else(ExperienceR=="Basic knowledge or little to none","Low","other"))
         )
SurveyXLSX %>%
  mutate(ExpRcat = if_else(ExperienceR=="Novice"|ExperienceR=="Basic knowledge or little to none","Low","other"))


#STRINGS: identify patterns, truncate string data
##str_detect helpful in combination with case_when or if_else
str_detect(SurveyXLSX$`What.are.you.hoping.to.take.away.from.the.session(s)?`, "how")
SurveyXLSX %>%
  mutate(TakeAwayHOW = case_when(str_detect(SurveyXLSX$`What.are.you.hoping.to.take.away.from.the.session(s)?`, "how")==TRUE ~ "Yes"))

##str_sub returns X number of characters in a string by counting specific number of characters from beginning or end
str_sub(SurveyXLSX$NewColumnExampleText, 1,5) #just the first 5 characters, inclusive
str_sub(SurveyXLSX$NewColumnExampleText, 5) #everything from character 5 to the end
str_sub(SurveyXLSX$NewColumnExampleText, -5) #just the last 5 characters
str_sub(SurveyXLSX$NewColumnExampleText, 5,10) #just characters 5 through 10

##Replace strings, including a subset
str_replace(SurveyXLSX$NewColumnExampleText, "a", "HELLO")
str_replace_all(SurveyXLSX$NewColumnExampleText, "a", "HELLO")

##join strings together, CONCATENATE in Excel or SQL
str_c(SurveyXLSX$NewColumnExampleText, SurveyXLSX$NewColumnExampleFormula, sep = "")

