#' @export
execHiveQuery <- function(query) {
#    library("RJDBC")
    drv <- JDBC(driverClass = "org.apache.hive.jdbc.HiveDriver", "/BAZjars/hive-jdbc-3.1.2-standalone.jar")
    drv <- JDBC(driverClass = "org.apache.hive.jdbc.HiveDriver", "/BAZjars/hadoop-common-3.3.1.jar")
    conn <-dbConnect(drv, "jdbc:hive2://hiveServer:10000/")
    result <- dbGetQuery(conn, query)
    return(result)
}