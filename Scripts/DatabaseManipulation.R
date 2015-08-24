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
        
        ## Insert data into a table 'table', where 'Values_List' is a vector of values since we don't need to insert for specific columns.
        ## Print the insert statements to a file to get every insertion done in the database.
        insertIntoTable = function(table, Values_List)
        {
            query <- paste("INSERT INTO ", table, " VALUES(", paste(Values_List, collapse = ", ", sep = ""), ")", sep = "")
            cat(paste(query, "\n"), file = "inserts.txt", append = TRUE)
            #tryCatch(
                res <- dbSendQuery(private$con, query)#, 
            #    error = function(err) {e <- dbGetException(private$con); print(paste(e$errMsg, "\n", err))}, 
            #    finally = dbDisconnect(private$con)
            #)
        },
        
        ## Get the primary key value from a field name and a table given as inputs.
        getPkValueFromName = function(table, field_name, field_value)
        {
            query <- paste("SELECT pk", table, " FROM ", table, " WHERE ", field_name, " = '", field_value, "'", sep = "")
            #tryCatch(
                res <- dbSendQuery(private$con, query)#, 
            #    error = function(err) {print(err)}, 
            #    finally = dbDisconnect(private$con)
            #)
            result <- fetch(res, n = -1)
            result[1, paste("pk", table, sep = "")]
        },
        
        getConnection = function()
        {
            private$con
        }
    )
)