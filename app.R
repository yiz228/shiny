library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(readr)

wic <- read_csv("Nut_Data.csv", show_col_types = FALSE)


# clean data
wic_clean <- wic %>%
  filter(
    Question == "Percent of WIC toddlers who have an overweight classification",
    StratificationCategory1 == "Race/Ethnicity",
    !is.na(Data_Value)
  ) %>%
  select(
    YearStart,
    LocationDesc,
    Question,
    StratificationCategory1,
    Stratification1,
    Data_Value
  ) %>%
  mutate(
    Stratification1 = case_when(
      Stratification1 == "American Indian/Alaska Native" ~ "American Indian/\nAlaska Native",
      Stratification1 == "Asian/Pacific Islander" ~ "Asian/\nPacific Islander",
      Stratification1 == "Non-Hispanic Black" ~ "Non-Hispanic\nBlack",
      Stratification1 == "Non-Hispanic White" ~ "Non-Hispanic\nWhite",
      TRUE ~ Stratification1
    )
  )




ui <- page_sidebar(
  title = "WIC Toddler Overweight Prevalence Explorer",
  theme = bs_theme(bootswatch = "flatly"),
  
  sidebar = sidebar(
    h4("User Controls"),
    
    selectInput(
      inputId = "year",
      label = "Select year:",
      choices = sort(unique(wic_clean$YearStart)),
      selected = 2008
    ),
    
    selectInput(
      inputId = "plot_type",
      label = "Select plot type:",
      choices = c("Boxplot", "Bar chart"),
      selected = "Boxplot"
    ),
    
    checkboxGroupInput(
      inputId = "race_groups",
      label = "Select race/ethnicity groups:",
      choices = sort(unique(wic_clean$Stratification1)),
      selected = sort(unique(wic_clean$Stratification1))
    )
  ),
  
  tabsetPanel(
    tabPanel(
      "About this App",
      
      h3("App Goal"),
      p("This Shiny App allows users to explore racial and ethnic differences in overweight prevalence among children participating in WIC. Users can select a year and race/ethnicity groups to compare prevalence patterns."),
      
      h3("Research Question"),
      p("Did overweight prevalence differ by race/ethnicity among children participating in WIC?"),
      
      h3("Data Source"),
      p("Data source: CDC Data.CDC.gov, Nutrition, Physical Activity, and Obesity - Women, Infant, and Child dataset."),
      
      h3("How to Use This App"),
      p("Use the sidebar to select a year, choose a plot type, and select race/ethnicity groups. The visualization and summary will update based on the selected options."),
      
      h3("Github Repository"),
      p("https://github.com/yiz228/shiny"),
      
      h3("AI Use Disclosure"),
      p("ChatGPT was used to assist with organizing the Shiny App structure and troubleshooting R code.")
    ),
    
    tabPanel(
      "Data Visualization",
      
      h3("Data Visualization"),
      plotOutput("prevalence_plot", height = "550px"),
      
      h3("Summary"),
      textOutput("summary_text")
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    wic_clean %>%
      filter(
        YearStart == input$year,
        Stratification1 %in% input$race_groups
      )
  })
  
  output$prevalence_plot <- renderPlot({
    data_to_plot <- filtered_data()
    
    if (input$plot_type == "Boxplot") {
      ggplot(data_to_plot, aes(x = Stratification1, y = Data_Value)) +
        geom_boxplot() +
        labs(
          title = paste("Overweight Prevalence by Race/Ethnicity in", input$year),
          x = "Race/Ethnicity",
          y = "Overweight prevalence (%)"
        ) +
        theme_minimal(base_size = 13) +
        theme(
          axis.text.x = element_text(angle = 0, hjust = 0.5, size = 11),
          axis.title.x = element_text(margin = margin(t = 15)),
          axis.title.y = element_text(margin = margin(r = 15)),
          plot.title = element_text(size = 15, face = "bold"),
          plot.margin = margin(15, 15, 50, 15)
        )
    } else {
      summary_df <- data_to_plot %>%
        group_by(Stratification1) %>%
        summarise(
          median_prevalence = median(Data_Value, na.rm = TRUE),
          .groups = "drop"
        )
      
      ggplot(summary_df, aes(x = Stratification1, y = median_prevalence)) +
        geom_col() +
        labs(
          title = paste("Median Overweight Prevalence by Race/Ethnicity in", input$year),
          x = "Race/Ethnicity",
          y = "Median overweight prevalence (%)"
        ) +
        theme_minimal(base_size = 13) +
        theme(
          axis.text.x = element_text(angle = 0, hjust = 0.5, size = 11),
          axis.title.x = element_text(margin = margin(t = 15)),
          axis.title.y = element_text(margin = margin(r = 15)),
          plot.title = element_text(size = 15, face = "bold"),
          plot.margin = margin(15, 15, 50, 15)
        )
    }
  })
  
  output$summary_text <- renderText({
    data_to_summarize <- filtered_data()
    
    if (nrow(data_to_summarize) == 0) {
      return("No data are available for the selected options.")
    }
    
    summary_df <- data_to_summarize %>%
      group_by(Stratification1) %>%
      summarise(
        median_prevalence = median(Data_Value, na.rm = TRUE),
        .groups = "drop"
      )
    
    highest_group <- summary_df %>%
      filter(median_prevalence == max(median_prevalence, na.rm = TRUE)) %>%
      slice(1)
    
    lowest_group <- summary_df %>%
      filter(median_prevalence == min(median_prevalence, na.rm = TRUE)) %>%
      slice(1)
    
    paste0(
      "In ", input$year, ", the selected group with the highest median overweight prevalence was ",
      highest_group$Stratification1, " (", round(highest_group$median_prevalence, 1), "%). ",
      "The selected group with the lowest median overweight prevalence was ",
      lowest_group$Stratification1, " (", round(lowest_group$median_prevalence, 1), "%)."
    )
  })
}

shinyApp(ui = ui, server = server)