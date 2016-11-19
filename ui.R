shinyUI(bootstrapPage(
    fileInput("xmlFile","Choose xml file"),
    textOutput("message"),
    downloadLink("downloadData", "Download tables")

))


