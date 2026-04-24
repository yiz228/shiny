# WIC Toddler Overweight Prevalence Shiny App

This repository contains the files for a Shiny App created for VTPEH 6270 Check Point 07. The app explores overweight prevalence among children participating in the Women, Infants, and Children (WIC) program, with a focus on differences by race/ethnicity and year.

## Research Question

Did the prevalence of overweight classification differ by race/ethnicity among children participating in WIC in the United States?

## Repository Contents

- `app.R`: The main Shiny App file, including the user interface, server logic, data cleaning, and visualization code.
- `Nut_Data.csv`: The dataset used in the app.

## App Description

The app allows users to interactively explore overweight prevalence among WIC toddlers. Users can select a year, choose a plot type, and select specific race/ethnicity groups. The visualization and summary text update based on the selected options.

## Variables Used in the App

The app uses the following variables from the dataset:

- `YearStart`: Year of the data record.
- `LocationDesc`: Geographic location associated with the record.
- `Question`: The health indicator being measured. This app focuses on the question: "Percent of WIC toddlers who have an overweight classification."
- `StratificationCategory1`: The category used for stratification. This app uses "Race/Ethnicity."
- `Stratification1`: Specific race/ethnicity group.
- `Data_Value`: Overweight prevalence percentage.

## How to Run the App Locally

To run the app locally, download or clone this repository, then open `app.R` in RStudio.

Make sure the required R packages are installed:

```r
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "readr"))
```

Run the app using:
```r
shiny::runApp()
```
Alternatively, open `app.R` in RStudio and click Run App.

## Data Source
The data were obtained from CDC Data.CDC.gov. The dataset is titled Nutrition, Physical Activity, and Obesity - Women, Infant, and Child.

## AI Use Disclosure
ChatGPT was used to assist with organizing the Shiny App structure, generating R code, troubleshooting R code, improving layout.




