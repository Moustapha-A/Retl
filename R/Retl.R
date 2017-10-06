devtools::use_package("RPostgreSQL")
devtools::use_package("data.table")
devtools::use_package("XLConnect")


importCSV = function(conn, filepath, table_name,append=FALSE){
  data = data.table::fread(filepath)
  if(isTRUE(append)){
    RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data),append=TRUE)
  }
  else{
    RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data))
  }
}

excelToDataFrame = function(conn, filepath, worksheet,fromRow){
  wb = XLConnect::loadWorkbook(filepath)
  ws = XLConnect::readWorksheet(wb,worksheet,startRow = fromRow)
  return(ws)
}

importXLSX = function(conn, filepath, worksheet,table_name,fromRow, append = FALSE){
  data = excelToDataFrame(conn,filepath,worksheet,fromRow)
  if(isTRUE(append)){
  RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data),append=TRUE)
  }
  else{
  RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data))
}
}

importToDB = function(host, port="", user, password, database, filepath, type, worksheet=NULL, fromRow=1, tableName, append = FALSE){

  tryCatch({
    drv <- dbDriver("PostgreSQL")
    print("Connecting to database")
    conn <- dbConnect(drv,
                      dbname = database,
                      host = host,
                      port = port,
                      user = user,
                      password = password)
    print("Connected!")
  },
  error=function(cond) {
    print("Unable to connect to database.")
    print(cond)
  })

  if (type=="xlsx"){
    if(is.null(worksheet)) stop("You should provide the excel worksheet name using the worksheet argument")

    if(isTRUE(append)){importXLSX(conn, filepath, worksheet, tableName, fromRow, append = TRUE)}
    else{importXLSX(conn, filepath, worksheet, tableName, fromRow)}
  }

  else

  if(type=="csv"){
    if(isTRUE(append)){importCSV(conn, filepath, tableName, append = TRUE)}
    else{importCSV(conn, filepath, tableName)}
  }

  else stop("The type argument provided is not supported")

}



