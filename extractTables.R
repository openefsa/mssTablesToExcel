library(xmlview)
library(xml2)

library(tidyverse)

#read xml document

document <- xml2::read_xml("./044312_Dinotefuran_Apple_Draft_Dul_RCK_June_7_2016.xml") %>%
  xml_ns_strip
dir.create("tables",showWarnings = F)
# create all xpath expressions to search for

xpaths <- c(".//Table",
            paste0(".//Table",1:9),
            ".//PhysicochemicalPropertiesTable"
            )
counter <- 0
csvFiles <- c()
# iterate over all xpath expressions
for (xpath in xpaths) {
  tables <- xml_find_all(document,xpath)
  # iterate over all elemnts found per expression
  for (table in tables) {
    counter <- counter + 1
    
    # get table name and table caption
    tableName <- xml_attr(table,"Name")
    captionName <-  xml_attr(table,"Caption")
    if (tableName == "") {
      tableName <- paste0("noName-",counter)
      captionName <- "noCaption"
      
    }
    #extract column names
    columnNames <- table %>%
      xml_find_all(".//Columns/Caption") %>%
      xml_text

    groupNames <- table %>%
      xml_find_all(".//Columns/Group") %>%
      xml_text
    
    #extract row names 
    rowNames <- table %>%
      xml_find_all(".//Rows/Caption") %>%
      xml_text
    
    
    
    #extract content of all cell as a vector
    cells <- table %>%
      xml_find_all(".//Cells") %>%
      xml_text
    
    # convert cell content vector to matrix of row and columns
    cellMatrix <- matrix(cells,
                nrow = length(rowNames),
                ncol = length(columnNames),
                byrow = T)
    
    dimnames(cellMatrix) <- list(rowNames,columnNames)
    
    df <- data_frame(caption=c("","",rowNames)) %>%
      bind_cols(
       rbind(groupNames,columnNames,as_data_frame(cellMatrix))) 
     
      
    # contstuct filename of the cv file
    fileName <- paste0("tables/",URLencode(paste0("t",counter,"-",tableName,"-",captionName,".csv"),reserved = T))
    
    write.csv(df,fileName,row.names = F)
    csvFiles <- c(csvFiles,fileName)
    }
}
#zip all csv files together
zip("tables.zip",csvFiles)