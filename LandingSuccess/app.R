library(shiny)
library(dplyr)

# read SpaceX dataset
spacex_data <- read.csv("spacex_launch_dash.csv");

# UI for an application that selects SpaceX launch sites and shows percentage of landing success by site
ui <- shinyUI(
    fluidPage(
    
    # Application title
    titlePanel("Launch Site recovery success rate"),
    
    # selector for launch site or all sites
    selectInput(inputId = "site", label = strong("Launch Site"), 
                choices = c("All Sites", "CCAFS LC-40", "KSC LC-39A", "CCAFS SLC-40", "VAFB SLC-4E"),
                selected = "All Sites"),
    
    # display the chart and title in the main panel
    mainPanel(
                textOutput(outputId = "chartheader"),
                plotOutput(outputId = "piechart", height = "300px")
             )
    )
)

# server logic for generating the pie chart for percentage of landing successes
server <- shinyServer(function(input, output) {
  
  outputdata <- reactive({
    # if all sites are selected - pie chart displays the number of successes at each site
    if(input$site == "All Sites")
    {
      # sum up the successes for each site and generate pie chart
      tempdata <- tapply(spacex_data$class, spacex_data$"Launch.Site", sum)
    }
    # if a single site is selected - pie chart displays the successes vs failures at each site
    else
    {
      # sum up the successes and failures for the selected site and generate pie chart
      tempdata <- subset(spacex_data, spacex_data$"Launch.Site" == input$site)
      tempdata$oneslist <- replicate(length(tempdata$class), 1)
      tempdata <- tapply(tempdata$oneslist, tempdata$class, sum)
    }
    outputdata <- tempdata
  })
  
  chartTitle <- reactive({
    if(input$site=="All Sites") 
    {  
      chartTitle <- paste("Landing Successes by Launch Site")
    }
    else
    {
      chartTitle <- paste("Landing Successes vs Failures for site ", input$site)
    }
  })
  
  output$chartheader <- renderText({
    paste(chartTitle())
  })
  output$piechart <- renderPlot({
    pie(outputdata())
  })
})

# Create Shiny object
shinyApp(ui = ui, server = server)

