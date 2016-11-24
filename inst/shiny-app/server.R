library(magrittr)
library(tidyverse)

shinyServer(function(input, output) {

    output$message <- renderText({

        inFile <- input$xmlFile
        if (is.null(inFile))
            return("Tables not ready yet...")
        else {
            extractTables(inFile$datapath) %>% writeToExcel()
            return("Tables ready")
            }
    })

    output$downloadData <- downloadHandler(
    filename = function() {
      "tables.xlsx"
    },
    content = function(file) {
      file.copy("./tables.xlsx",file)

    }
  )
})



