

#' Extracts all xml <tables...> nodes into a list of data frames,
#' where each dataframe is the 'cell' nodes inside <table > content.
#'
#' @importFrom magrittr %>%
#' @param fileName The file to convert
#' @return List of data frames, where the key is a unique table name
#' constructed from the xml attributes 'Name' and 'Caption'
#' @export
extractTables <- function(fileName) {
    ## read xml document

    document <- xml2::read_xml(fileName) %>%
        xml2::xml_ns_strip()

    ## create all xpath expressions to search for

    xpaths <- c(".//Table",
               paste0(".//Table",1:9),
               ".//PhysicochemicalPropertiesTable")
    counter <- 0
    dfs <- list()
    ## iterate over all xpath expressions
    for (xpath in xpaths) {
        tables <- xml2::xml_find_all(document,xpath)
        ## iterate over all elemnts found per expression
        for (table in tables) {

            counter <- counter + 1
            ## get table name and table caption
            tableName <- xml2::xml_attr(table,"Name")
            captionName <-  xml2::xml_attr(table,"Caption")
            rowsTitle <- xml2::xml_attr(table,"RowsTitle")
            if (tableName == "") {
                tableName <- paste0("noName-",counter)
                captionName <- "noCaption"

            } else {
                tableName <- paste0(counter,"-",tableName)
            }
            rowsTitle <- ifelse(rowsTitle=="","rows",rowsTitle)
            ## extract column names
            columnNames <- table %>%
              xml2::xml_find_all(".//Columns/Caption") %>%
              xml2::xml_text()

                    ## extract group names
            groupNames <- table %>%
              xml2::xml_find_all(".//Columns/Group") %>%
              xml2::xml_text()

                                        #extract row names
            rowNames <- table %>%
              xml2::xml_find_all(".//Rows/Caption") %>%
              xml2::xml_text()



            ## extract content of all cell as a vector
            cells <- table %>%
              xml2::xml_find_all(".//Cells") %>%
              xml2::xml_text()
            if (length(cells)==0) {
              next()

            }
            ## convert cell content vector to matrix of row and columns
                                        #browser()
            cellMatrix <- matrix(cells,
                                nrow = length(rowNames),
                                ncol = length(columnNames),
                                byrow = T)



            ## create data frame containing cells and (grouped) columnheaders
            df <- dplyr::data_frame(rowNumber=1:(length(rowNames)+2))
            df[rowsTitle] <- c(rowsTitle,"",rowNames)


            df <- cbind(df,
                       rbind(groupNames,columnNames,dplyr::as_data_frame(cellMatrix)))
            dfs[[tableName]] <- df %>%
                dplyr::select(-rowNumber)

                                        #tidy_df <- data.frame(value=cells,rowname=rowNames,columnname=columnNames,group=groupNames)
        }

    }
    dfs
}
#' Writes the list of data frames to an excel file.
#' All cells have type 'text', so needed to be converted in Excel, if needed.
#' @param dfs A list of data frames
#' @param file The xlsx file to write the extracted tables to
#' @return NULL
#' @export
writeToExcel <- function(dfs,file = "tables.xlxs") {
    openxlsx::write.xlsx(dfs,"tables.xlsx",colNames = F,rowNames = F)
    print(paste(length(dfs),"sheets written"))
}


#' Runs the export as a shiny app, where the input file can be choosen
#' and the output is "table.xlsx:
#' @export
runShiny <- function() {
  appDir <- system.file("shiny-app",package = "mssTablesToExcel")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `mssTablesToExcel`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}


