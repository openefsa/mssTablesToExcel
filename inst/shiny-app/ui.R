shinyUI(bootstrapPage(
    fileInput("xmlFile","Choose mss xml file"),
    textOutput("message"),
    downloadLink("downloadData", "Download tables")

))


