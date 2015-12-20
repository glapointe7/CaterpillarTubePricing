## Need of the RMySQL package.
library(RMySQL)

## Need to use object oriented.
library(R6)


CaterpillarDatabase <- R6Class("CaterpillarDatabase",
    private = list(
        ## Connection handler of the database.
        con = NULL
    ),
    
    
    public = list(

        initialize = function()
        {
            
        },
        
        ## Connect to Caterpillar database and return the resource used.
        connect = function()
        {
            tryCatch(
                private$con <- dbConnect(
                    dbDriver("MySQL"), 
                    user = "root", 
                    password = "glapointe7", 
                    host = "localhost", 
                    dbname="Caterpillar"
                ),
                error = function(err) {print(err)}
            )
        },
        
        ## Disconnect from the Caterpillar database.
        disconnect = function()
        {
            dbDisconnect(private$con)
        },
        
        ## Insert data into a table 'table', where 'values' is a string of values since we don't need to insert for specific columns.
        ## MySQL syntax used: INSERT INTO TableName VALUES(...), (...), ..., (...);
        insertIntoTable = function(table, values)
        {
            query <- paste0("INSERT INTO ", table, " VALUES(", values, ");")
            tryCatch(
                res <- dbSendQuery(private$con, query),
                error = function(err) {print(err); dbDisconnect(private$con)}
            )
        },
        
        ## Get the primary key value from a field name and a table given as inputs.
        getPkValueFromName = function(table, field_name, field_value)
        {
            query <- paste0("SELECT pk", table, " FROM ", table, " WHERE ", field_name, " = '", field_value, "'")
            res <- dbSendQuery(private$con, query)
            result <- fetch(res, n = -1)
            result[1, paste0("pk", table)]
        },
        
        ## Execute a SELECT statement in the Caterpillar database.
        selectFromTable = function(query)
        {
            res <- dbSendQuery(private$con, query)
            result <- fetch(res, n = -1)
        }
    )
)