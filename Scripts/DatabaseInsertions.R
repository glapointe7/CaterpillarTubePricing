source("Scripts/DatabaseManipulation.R")

## To perform SQL selection queries on csv file reading.
library(sqldf)

#####################################################################
# Class to insert data in tables of the Caterpillar database.
#####################################################################
CaterpillarTables <- R6Class("CaterpillarTables",
    private = list(
        database = NULL,
        OTHER = 9999
    ),
    
    public = list(
        ## Constructor and destructor.
        initialize = function()
        {
            private$database <<- CaterpillarDatabase$new()
            private$database$connect()
            
            reg.finalizer(private,
                          function() {private$database$disconnect()},
                          onexit = TRUE)
        },

        ## Add all rows from files Dataset/type_[type].csv to table ComponentType, ConnectionType and EndFormType in the Caterpillar database.
        addAllTypesData = function()
        {
            Types_List <- list(component = "ComponentType", connection = "ConnectionType", end_form = "EndFormType")
            for(type in names(Types_List))
            {
                cat(paste0("Process insertions into table ", Types_List[[type]], "..."))
                field_type <- ifelse(type == "end_form", paste0(type, "_id"), paste0(type, "_type_id"))
                data <- read.csv.sql(paste0("Dataset/type_", type, ".csv"), sql = paste0("SELECT ", field_type, ",name FROM file"))
                
                data[[field_type]] <- ifelse(data[, field_type] == "Other", private$OTHER, as.integer(str_sub(data[, field_type], start = -3)))
                
                rows_values <- apply(data, 1, paste, collapse = ",'")
                values <- paste0(paste(rows_values, collapse = "'),("), "'")
                
                ## Insert the component type 'OTHER' since there's no such type defined, but it is used in every component file.
                if(type == "component")
                {
                    values <- paste0(values, "),(9999,'Other'")
                }
                private$database$insertIntoTable(Types_List[[type]], values)
                cat("DONE\n")
            }
        },
        
        ## Merge all component types data files and insert the data into the Component table in the Caterpillar database.
        addMergedComponentsData = function()
        {
            cat("Process insertions into Component table...")
            files <- c("Dataset/comp_adaptor.csv", "Dataset/comp_boss.csv", "Dataset/comp_elbow.csv", "Dataset/comp_float.csv", "Dataset/comp_hfl.csv", 
                       "Dataset/comp_nut.csv", "Dataset/comp_sleeve.csv", "Dataset/comp_straight.csv", "Dataset/comp_tee.csv", "Dataset/comp_threaded.csv", 
                       "Dataset/comp_other.csv")
            
            datalist <- lapply(files, read.csv, header = T, stringsAsFactors = FALSE)
            data <- Reduce(function(x, y) { merge(x, y, all = T) }, datalist)
            
            col_kept <- c("component_id", "component_type_id", "weight")
            data <- data[,col_kept]
            new_row <- data.frame(component_id = "C-9999", component_type_id = NA, weight = NA)
            data <- rbind(data, new_row)

            ## Transform the data.
            data$component_id <- as.integer(substring(data$component_id, 3))
            data$component_type_id <- as.integer(substring(data$component_type_id, 4))
            data[is.na(data$component_type_id), "component_type_id"] <- private$OTHER
            data$weight <- ifelse(is.na(data$weight), 0.0, data$weight)
            #data$overall_length <- ifelse(is.na(data$overall_length), "NULL", data$overall_length)
            #data$hex_size <- ifelse(is.na(data$hex_size), "NULL", data$hex_size)
            
            rows_values <- apply(data, 1, paste, collapse = ",")
            values <- paste0(paste(rows_values, collapse = "),("))
            private$database$insertIntoTable("Component", values)
            
            cat("DONE\n")
        },
        
        ## Add all rows from the file Dataset/tube_end_form.csv to the table TubeEndForm in the Caterpillar database.
        addEndTubeFormData = function()
        {
            cat("Process insertions into TubeEndForm table...")
            data <- read.csv.sql("Dataset/tube_end_form.csv", sql = "SELECT end_form_id, forming FROM file")
            
            data$end_form_id <- ifelse(data$end_form_id == private$OTHER, private$OTHER, as.integer(substring(data$end_form_id, 4)))
            data$forming <- ifelse(data$forming == "Yes", 1, 0)
            
            rows_values <- apply(data, 1, paste, collapse = ",")
            values <- paste(rows_values, collapse = "),(")
            private$database$insertIntoTable("TubeEndForm", values)
            
            cat("DONE\n")
        },
        
        ## Add all rows from the file Dataset/tube.csv to the table TubeAssembly in the Caterpillar database.
        ## There is no tube assembly TA-19491, so the primary key is not an auto increment.
        addTubeAssemblyData = function()
        {
            cat("Process insertions into TubeAssembly table...")
            data <- read.csv.sql("Dataset/tube.csv", sql = "SELECT tube_assembly_id, material_id, diameter, wall, length, num_bends, bend_radius, 
                                                                   end_a_1x, end_a_2x, end_x_1x, end_x_2x, end_a, end_x, num_boss, num_bracket, other FROM file")
            
            ## Transform the data.
            data$tube_assembly_id <- as.integer(substring(data$tube_assembly_id, 4))
            data$material_id <- ifelse(data$material_id == "NA", 0, as.numeric(substring(data$material_id, 4)))
            data$diameter <- ifelse(data$diameter == "NA", 0.0, data$diameter)
            data$wall <- ifelse(data$wall == "NA", 0.0, data$wall)
            data$length <- ifelse(data$length == "NA", 0.0, data$length)
            data$num_bends <- ifelse(data$num_bends == "NA", 0, data$num_bends)
            data$bend_radius <- ifelse(data$bend_radius == "NA", 0.0, data$bend_radius)
            data$end_a_1x <- ifelse(data$end_a_1x == "Y", 1, 0)
            data$end_a_2x <- ifelse(data$end_a_2x == "Y", 1, 0)
            data$end_x_1x <- ifelse(data$end_x_1x == "Y", 1, 0)
            data$end_x_2x <- ifelse(data$end_x_2x == "Y", 1, 0)
            data$end_a <- ifelse(data$end_a == "NONE", "NULL", as.integer(substring(data$end_a, 4)))
            data$end_x <- ifelse(data$end_x == "NONE", "NULL", as.integer(substring(data$end_x, 4)))
            
            ## There is a maximum of 10 specs and a minimum of 0 spec for each tube assembly.
            data_specs <- read.csv.sql("Dataset/specs.csv", sql = "SELECT spec1, spec2, spec3, spec4, spec5, spec6, spec7, spec8, spec9, spec10 FROM file")
            specs <- apply(data_specs, 1, function(x){paste(x[x != "NA"], collapse = ",")})
            data$specs <- ifelse(specs == "", "NULL", paste0("'", specs, "'"))
            
            rows_values <- apply(data, 1, paste, collapse = ",")
            values <- paste(rows_values, collapse = "),(")
            private$database$insertIntoTable("TubeAssembly", values)
            
            cat("DONE\n")
        },
        
        ## Add all rows from the file Dataset/train_set.csv to the table TubeAssemblyPricing in the Caterpillar database.
        addTubeAssemblyPricingData = function()
        {
            cat("Process insertions into TubeAssemblyPricing table...")
            train_data <- read.csv.sql("Dataset/train_set.csv", sql = "SELECT tube_assembly_id, supplier, quote_date, annual_usage, min_order_quantity, 
                                                                              bracket_pricing, quantity, cost FROM file")
            test_data <- read.csv.sql("Dataset/test_set.csv", sql = "SELECT tube_assembly_id, supplier, quote_date, annual_usage, min_order_quantity, 
                                                                            bracket_pricing, quantity FROM file")
            # Merge the test and train sets.
            test_data$cost <- 0.0
            data <- merge(test_data, train_data, all = TRUE)
            
            ## Transform the data.
            data <- cbind(primary_key = "NULL", data)
            data$tube_assembly_id <- as.integer(substring(data$tube_assembly_id, 4))
            data$supplier <- as.numeric(substring(data$supplier, 3))
            data$quote_date <- paste0("'", data$quote_date, "'")
            data$bracket_pricing <- ifelse(data$bracket_pricing == "Yes", 1, 0)
            
            rows_values <- apply(data, 1, paste, collapse = ",")
            values <- paste(rows_values, collapse = "), (")
            private$database$insertIntoTable("TubeAssemblyPricing", values)
            
            cat("DONE\n")
        },
        
        ## Add all rows from the file Dataset/bill_of_materials.csv to the table TubeAssembly_Component in the Caterpillar database.
        addBillOfMaterialsData = function()
        {
            cat("Process insertions into TubeAssembly_Component table...")
            query <- "SELECT tube_assembly_id, component_id_1, quantity_1, component_id_2, quantity_2, component_id_3, quantity_3, component_id_4, quantity_4, 
                             component_id_5, quantity_5, component_id_6, quantity_6, component_id_7, quantity_7, component_id_8, quantity_8 FROM file 
                      WHERE component_id_1 <> 'NA'"
            data <- read.csv.sql("Dataset/bill_of_materials.csv", sql = query)
            
            ## Transform the data.
            data$tube_assembly_id <- as.integer(substring(data$tube_assembly_id, 4))
            
            ## Change the component ids to match with primary key integers. (Remove the prefix "C-")
            component_id_cols <- c("component_id_1", "component_id_2", "component_id_3", "component_id_4", "component_id_5", "component_id_6", "component_id_7", "component_id_8")
            data[, component_id_cols] <- apply(data[, component_id_cols], 2, function(x)
            {
                ifelse(x != "NA", ifelse(x == private$OTHER, private$OTHER, as.integer(substring(x, 3))), "NA")
            })
            
            ## Split columns in dataframes of 3 columns: (tube_assembly_id, component_id, quantity)
            values <- ""
            for(i in 1:7)
            {
                data_components <- data[, c("tube_assembly_id", paste0("component_id_", i), paste0("quantity_", i))]
                rows_values <- apply(data_components, 1, function(x){paste(x[x != "NA"], collapse = ",")})
                
                ## We keep only string with two comas since the dataset contains NA components with a non NA quantity associated.
                ## This behaviour is absurd so we ensure we won't let that happens.
                rows_values <- rows_values[str_count(rows_values, ",") == 2]
                values <- paste0(values, paste(rows_values, collapse = "),("), "),(")
            }
            ## Since we ensure that there is only one tube assembly with 8 different components.
            ## The collapse won't do anything in that case, so we have to manually enter the values.
            values <- paste0(values, "11524,1981,1")
            private$database$insertIntoTable("TubeAssembly_Component", values)
            
            cat("DONE\n")
        }
    )
)

## After grouping and cleaning data, we insert all data from the dataset in our Caterpillar database.
addDatasetToDatabase <- function()
{
    library(stringr)
    table <- CaterpillarTables$new()
    
    table$addAllTypesData()
    table$addMergedComponentsData()
    table$addEndTubeFormData()
    table$addTubeAssemblyData()
    table$addTubeAssemblyPricingData()
    table$addBillOfMaterialsData()
    
    gc()
}