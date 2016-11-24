
library(xml2)

library(tidyverse)
library(openxlsx)



##' Extracts all xml <tables...> into a list of data frames,
##' where each dataframe is the table content. 
##'
##' @title 
##' @param fileName The file to convert
##' @return List of data frames
extractTables <- function(fileName) {
    ## read xml document

    document <- xml2::read_xml(fileName) %>%
        xml_ns_strip
    
    ## create all xpath expressions to search for

    xpaths <- c(".//Table",
               paste0(".//Table",1:9),
               ".//PhysicochemicalPropertiesTable"
               )
    counter <- 0
    dfs <- list()
    ## iterate over all xpath expressions
    for (xpath in xpaths) {
        tables <- xml_find_all(document,xpath)
        ## iterate over all elemnts found per expression
        for (table in tables) {
                                       
            counter <- counter + 1
            
            ## get table name and table caption
            tableName <- xml_attr(table,"Name")
            captionName <-  xml_attr(table,"Caption")
            rowsTitle <- xml_attr(table,"RowsTitle")
            if (tableName == "") {
                tableName <- paste0("noName-",counter)
                captionName <- "noCaption"
                
            } else {
                tableName <- paste0(counter,"-",tableName)
            }
            rowsTitle <- ifelse(rowsTitle=="","rows",rowsTitle)
            ## extract column names
            columnNames <- table %>%
                      xml_find_all(".//Columns/Caption") %>%
                      xml_text

                  ## extract group names
            groupNames <- table %>%
                xml_find_all(".//Columns/Group") %>%
                xml_text
            
                                        #extract row names 
            rowNames <- table %>%
                xml_find_all(".//Rows/Caption") %>%
                xml_text
            
            
            
            ## extract content of all cell as a vector
            cells <- table %>%
                xml_find_all(".//Cells") %>%
                xml_text
            
            ## convert cell content vector to matrix of row and columns
                                        #browser()
            cellMatrix <- matrix(cells,
                                nrow = length(rowNames),
                                ncol = length(columnNames),
                                byrow = T)
            
                                   

            ## create data frame containing cells and (grouped) columnheaders
            df <- data_frame(rowNumber=1:(length(rowNames)+2))
            df[rowsTitle] <- c(rowsTitle,"",rowNames)
            
            
            df <- cbind(df,
                       rbind(groupNames,columnNames,as_data_frame(cellMatrix))) 
            dfs[[tableName]] <- df %>%
                dplyr::select(-rowNumber)
        }
        
    }
    dfs
}
##' Writes the list of data frames to an excel file.
##' All cells have type 'text', so needed to be converted in Excel, if needed.
##' @param dfs A list of data frames
exportToExcel <- function(dfs) {
    openxlsx::write.xlsx(dfs,"tables.xlsx",colNames=F,rowNames=F)
    print(paste(length(dfs),"sheet written"))    
}


## The extratction can be run like this
## extractTables("./044312_Dinotefuran_Apple_Draft_Dul_RCK_June_7_2016.xml") %>%
## exportToExcel()    
