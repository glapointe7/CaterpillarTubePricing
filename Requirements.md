# Technical & Functional Requirements

## Project
Company: Caterpillar

Subject group: Industrial Engineering

The objective of this project is to predict the price a supplier will quote for a given tube assembly. Like snowflakes, it's difficult to find two tubes in Caterpillar's diverse catalogue of machinery that are exactly alike. Tubes can vary across a number of dimensions, including base materials, number of bends, bend radius, bolt patterns, and end types. Currently, Caterpillar relies on a variety of suppliers to manufacture these tube assemblies, each having their own unique pricing model.

The data are certified valid and are found [here](https://www.kaggle.com/c/caterpillar-tube-pricing/data).


## Technologies
In this section, we write the list of languages and softwares that will be used for this project. We give also other important details like the configuration of softwares, computer details and the server where the project is stored.

#### Languages

* MySQL 5.5.44 to store the data since the entire dataset is small enough (approximatively 6.8 Mb)
* R version 3.2.1 (2015-06-18) to produce the analysis code and graphics
* LaTeX with TeX Live 2013/Debian

#### Softwares

* MySQL WorkBench version 6.0.8.11354
* RStudio Version 0.99.465

#### Configuration details
The configuration details for MySQL will be set considering we will create tables once and we will insert a lot of data. Once it will be done, all queries will be selections of data. Since the data integrity is very important, MyISAM engine cannot be used. Therefore, we will use the InnoDB engine. 

Connection details:

* Connection method = TCP/IP
* Hostname = localhost
* Port = 3306

R main Packages used for this project are:

* ggplot2
* dplyr
* RMySQL
* R6
* sqldf
* xtable
* knitr

If they are not installed, then use `install.packages("PackageName")` to get the package PackageName installed.


#### Operating Systems used

* Linux Mint 17.1
* Microsoft Windows 7, 8, 8.1 and 10

#### Project Server
The project files will be stored in github under the folder [CaterpillarTubePricing](https://github.com/glapointe7/CaterpillarTubePricing)

#### Versioning System
We will use GIT version 1.9.1 as our versioning system.

Once a functional requirement is done (means it is tested and considered as valid), we will create a tag with a valid name (refer to the Naming Convention section below). Therefore, the `master` branch will be updated with the changes from the new tag. 

We will create a branch named `Development` where we will put reproductible analysis and all documents and codes used for the projects. The `master` branch must contain the documents representing the functional requirements (see last section of this document) and other important documents like the license for example.


## Functional Requirements

* F-01: Write a Code Book describing the dataset and its files and variables used from the dataset received as input.
* F-02: Create the relational scheme of the database from the dataset given as input.
* F-03: Group and clean data (also apply renaming following a naming convension) from the dataset and create the database.
* F-04: Insert data from the dataset in the database and keep the script as the output.
* F-05: Identify variables needed for the analysis and explain why they will be more important for the analysis (independant and dependant variables).
* F-06: Following the goal provided in the project summary, identify possible methods or models that can be applied to solve the problem and why they are considered.
* F-07: With the variables identified and list of models found, modelize the problem mathematically and explain every step.
* F-08: With the dataset obtained after F-03 as input, test the model to this dataset and show graphically the results with explanations.
* F-09: Compare results with the goal to reach and explain why the model succeed or failed. If it fails, keep track and start again from F-04.
* F-10: If the model succeed, simplify the analysis in terms of business and show how big the difference is.
* F-11: Conclude by recommanding the successful model and explain the advantages for the company to use it.
