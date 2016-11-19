source("./extractTables.R")

shinyServer(function(input, output) {

    output$message <- renderText({

        inFile <- input$xmlFile
        if (is.null(inFile))
            return("Tables not ready ...")
        else {
            extractTables(inFile$datapath)
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



