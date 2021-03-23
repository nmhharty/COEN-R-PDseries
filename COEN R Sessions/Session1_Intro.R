#COEN R and RMarkdown Professional Development Series
#Session 1: Introduction to R and RStudio for Evaluators

#Fist Authored: 2/13/2021 Nicole Harty
#Last Updated: 3/06/2021 Nicole Harty


# Session Objectives:
## Explain file directories, file types, and project structure
## Install and use major packages to import data and create data frames

#load packages
library(openxlsx)
library(googlesheets4)
library(tidyverse)

#check working directory
getwd()
#Change wd if needed
#first with code
setwd("U:/COEN R PD/COEN-R-PDseries/COEN R Sessions")
#second using GUI

#load data file
#from .xslx file
read.xlsx("R Workshop (Responses).xlsx")
#from .csv file
read.csv("R Workshop (Responses) - Form Responses 1.csv", header = TRUE)
#save this data as a dataframe
SurveyCSV <- read.csv("R Workshop (Responses) - Form Responses 1.csv", header = TRUE)
SurveyXLSX <- read.xlsx("R Workshop (Responses).xlsx")


#from API connection to Google Sheets
read_sheet("https://docs.google.com/spreadsheets/d/17uyz1A90D6XgGKi_Qer-ssgkWRdPmKACEOHzk0FhjiI/edit#gid=790590919")
#save this data as a dataframe
##commented this out because don't want to use live connectioncommented this out because don't want
# SurveyGSheetAPI <- read_sheet("https://docs.google.com/spreadsheets/d/17uyz1A90D6XgGKi_Qer-ssgkWRdPmKACEOHzk0FhjiI/edit#gid=790590919")

#look at the data
##use data viewer
##in console
SurveyXLSX
##get info about data
colnames(SurveyXLSX)
data.class(SurveyXLSX$`What.session(s).are.you.attending?.(Check.all.that.apply)`)
data.class(SurveyXLSX$Timestamp)

