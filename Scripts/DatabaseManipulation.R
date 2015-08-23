## Need of the RMySQL package.
library(RMySQL)

## Need to use object oriented.
library(R6)


## Class CaterpillarDatabase.
CaterpillarDatabase <- R6Class("CaterpillarDatabase",
    private = list(
        ## Connection handler of the database.
        con = NULL
    ),
    
    
    public = list(
        ## Constructor.
        initialize = function()
        {
            
        },
        
        ## Connect to Caterpillar database and return the resource used.
        connect = function()
        {
            private$con <<- dbConnect(
                dbDriver("MySQL"), 
                user = "root", 
                password = "glapointe7", 
                host = "localhost", 
                dbname="Caterpillar"
            )
        },
        
        ## Disconnect from the Caterpillar database.
        disconnect = function()
        {
            dbDisconnect(private$con)
        },
        
        ## Insert data into a table 'table', where 'fields' is a list field name ---> value.
        insertIntoTable = function(table, Values_List)
        {
            query <- paste("INSERT INTO ", table, " VALUES(", paste(Values_List, collapse = ", ", sep = ""), ")", sep = "")
            cat(paste(query, "\n"), file = "inserts.txt", append = TRUE)
            tryCatch(
                res <- dbSendQuery(private$con, query), 
                error = function(err) {print(err)}, 
                finally = dbDisconnect(private$con)
            )
        },
        
        ## Get the primary key value from a field name and a table given as inputs.
        getPkValueFromName <- function(table, field_name, field_value)
        {
            query <- paste("SELECT pk", table, " FROM ", table, " WHERE ", field_name, " = '", field_value, "'", sep = "")
            tryCatch(
                res <- dbGetQuery(private$con, query), 
                error = function(err) {print(err)}, 
                finally = dbDisconnect(private$con)
            )
        }
    )
)