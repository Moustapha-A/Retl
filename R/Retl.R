importCSV = function(conn, filepath, table_name){
  data = fread(filepath)
  RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data))
}

excelToDataFrame = function(conn, filepath, worksheet,fromRow){
  wb = loadWorkbook(filepath)
  ws = readWorksheet(wb,worksheet,startRow = fromRow)
  return(ws)
}

importXLSX = function(conn, filepath, worksheet,table_name,fromRow){
  data = excelToDataFrame(conn,filepath,worksheet,fromRow)
  RPostgreSQL::dbWriteTable(conn,table_name,as.data.frame(data))
}

importToDB = function(host, port="", user, password, database, filepath, type, worksheet=NULL, fromRow=1, tableName){

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
  })

  if (type=="xlsx"){
    if(is.null(worksheet)) stop("You should provide the excel worksheet name using the worksheet argument")
    importXLSX(conn, filepath, worksheet, tableName, fromRow)
  }

  else

  if(type=="csv"){
    importCSV(conn, filepath, tableName)
  }

  else stop("The type argument provided is not supported")

}



