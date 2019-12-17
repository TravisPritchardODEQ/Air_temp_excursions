#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)


load('data/Air_temp_checker.Rdata')
station_names = sort(unique(Air_temp_checker$STATION))

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Air Temperature Exclusion"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectizeInput("Air_Stations",
                     "Select Air Station",
                     choices = station_names,
                     multiple = FALSE,
                     ),
      airDatepickerInput(
        inputId = "date_select",
        label = "Select multiple dates:",
        placeholder = "You can pick 20 dates",
        view  = 'years',
        multiple = 20, clearButton = TRUE
      ),
      actionButton("go", "Filter",  icon("filter"))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      dataTableOutput('tbl')
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  table_Data <- eventReactive(input$go,{
    
    dat <- Air_temp_checker %>%
      filter(STATION == input$Air_Stations,
             DATE %in% input$date_select)
  
  })
  
  
  output$tbl <- renderDataTable({
    
    table_Data()
    
  }
    
  )

}

# Run the application 
shinyApp(ui = ui, server = server)
