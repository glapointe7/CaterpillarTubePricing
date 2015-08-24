source("DatabaseManipulation.R")

## To perform SQL selection queries on csv file reading.
library(sqldf)

## Transform a (Yes/No) or (Y/N) data to (0/1). The N/A case returns NULL.
transformToBit <- function(data)
{
    switch(
        data,
        Yes = 1,
        Y = 1,
        No = 0,
        N = 0,
        "NA" = "NULL"
    )
}

## Convert values 9999, NA or others from the dataset to the one corresponding for the MySQL database.
convertSpecialValues <- function(data, pk_other)
{
    switch(
        data,
        "9999" = pk_other,
        "NA"   = "NULL",
        as.integer(substring(data, 3))
    )
}

#####################################################################
# Class to insert data in tables of the Caterpillar database.
#####################################################################
CaterpillarTables <- R6Class("CaterpillarTables",
    private = list(
        database = NULL,
        
        ## Build a string of specs used by a tube assembly.
        addSpecsUsedInTubeAssembly = function(Tube_Specs_Row)
        {
            ## Open the file once and store data in a dataframe should be faster by using data[i] which is the ith tube assembly.
            #pk_tube <- paste("TA-", formatC(tube_id, width = 5, format = "d", flag = "0"), sep = "")
            #query <- paste("SELECT spec1, spec2, spec3, spec4, spec5, spec6, spec7, spec8, spec9, spec10 FROM file WHERE tube_assembly_id = '", pk_tube, "'", sep = "")
            #data <- read.csv.sql("Dataset/specs.csv", sql = query)
            
            ## There are a maximum of 10 specs and a minimum of 0 spec for each tube assembly.
            specs <- ""
            i <- 1
            spec_value <- Tube_Specs_Row[1, paste("spec", i, sep = "")]
            while(spec_value != "NA" && i <= 10)
            {
                specs <- paste(specs, Tube_Specs_Row[1, paste("spec", i, sep = "")], sep = ",")
                i <- i + 1
                spec_value <- Tube_Specs_Row[1, paste("spec", i, sep = "")]
            }
            
            specs
        }
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
                data <- read.csv.sql(paste("Dataset/type_", type, ".csv", sep = ""), sql = "SELECT name FROM file")
                for(i in 1:nrow(data))
                {
                    Values_List <- c(
                        "NULL",
                        paste("'", data[i, "name"], "'", sep = "")
                    )
                    private$database$insertIntoTable(Types_List[[type]], Values_List)
                }
                
                ## Insert the component type 'OTHER' since there's no such type defined, but it is used in every component file.
                if(type == "component")
                {
                    private$database$insertIntoTable(Types_List[[type]], c("NULL", "'Other'"))
                }
            }
        },
        
        ## Add all rows from the file Dataset/components.csv to the table Components in the Caterpillar database.
        addAllComponentsData = function()
        {
            data <- read.csv.sql("Dataset/components.csv", sql = "SELECT name, component_type_id FROM file")
            pk_component_type <- private$database$getPkValueFromName("ComponentType", "name", "Other")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    paste("'", data[i, "name"], "'", sep = ""), 
                    ifelse(data[i, "component_type_id"] == "OTHER", pk_component_type, as.integer(substring(data[i, "component_type_id"], 4)))
                )
                private$database$insertIntoTable("Component", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/tube_end_form.csv to the table TubeEndForm in the Caterpillar database.
        addEndTubeFormData = function()
        {
            data <- read.csv.sql("Dataset/tube_end_form.csv", sql = "SELECT forming FROM file")
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    transformToBit(data[i, "forming"])
                )
                private$database$insertIntoTable("TubeEndForm", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/tube.csv to the table TubeAssembly in the Caterpillar database.
        addTubeAssemblyData = function()
        {
            data <- read.csv.sql("Dataset/tube.csv", sql = "SELECT material_id, diameter, wall, length, num_bends, bend_radius, end_a_1x, end_a_2x, 
                                                                   end_x_1x, end_x_2x, end_a, end_x, num_boss, num_bracket, other FROM file")
            
            query <- "SELECT spec1, spec2, spec3, spec4, spec5, spec6, spec7, spec8, spec9, spec10 FROM file"
            data_specs <- read.csv.sql("Dataset/specs.csv", sql = query)
            
            for(i in 1:nrow(data))
            {
                specs <- private$addSpecsUsedInTubeAssembly(data_specs[i, ])
                Values_List <- c(
                    "NULL",
                    ifelse(data[i, "material_id"] == "NA", "NULL", paste("'", data[i, "material_id"], "'", sep = "")),
                    ifelse(data[i, "diameter"] == "NA", "NULL", data[i, "diameter"]),
                    ifelse(data[i, "wall"] == "NA", "NULL", data[i, "wall"]),
                    ifelse(data[i, "length"] == "NA", "NULL", data[i, "length"]),
                    ifelse(data[i, "num_bends"] == "NA", "NULL", data[i, "num_bends"]),
                    ifelse(data[i, "bend_radius"] == "NA", "NULL", data[i, "bend_radius"]),
                    transformToBit(data[i, "end_a_1x"]),
                    transformToBit(data[i, "end_a_2x"]),
                    transformToBit(data[i, "end_x_1x"]),
                    transformToBit(data[i, "end_x_2x"]),
                    ifelse(data[i, "end_a"] == "NONE", "NULL", as.integer(substring(data[i, "end_a"], 4))),
                    ifelse(data[i, "end_x"] == "NONE", "NULL", as.integer(substring(data[i, "end_x"], 4))),
                    data[i, "num_boss"],
                    data[i, "num_bracket"],
                    data[i, "other"],
                    ifelse(specs == "", "NULL", paste("'", specs, "'", sep = ""))
                )
                private$database$insertIntoTable("TubeAssembly", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/train_set.csv to the table TubeAssemblyPricing in the Caterpillar database.
        addTubeAssemblyPricingData = function()
        {
            data <- read.csv.sql("Dataset/train_set.csv", sql = "SELECT tube_assembly_id, supplier, quote_date, annual_usage, min_order_quantity, 
                                                                        bracket_pricing, quantity, cost FROM file")
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "tube_assembly_id"], 4)),
                    paste("'", data[i, "supplier"], "'", sep = ""),
                    paste("'", data[i, "quote_date"], "'", sep = ""),
                    data[i, "annual_usage"],
                    data[i, "min_order_quantity"],
                    transformToBit(data[i, "bracket_pricing"]),
                    data[i, "quantity"],
                    data[i, "cost"]
                )
                private$database$insertIntoTable("TubeAssemblyPricing", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/bill_of_materials.csv to the table TubeAssembly_Component in the Caterpillar database.
        addBillOfMaterialsData = function()
        {
            query <- "SELECT tube_assembly_id, component_id_1, quantity_1, component_id_2, quantity_2, component_id_3, quantity_3, component_id_4, quantity_4, 
                             component_id_5, quantity_5, component_id_6, quantity_6, component_id_7, quantity_7, component_id_8, quantity_8 FROM file"
            data <- read.csv.sql("Dataset/bill_of_materials.csv", sql = query)
            for(i in 1:nrow(data))
            {
                ## If the tube doesn't contain any component, we insert only the tube assembly ID.
                tube_id <- as.integer(substring(data[i, "tube_assembly_id"], 4))
                component_id <- data[i, "component_id_1"]
                if(component_id == "NA")
                {
                    Values_List <- c(
                        tube_id,
                        "NULL",
                        "NULL"
                    )
                    private$database$insertIntoTable("TubeAssemblyPricing", Values_List)
                }
                else
                {
                    j <- 1
                    while(component_id != "NA")
                    {
                        Values_List <- c(
                            tube_id,
                            as.integer(substring(component_id, 3)),
                            data[i, paste("quantity_", j, sep = "")]
                        )
                        private$database$insertIntoTable("TubeAssembly_Component", Values_List)
                        
                        j <- j + 1
                        component_id <- data[i, paste("component_id_", j, sep = "")]
                    }
                }
            }
        },
        
        ## Add all rows from the file Dataset/comp_other.csv to the table ComponentOther in the Caterpillar database.
        addOtherComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_other.csv", sql = "SELECT component_id, part_name, weight FROM file")
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    paste("'", data[i, "part_name"], "'", sep = ""),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentOther", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_adaptor.csv to the table ComponentAdaptor in the Caterpillar database.
        addAdaptorComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_adaptor.csv", sql = "SELECT component_id, component_type_id, adaptor_angle, overall_length, 
                                                             end_form_id_1, connection_type_id_1, length_1, thread_size_1, thread_pitch_1, nominal_size_1, 
                                                             end_form_id_2, connection_type_id_2, length_2, thread_size_2, thread_pitch_2, nominal_size_2, 
                                                             hex_size, unique_feature, orientation, weight FROM file")
            pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
            pk_end_form_other <- private$database$getPkValueFromName("EndFormType", "name", "Other")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "adaptor_angle"] == "NA", "NULL", data[i, "adaptor_angle"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    
                    convertSpecialValues(data[i, "end_form_id_1"], pk_end_form_other),
                    convertSpecialValues(data[i, "connection_type_id_1"], pk_connection_other),
                    
                    ifelse(data[i, "length_1"] == "NA", "NULL", data[i, "length_1"]),
                    ifelse(data[i, "thread_size_1"] == "NA", "NULL", data[i, "thread_size_1"]),
                    ifelse(data[i, "thread_pitch_1"] == "NA", "NULL", data[i, "thread_pitch_1"]),
                    ifelse(data[i, "nominal_size_1"] == "NA", "NULL", data[i, "nominal_size_1"]),
                    
                    convertSpecialValues(data[i, "end_form_id_2"], pk_end_form_other),
                    convertSpecialValues(data[i, "connection_type_id_2"], pk_connection_other),
                    
                    ifelse(data[i, "length_2"] == "NA", "NULL", data[i, "length_2"]),
                    ifelse(data[i, "thread_size_2"] == "NA", "NULL", data[i, "thread_size_2"]),
                    ifelse(data[i, "thread_pitch_2"] == "NA", "NULL", data[i, "thread_pitch_2"]),
                    ifelse(data[i, "nominal_size_2"] == "NA", "NULL", data[i, "nominal_size_2"]),
                    ifelse(data[i, "hex_size"] == "NA", "NULL", data[i, "hex_size"]),
                    transformToBit(data[i, "unique_feature"]),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentAdaptor", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_boss.csv to the table ComponentBoss in the Caterpillar database.
        addBossComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_boss.csv", sql = "SELECT component_id, component_type_id, type, connection_type_id, outside_shape, base_type, 
                                                                        height_over_tube, bolt_pattern_long, bolt_pattern_wide, groove, base_diameter, 
                                                                        shoulder_diameter, unique_feature, orientation, weight FROM file")
            pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "type"] == "NA", "NULL", data[i, "type"]),
                    
                    convertSpecialValues(data[i, "connection_type_id"], pk_connection_other),
                    
                    ifelse(data[i, "outside_shape"] == "NA", "NULL", paste("'", data[i, "outside_shape"], "'", sep = "")),
                    ifelse(data[i, "base_type"] == "NA", "NULL", paste("'", data[i, "base_type"], "'", sep = "")),
                    ifelse(data[i, "height_over_tube"] == "NA", "NULL", data[i, "height_over_tube"]),
                    ifelse(data[i, "bolt_pattern_long"] == "NA", "NULL", data[i, "bolt_pattern_long"]),
                    ifelse(data[i, "bolt_pattern_wide"] == "NA", "NULL", data[i, "bolt_pattern_wide"]),
                    transformToBit(data[i, "groove"]),
                    ifelse(data[i, "base_diameter"] == "NA", "NULL", data[i, "base_diameter"]),
                    ifelse(data[i, "shoulder_diameter"] == "NA", "NULL", data[i, "shoulder_diameter"]),
                    transformToBit(data[i, "unique_feature"]),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentBoss", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_elbow.csv to the table ComponentElbow in the Caterpillar database.
        addElbowComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_elbow.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, extension_length, 
                                                                         overall_length, thickness, drop_length, elbow_angle, mj_class_code, mj_plug_class_code, 
                                                                         plug_diameter, groove, unique_feature, orientation, weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "bolt_pattern_long"] == "NA", "NULL", data[i, "bolt_pattern_long"]),
                    ifelse(data[i, "bolt_pattern_wide"] == "NA", "NULL", data[i, "bolt_pattern_wide"]),
                    ifelse(data[i, "extension_length"] == "NA", "NULL", data[i, "extension_length"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    ifelse(data[i, "thickness"] == "NA", "NULL", data[i, "thickness"]),
                    ifelse(data[i, "drop_length"] == "NA", "NULL", data[i, "drop_length"]),
                    ifelse(data[i, "elbow_angle"] == "NA", "NULL", data[i, "elbow_angle"]),
                    ifelse(data[i, "mj_class_code"] == "NA", "NULL", paste("'", data[i, "mj_class_code"], "'", sep = "")),
                    ifelse(data[i, "mj_plug_class_code"] == "NA", "NULL", paste("'", data[i, "mj_plug_class_code"], "'", sep = "")),
                    ifelse(data[i, "plug_diameter"] == "NA", "NULL", data[i, "plug_diameter"]),
                    transformToBit(data[i, "groove"]),
                    transformToBit(data[i, "unique_feature"]),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentElbow", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_float.csv to the table ComponentFloat in the Caterpillar database.
        addFloatComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_float.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, thickness, 
                                                                         orientation, weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "bolt_pattern_long"] == "NA", "NULL", data[i, "bolt_pattern_long"]),
                    ifelse(data[i, "bolt_pattern_wide"] == "NA", "NULL", data[i, "bolt_pattern_wide"]),
                    ifelse(data[i, "extension_length"] == "NA", "NULL", data[i, "extension_length"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    ifelse(data[i, "thickness"] == "NA", "NULL", data[i, "thickness"]),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentFloat", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_hfl.csv to the table ComponentHfl in the Caterpillar database.
        addHflComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_hfl.csv", sql = "SELECT component_id, component_type_id, hose_diameter, corresponding_shell, coupling_class, 
                                                                       material, plating, orientation, weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "hose_diameter"] == "NA", "NULL", data[i, "hose_diameter"]),
                    as.integer(substring(data[i, "corresponding_shell"], 3)),
                    ifelse(data[i, "coupling_class"] == "NA", "NULL", paste("'", data[i, "coupling_class"], "'")),
                    ifelse(data[i, "material"] == "NA", "NULL", paste("'", data[i, "material"], "'")),
                    ifelse(data[i, "plating"] == "NA", "NULL", transformToBit(data[i, "plating"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentHfl", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_nut.csv to the table ComponentNut in the Caterpillar database.
        addNutComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_nut.csv", sql = "SELECT component_id, component_type_id, hex_nut_size, seat_angle, length, thread_size, 
                                                                       thread_pitch, diameter, blind_hole, orientation, weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "hex_nut_size"] == "NA", "NULL", data[i, "hose_diameter"]),
                    ifelse(data[i, "seat_angle"] == "NA", "NULL", data[i, "seat_angle"]),
                    ifelse(data[i, "length"] == "NA", "NULL", data[i, "length"]),
                    ifelse(data[i, "thread_size"] == "NA", "NULL", data[i, "thread_size"]),
                    ifelse(data[i, "thread_pitch"] == "NA", "NULL", data[i, "thread_pitch"]),
                    ifelse(data[i, "diameter"] == "NA", "NULL", data[i, "diameter"]),
                    ifelse(data[i, "blind_hole"] == "NA", "NULL", transformToBit(data[i, "blind_hole"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentNut", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_sleeve.csv to the table ComponentSleeve in the Caterpillar database.
        addSleeveComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_sleeve.csv", sql = "SELECT component_id, component_type_id, connection_type_id, length, intended_nut_thread, 
                                                                          intended_nut_pitch, unique_feature, plating, orientation, weight FROM file")
            pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    convertSpecialValues(data[i, "connection_type_id"], pk_connection_other),
                    ifelse(data[i, "length"] == "NA", "NULL", data[i, "length"]),
                    ifelse(data[i, "intended_nut_thread"] == "NA", "NULL", data[i, "intended_nut_thread"]),
                    ifelse(data[i, "intended_nut_pitch"] == "NA", "NULL", data[i, "intended_nut_pitch"]),
                    ifelse(data[i, "unique_feature"] == "NA", "NULL", transformToBit(data[i, "unique_feature"])),
                    ifelse(data[i, "plating"] == "NA", "NULL", transformToBit(data[i, "plating"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentSleeve", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_straight.csv to the table ComponentStraight in the Caterpillar database.
        addStraightComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_straight.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, head_diameter,
                                                                            overall_length, thickness, mj_class_code, groove, unique_feature, orientation, 
                                                                            weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "bolt_pattern_long"] == "NA", "NULL", data[i, "bolt_pattern_long"]),
                    ifelse(data[i, "bolt_pattern_wide"] == "NA", "NULL", data[i, "bolt_pattern_wide"]),
                    ifelse(data[i, "head_diameter"] == "NA", "NULL", data[i, "head_diameter"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    ifelse(data[i, "mj_class_code"] == "NA", "NULL", paste("'", data[i, "mj_class_code"], "'")),
                    ifelse(data[i, "groove"] == "NA", "NULL", transformToBit(data[i, "groove"])),
                    ifelse(data[i, "unique_feature"] == "NA", "NULL", transformToBit(data[i, "unique_feature"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentStraight", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_tee.csv to the table ComponentTee in the Caterpillar database.
        addTeeComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_tee.csv", sql = "SELECT component_id, component_type_id, bolt_pattern_long, bolt_pattern_wide, extension_length, 
                                                                       overall_length, thickness, drop_length, mj_class_code, mj_plug_class_code, groove, 
                                                                       unique_feature, orientation, weight FROM file")
            
            for(i in 1:nrow(data))
            {
                Values_List <- c(
                    "NULL",
                    as.integer(substring(data[i, "component_id"], 3)),
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "bolt_pattern_long"] == "NA", "NULL", data[i, "bolt_pattern_long"]),
                    ifelse(data[i, "bolt_pattern_wide"] == "NA", "NULL", data[i, "bolt_pattern_wide"]),
                    ifelse(data[i, "extension_length"] == "NA", "NULL", data[i, "extension_length"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    ifelse(data[i, "thickness"] == "NA", "NULL", data[i, "thickness"]),
                    ifelse(data[i, "drop_length"] == "NA", "NULL", data[i, "drop_length"]),
                    ifelse(data[i, "mj_class_code"] == "NA", "NULL", paste("'", data[i, "mj_class_code"], "'")),
                    ifelse(data[i, "mj_plug_class_code"] == "NA", "NULL", paste("'", data[i, "mj_plug_class_code"], "'")),
                    ifelse(data[i, "groove"] == "NA", "NULL", transformToBit(data[i, "groove"])),
                    ifelse(data[i, "unique_feature"] == "NA", "NULL", transformToBit(data[i, "unique_feature"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentTee", Values_List)
            }
        },
        
        ## Add all rows from the file Dataset/comp_threaded.csv to the table ComponentThreaded in the Caterpillar database.
        addThreadedComponentsData = function()
        {
            data <- read.csv.sql("Dataset/comp_threaded.csv", sql = "SELECT component_id, component_type_id, adaptor_angle, overall_length, hex_size, 
                                 end_form_id_1, connection_type_id_1, length_1, thread_size_1, thread_pitch_1, nominal_size_1, 
                                 end_form_id_2, connection_type_id_2, length_2, thread_size_2, thread_pitch_2, nominal_size_2, 
                                 end_form_id_3, connection_type_id_3, length_3, thread_size_3, thread_pitch_3, nominal_size_3, 
                                 end_form_id_4, connection_type_id_4, length_4, thread_size_4, thread_pitch_4, nominal_size_4, 
                                 unique_feature, orientation, weight FROM file")
            pk_end_form_other <- private$database$getPkValueFromName("EndFormType", "name", "Other")
            pk_connection_other <- private$database$getPkValueFromName("ConnectionType", "name", "Other")
            
            for(i in 1:nrow(data))
            {
                component_id <- as.integer(substring(data[i, "component_id"], 3))
                Values_List <- c(
                    "NULL",
                    component_id,
                    as.integer(substring(data[i, "component_type_id"], 4)),
                    ifelse(data[i, "adaptor_angle"] == "NA", "NULL", data[i, "adaptor_angle"]),
                    ifelse(data[i, "overall_length"] == "NA", "NULL", data[i, "overall_length"]),
                    ifelse(data[i, "hex_size"] == "NA", "NULL", data[i, "hex_size"]),
                    ifelse(data[i, "unique_feature"] == "NA", "NULL", transformToBit(data[i, "unique_feature"])),
                    transformToBit(data[i, "orientation"]),
                    ifelse(data[i, "weight"] == "NA", "NULL", data[i, "weight"])
                )
                private$database$insertIntoTable("ComponentThreaded", Values_List)
                
                ## Insert the 4 thread connections in the table 'Component_Connection'.
                fk_thread <- private$database$getPkValueFromName("ConnectionThread", "fkComponent", component_id)
                for(j in 1:4)
                {
                    Thread_Values <- c(
                        fk_thread,
                        convertSpecialValues(data[i, paste("end_form_id_", j, sep = "")], pk_end_form_other),
                        convertSpecialValues(data[i, paste("connection_type_id_", j, sep = "")], pk_connection_other),
                        ifelse(data[i, paste("length_", j, sep = "")] == "NA", "NULL", data[i, paste("length_", j, sep = "")]),
                        ifelse(data[i, paste("thread_size_", j, sep = "")] == "NA", "NULL", data[i, paste("thread_size_", j, sep = "")]),
                        ifelse(data[i, paste("thread_pitch_", j, sep = "")] == "NA", "NULL", data[i, paste("thread_pitch_", j, sep = "")]),
                        ifelse(data[i, paste("nominal_size_", j, sep = "")] == "NA", "NULL", data[i, paste("nominal_size_", j, sep = "")])
                    )
                    private$database$insertIntoTable("Component_Connection", Thread_Values)
                }
            }
        }
    )
)

## After grouping and cleaning data, we insert all data from the dataset in our Caterpillar database.
addDatasetToDatabase <- function()
{
    table <- CaterpillarTables$new()
    table$addAllTypesData()
    table$addAllComponentsData()
    table$addEndTubeFormData()
    table$addTubeAssemblyData()
#     table$addTubeAssemblyPricingData()
#     table$addBillOfMaterialsData()
#     table$addOtherComponentsData()
#     table$addAdaptorComponentsData()
#     table$addBossComponentsData()
#     table$addElbowComponentsData()
#     table$addFloatComponentsData()
#     table$addHflComponentsData()
#     table$addNutComponentsData()
#     table$addSleeveComponentsData()
#     table$addStraightComponentsData()
#     table$addTeeComponentsData()
#     table$addThreadedComponentsData()
    gc()
}