source("Scripts/DatabaseManipulation.R")

## To perform SQL selection queries on csv file reading.
library(sqldf)

#####################################################################
# Class to insert data in tables of the Caterpillar database.
#####################################################################
CaterpillarTables <- R6Class("CaterpillarTables",
    private = list(
        database = NULL
        
        ## Insert the 4 thread connections in the table 'Component_Connection' for each row of the comp_threaded file.
#         addThreadedConnectionsData = function(data, data_threaded)
#         {
#             ## Change the component ids to match with primary key integers. (Removed the prefix "C-")
#             data_connections <- data[, 6:29]
#             data_connections <- cbind(component_id = data_threaded$component_id, data_connections)
#             ids <- c("end_form_id_1", "connection_type_id_1", "end_form_id_2", "connection_type_id_2", 
#                      "end_form_id_3", "connection_type_id_3", "end_form_id_4", "connection_type_id_4")
#             data_connections[, ids] <- apply(data_connections[, ids], 2, function(x){ifelse(x != "NA", as.integer(substring(x, 3)), "NA")})
#             
#             values <- ""
#             for(i in 1:3)
#             {
#                 end_form_id <- paste0("end_form_id_", i)
#                 connection_type_id <- paste0("connection_type_id_", i)
#                 length <- paste0("length_", i)
#                 thread_size <- paste0("thread_size_", i)
#                 thread_pitch <- paste0("thread_pitch_", i)
#                 nominal_size <- paste0("nominal_size_", i)
#                 
#                 data_components <- data_connections[, c("component_id", end_form_id, connection_type_id, length, thread_size, thread_pitch, nominal_size)]
#                 data_components[,end_form_id] <- ifelse(data_components[,end_form_id] == "NA", "NULL", data_components[,end_form_id])
#                 data_components[,connection_type_id] <- ifelse(data_components[,connection_type_id] == "NA", "NULL", data_components[,connection_type_id])
#                 data_components[,length] <- ifelse(data_components[,length] == "NA", "NULL", data_components[,length])
#                 data_components[,thread_size] <- ifelse(data_components[,thread_size] == "NA", "NULL", data_components[,thread_size])
#                 data_components[,thread_pitch] <- ifelse(data_components[,thread_pitch] == "NA", "NULL", data_components[,thread_pitch])
#                 data_components[,nominal_size] <- ifelse(data_components[,nominal_size] %in% c("NA", 9999), "NULL", data_components[,nominal_size])
#                 
#                 rows_values <- apply(data_components, 1, function(x){paste(x[x[paste0("end_form_id_", i)] != "NULL"], collapse = ",")})
#                 values <- paste0(values, paste(rows_values[grepl(",", rows_values)], collapse = "),("), "),(")
#             }
#             ## This is the only one with a 4th connection. Since there's only one, the collapse won't add "),(" as needed. 
#             ## Thus, we have to add manually this connection.
#             values <- paste0(values, "605,1,2,41.7,1.187,12,NULL")
#             private$database$insertIntoTable("Component_Connection", values)
#         }
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
                
                data[[field_type]] <- ifelse(data[, field_type] == "Other", 9999, as.integer(str_sub(data[, field_type], start = -3)))
                
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
            
            col_kept <- c("component_id", "component_type_id", "weight", "overall_length", "hex_size")
            data <- data[,col_kept]
            new_row <- data.frame(component_id = "C-9999", component_type_id = NA, weight = NA, overall_length = NA, hex_size = NA)
            data <- rbind(data, new_row)

            ## Transform the data.
            data$component_id <- as.integer(substring(data$component_id, 3))
            data$component_type_id <- as.integer(substring(data$component_type_id, 4))
            data[is.na(data$component_type_id), "component_type_id"] <- 9999
            data$weight <- ifelse(is.na(data$weight), "NULL", data$weight)
            data$overall_length <- ifelse(is.na(data$overall_length), "NULL", data$overall_length)
            data$hex_size <- ifelse(is.na(data$hex_size), "NULL", data$hex_size)
            
            rows_values <- apply(data, 1, paste, collapse = ",")
            values <- paste0(paste(rows_values, collapse = "),("))
            private$database$insertIntoTable("Component", values)
            
            cat("DONE\n")
        },
        
        ## Add all rows from the file Dataset/components.csv to the table Components in the Caterpillar database.
#         addAllComponentsData = function()
#         {
#             cat("Process insertions into ComponentType table...")
#             data <- read.csv.sql("Dataset/components.csv", sql = "SELECT name, component_type_id FROM file")
#             
#             ## ComponentType must be filled before getting his ID from the type Other.
#             pk_component_type <- private$database$getPkValueFromName("ComponentType", "name", "Other")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_type_id <- ifelse(data[, "component_type_id"] == "OTHER", pk_component_type, as.integer(substring(data[, "component_type_id"], 4)))
#             data$name <- paste0("'", data$name, "'")
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "), (")
#             private$database$insertIntoTable("Component", values)
#             
#             cat("DONE\n")
#         },
        
        ## Add all rows from the file Dataset/tube_end_form.csv to the table TubeEndForm in the Caterpillar database.
        addEndTubeFormData = function()
        {
            cat("Process insertions into TubeEndForm table...")
            data <- read.csv.sql("Dataset/tube_end_form.csv", sql = "SELECT end_form_id, forming FROM file")
            
            data$end_form_id <- ifelse(data$end_form_id == 9999, 9999, as.integer(substring(data$end_form_id, 4)))
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
            data$material_id <- ifelse(data$material_id == "NA", "NULL", paste0("'", data$material_id, "'"))
            data$diameter <- ifelse(data$diameter == "NA", "NULL", data$diameter)
            data$wall <- ifelse(data$wall == "NA", "NULL", data$wall)
            data$length <- ifelse(data$length == "NA", "NULL", data$length)
            data$num_bends <- ifelse(data$num_bends == "NA", "NULL", data$num_bends)
            data$bend_radius <- ifelse(data$bend_radius == "NA", "NULL", data$bend_radius)
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
            data$supplier <- paste0("'", data$supplier, "'")
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
                ifelse(x != "NA", ifelse(x == 9999, 9999, as.integer(substring(x, 3))), "NA")
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
        
        ## Add all rows from the file Dataset/comp_other.csv to the table ComponentOther in the Caterpillar database.
#         addOtherComponentsData = function()
#         {
#             cat("Process insertions into ComponentOther table...")
#             data <- read.csv.sql("Dataset/comp_other.csv", sql = "SELECT component_id, part_name, weight FROM file")
#             
#             ## Transform the data. The weights with NA are converted to 0...
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$part_name <- paste0("'", data$part_name, "'")
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentOther", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_adaptor.csv to the table ComponentAdaptor in the Caterpillar database.
#         addAdaptorComponentsData = function()
#         {
#             cat("Process insertions into ComponentAdaptor table...")
#             data <- read.csv.sql("Dataset/comp_adaptor.csv", sql = "SELECT component_id, component_type_id, adaptor_angle, overall_length, 
#                                                              end_form_id_1, connection_type_id_1, length_1, thread_size_1, thread_pitch_1, nominal_size_1, 
#                                                              end_form_id_2, connection_type_id_2, length_2, thread_size_2, thread_pitch_2, nominal_size_2, 
#                                                              hex_size, unique_feature, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$adaptor_angle <- ifelse(data$adaptor_angle == "NA", "NULL", data$adaptor_angle)
#             data$overall_length <- ifelse(data$overall_length == "NA", "NULL", data$overall_length)
#             
#             data$end_form_id_1 <- as.integer(substring(data$end_form_id_1, 3))
#             data$connection_type_id_1 <- ifelse(data$connection_type_id_1 == "NA", "NULL", as.integer(substring(data$connection_type_id_1, 3)))
#             data$length_1 <- ifelse(data$length_1 == "NA", "NULL", data$length_1)
#             data$thread_size_1 <- ifelse(data$thread_size_1 == "NA", "NULL", data$thread_size_1)
#             data$thread_pitch_1 <- ifelse(data$thread_pitch_1 == "NA", "NULL", data$thread_pitch_1)
#             data$nominal_size_1 <- ifelse(data$nominal_size_1 == "NA", "NULL", data$nominal_size_1)
#             
#             pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
#             pk_end_form_other <- private$database$getPkValueFromName("EndFormType", "name", "Other")
#             data$end_form_id_2 <- ifelse(data$end_form_id_2 == 9999, pk_end_form_other, as.integer(substring(data$end_form_id_2, 3)))
#             data$connection_type_id_2 <- ifelse(data$connection_type_id_2 == 9999, pk_connection_other, 
#                                                 ifelse(data$connection_type_id_2 == "NA", "NULL", as.integer(substring(data$connection_type_id_2, 3))))
#             data$length_2 <- ifelse(data$length_2 == "NA", "NULL", data$length_2)
#             data$thread_size_2 <- ifelse(data$thread_size_2 %in% c("NA", "9999"), "NULL", data$thread_size_2)
#             data$thread_pitch_2 <- ifelse(data$thread_pitch_2 %in% c("NA", "9999"), "NULL", data$thread_pitch_2)
#             data$nominal_size_2 <- ifelse(data$nominal_size_2 == "NA", "NULL", data$nominal_size_2)
#             
#             data$hex_size <- ifelse(data$hex_size == "NA", "NULL", data$hex_size)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentAdaptor", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_boss.csv to the table ComponentBoss in the Caterpillar database.
#         addBossComponentsData = function()
#         {
#             cat("Process insertions into ComponentBoss table...")
#             data <- read.csv.sql("Dataset/comp_boss.csv", sql = "SELECT component_id, component_type_id, type, connection_type_id, outside_shape, base_type, 
#                                                                         height_over_tube, bolt_pattern_long, bolt_pattern_wide, groove, base_diameter, 
#                                                                         shoulder_diameter, unique_feature, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$type <- ifelse(data$type == "NA", "NULL", paste0("'", data$type, "'"))
#             
#             pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
#             data$connection_type_id <- ifelse(data$connection_type_id == 9999, pk_connection_other, as.integer(substring(data$connection_type_id, 3)))
#             data$outside_shape <- ifelse(data$outside_shape == "NA", "NULL", paste0("'", data$outside_shape, "'"))
#             data$base_type <- ifelse(data$base_type == "NA", "NULL", paste0("'", data$base_type, "'"))
#             data$bolt_pattern_long <- ifelse(data$bolt_pattern_long == "NA", "NULL", data$bolt_pattern_long)
#             data$bolt_pattern_wide <- ifelse(data$bolt_pattern_wide == "NA", "NULL", data$bolt_pattern_wide)
#             data$groove <- ifelse(data$groove == "Yes", 1, 0)
#             data$base_diameter <- ifelse(data$base_diameter == "NA", "NULL", data$base_diameter)
#             data$shoulder_diameter <- ifelse(data$shoulder_diameter == "NA", "NULL", data$shoulder_diameter)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentBoss", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_elbow.csv to the table ComponentElbow in the Caterpillar database.
#         addElbowComponentsData = function()
#         {
#             cat("Process insertions into ComponentElbow table...")
#             data <- read.csv.sql("Dataset/comp_elbow.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, extension_length, 
#                                                                          overall_length, thickness, drop_length, elbow_angle, mj_class_code, mj_plug_class_code, 
#                                                                          plug_diameter, groove, unique_feature, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$bolt_pattern_long <- ifelse(data$bolt_pattern_long == "NA", "NULL", data$bolt_pattern_long)
#             data$bolt_pattern_wide <- ifelse(data$bolt_pattern_wide == "NA", "NULL", data$bolt_pattern_wide)
#             data$extension_length <- ifelse(data$extension_length == "NA", "NULL", data$extension_length)
#             data$overall_length <- ifelse(data$overall_length == "NA", "NULL", data$overall_length)
#             data$thickness <- ifelse(data$thickness == "NA", "NULL", data$thickness)
#             data$drop_length <- ifelse(data$drop_length == "NA", "NULL", data$drop_length)
#             data$elbow_angle <- ifelse(data$elbow_angle == "NA", "NULL", data$elbow_angle)
#             data$mj_class_code <- ifelse(data$mj_class_code == "NA", "NULL", paste0("'", data$mj_class_code, "'"))
#             data$mj_plug_class_code <- ifelse(data$mj_plug_class_code == "NA", "NULL", paste0("'", data$mj_plug_class_code, "'"))
#             data$plug_diameter <- ifelse(data$plug_diameter == "NA", "NULL", data$plug_diameter)
#             data$groove <- ifelse(data$groove == "Yes", 1, 0)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentElbow", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_float.csv to the table ComponentFloat in the Caterpillar database.
#         addFloatComponentsData = function()
#         {
#             cat("Process insertions into ComponentFloat table...")
#             data <- read.csv.sql("Dataset/comp_float.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, thickness, 
#                                                                          orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentFloat", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_hfl.csv to the table ComponentHfl in the Caterpillar database.
#         addHflComponentsData = function()
#         {
#             cat("Process insertions into ComponentHfl table...")
#             data <- read.csv.sql("Dataset/comp_hfl.csv", sql = "SELECT component_id, component_type_id, hose_diameter, corresponding_shell, coupling_class, 
#                                                                        material, plating, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$corresponding_shell <- as.integer(substring(data$corresponding_shell, 3))
#             data$coupling_class <- paste0("'", data$coupling_class, "'")
#             data$material <- paste0("'", data$material, "'")
#             data$plating <- ifelse(data$plating == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentHfl", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_nut.csv to the table ComponentNut in the Caterpillar database.
#         addNutComponentsData = function()
#         {
#             cat("Process insertions into ComponentNut table...")
#             data <- read.csv.sql("Dataset/comp_nut.csv", sql = "SELECT component_id, component_type_id, hex_nut_size, seat_angle, length, thread_size, 
#                                                                        thread_pitch, diameter, blind_hole, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$hex_nut_size <- ifelse(data$hex_nut_size == "NA", "NULL", data$hex_nut_size)
#             data$seat_angle <- ifelse(data$seat_angle == "NA", "NULL", data$seat_angle)
#             data$thread_size <- ifelse(substring(data$thread_size, 1, 1) == "M", substring(data$thread_size, 2), data$thread_size)
#             data$diameter <- ifelse(data$diameter == "NA", "NULL", data$diameter)
#             data$blind_hole <- ifelse(data$blind_hole == "NA", "NULL", ifelse(data$blind_hole == "Yes", 1, 0))
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentNut", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_sleeve.csv to the table ComponentSleeve in the Caterpillar database.
#         addSleeveComponentsData = function()
#         {
#             cat("Process insertions into ComponentSleeve table...")
#             data <- read.csv.sql("Dataset/comp_sleeve.csv", sql = "SELECT component_id, component_type_id, connection_type_id, length, intended_nut_thread, 
#                                                                           intended_nut_pitch, unique_feature, plating, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$connection_type_id <- as.integer(substring(data$connection_type_id, 3))
#             data$length <- ifelse(data$length == 9999, "NULL", data$length)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$plating <- ifelse(data$plating == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentSleeve", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_straight.csv to the table ComponentStraight in the Caterpillar database.
#         addStraightComponentsData = function()
#         {
#             cat("Process insertions into ComponentStraight table...")
#             data <- read.csv.sql("Dataset/comp_straight.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, head_diameter,
#                                                                             overall_length, thickness, mj_class_code, groove, unique_feature, orientation, 
#                                                                             weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- as.integer(substring(data$component_type_id, 4))
#             data$bolt_pattern_long <- ifelse(data$bolt_pattern_long == "NA", "NULL", data$bolt_pattern_long)
#             data$bolt_pattern_wide <- ifelse(data$bolt_pattern_wide == "NA", "NULL", data$bolt_pattern_wide)
#             data$head_diameter <- ifelse(data$head_diameter == "NA", "NULL", data$head_diameter)
#             data$overall_length <- ifelse(data$overall_length == "NA", "NULL", data$overall_length)
#             data$mj_class_code <- ifelse(data$mj_class_code == "NA", "NULL", paste0("'", data$mj_class_code, "'"))
#             data$groove <- ifelse(data$groove == "Yes", 1, 0)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             data$weight <- ifelse(data$weight == "NA", "NULL", data$weight)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentStraight", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_tee.csv to the table ComponentTee in the Caterpillar database.
#         addTeeComponentsData = function()
#         {
#             cat("Process insertions into ComponentTee table...")
#             data <- read.csv.sql("Dataset/comp_tee.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, extension_length, 
#                                                                        overall_length, thickness, drop_length, mj_class_code, mj_plug_class_code, groove, 
#                                                                        unique_feature, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data <- cbind(primary_key = "NULL", data)
#             data$component_id <- as.integer(substring(data$component_id, 3))
#             data$component_type_id <- private$database$getPkValueFromName("ComponentType", "name", "Other")
#             data$mj_class_code <- paste0("'", data$mj_class_code, "'")
#             data$mj_plug_class_code <- paste0("'", data$mj_plug_class_code, "'")
#             data$groove <- ifelse(data$groove == "Yes", 1, 0)
#             data$unique_feature <- ifelse(data$unique_feature == "Yes", 1, 0)
#             data$orientation <- ifelse(data$orientation == "Yes", 1, 0)
#             
#             rows_values <- apply(data, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentTee", values)
#             
#             cat("DONE\n")
#         },
#         
#         ## Add all rows from the file Dataset/comp_threaded.csv to the table ComponentThreaded in the Caterpillar database.
#         addThreadedComponentsData = function()
#         {
#             cat("Process insertions into ComponentThreaded and Component_Connection table...")
#             data <- read.csv.sql("Dataset/comp_threaded.csv", sql = "SELECT component_id, component_type_id, adaptor_angle, overall_length, hex_size, 
#                                  end_form_id_1, connection_type_id_1, length_1, thread_size_1, thread_pitch_1, nominal_size_1, 
#                                  end_form_id_2, connection_type_id_2, length_2, thread_size_2, thread_pitch_2, nominal_size_2, 
#                                  end_form_id_3, connection_type_id_3, length_3, thread_size_3, thread_pitch_3, nominal_size_3, 
#                                  end_form_id_4, connection_type_id_4, length_4, thread_size_4, thread_pitch_4, nominal_size_4, 
#                                  unique_feature, orientation, weight FROM file")
#             
#             ## Transform the data.
#             data_threaded <- data[, c("component_id", "component_type_id", "adaptor_angle", "overall_length", "hex_size", 
#                                       "unique_feature", "orientation", "weight")]
#             data_threaded <- cbind(primary_key = "NULL", data_threaded)
#             data_threaded$component_id <- as.integer(substring(data_threaded$component_id, 3))
#             data_threaded$component_type_id <- as.integer(substring(data_threaded$component_type_id, 4))
#             data_threaded$adaptor_angle <- ifelse(data_threaded$adaptor_angle == "NA", "NULL", data_threaded$adaptor_angle)
#             data_threaded$overall_length <- ifelse(data_threaded$overall_length == "NA", "NULL", data_threaded$overall_length)
#             data_threaded$hex_size <- ifelse(data_threaded$hex_size == "NA", "NULL", data_threaded$hex_size)
#             data_threaded$unique_feature <- ifelse(data_threaded$unique_feature == "Yes", 1, 0)
#             data_threaded$orientation <- ifelse(data_threaded$orientation == "Yes", 1, 0)
#             data_threaded$weight <- ifelse(data_threaded$weight == "NA", "NULL", data_threaded$weight)
#             
#             rows_values <- apply(data_threaded, 1, paste, collapse = ",")
#             values <- paste(rows_values, collapse = "),(")
#             private$database$insertIntoTable("ComponentThreaded", values)
#             
#             private$addThreadedConnectionsData(data, data_threaded)
#             
#             cat("DONE\n")
#         }
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