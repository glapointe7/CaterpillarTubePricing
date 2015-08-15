# Technical & Functional Requirements

## Project
Company: Caterpillar

Subject group: Industrial Engineering

The objective of this project is to predict the price a supplier will quote for a given tube assembly. Like snowflakes, it's difficult to find two tubes in Caterpillar's diverse catalogue of machinery that are exactly alike. Tubes can vary across a number of dimensions, including base materials, number of bends, bend radius, bolt patterns, and end types. Currently, Caterpillar relies on a variety of suppliers to manufacture these tube assemblies, each having their own unique pricing model.

The data are certified valid and are found [here](https://www.kaggle.com/c/caterpillar-tube-pricing/data).


## Technologies
In this section, we write the list of languages and softwares that will be used for this project. We give also other important details like the configuration of softwares, computer details and the server where the project is stored.

#### Languages

* MySQL 5.5.44 to store the data since the entire dataset is small (approximatively 6.8 Mb)
* R to produce the analysis code and graphics
* Python 3.4

#### Sofwares

* MySQL WorkBench version 6.0.8.11354
* RStudio Version 0.99.465
* IDLE Version 3.4.0
* Dia to build the relational schema of the database and other schemas if needed
* [XMind 6](www.xmind.net/download/)

#### Configuration details
The configuration details for MySQL will be set considering we will create tables once and we will insert a lot of data. Once it will be done, all queries will be selections of data. Since the data integrity is very important, MyISAM engine cannot be used. Therefore, we will use the InnoDB engine. 

R Packages used for this project are:

* ggplot2
* dplyr
* RMySQL

*TBD*

#### Type of computer used

* Processor: Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz
* Cores: 4
* RAM: 8 GB
* Company Name: HP (Hewlett-Packard)

#### Operating Systems used

* Linux Mint 17.1
* Microsoft Windows 7, 8, 8.1 and 10

#### Project Server
The project files will be stored in github under the folder [CaterpillarTubePricing](https://github.com/glapointe7/CaterpillarTubePricing)

#### Versioning System
We will use GIT version 1.9.1 as our versioning system.

Once a functional requirement is done (means it is tested and considered as valid), we will create a tag with a valid name (refer to the Naming Convention section below). Therefore, the `master` branch will be updated with the changes from the new tag. 

We will create a branch named `Development` where we will put reproductible analysis and all documents and codes used for the projects. The `master` branch must contain the documents representing the functional requirements (see last section of this document) and other important documents like the license for example.

## Naming Convension
For the database:

* Database: Upper camel case (AaaaaBbbbb)
* Tables: Upper camel case (AaaaaBbbbb)
* Cross reference tables: Aaaaa_Bbbbb
* Fields: Lower camel case (aaaaaBbbbb)
* Primary keys: pkTableName
* Foreign keys: fkTableName

For the R language we will use tabulation of 4 spaces as indentation:

* Functions: aaaaBbbbb
* Function parameters: aaaa_bbbb
* Local variables: aaaa_bbbb
* Constants: AAAA_BBBB
* Lists: AaaaaBbbbb
* Dataset: Aaaaa_Bbbbb

For the Python language we will use tabulation of 4 spaces as indentation:

* Functions: aaaaBbbbb
* Function parameters: aaaa_bbbb
* Local variables: aaaa_bbbb
* Constants: AAAA_BBBB
* Arrays: Aaaaa_Bbbbb
* Classes: AaaaaBbbbb

The tag created with GIT must be in this format: V[x].[y]\_[date of tag creation], where `x` is the major version starting at `0`, `y` is the minor version starting at `1` (can be related with a functional requirement ID) and date of tag creation is in the format Mmmjjaaaa. Here is an example of a valid tag: V0.1\_Aug142015.

Note that if the project is not finished, then the version must be set to `0`. When the project is finished but need optimization, then major version greater than `0` is valid.

The branches used will be `master` and `Development`.


## Database Structure
This is the [relational schema of the database](https://github.com/glapointe7/CaterpillarTubePricing/blob/master/Caterpillar.dia).

## Functional Requirements

* F-01: Write a Code Book describing the dataset and its files and variables used from the dataset received as input.
* F-02: Create the relational scheme of the database from the dataset given as input.
* F-03: Group and clean data (also apply renaming following a naming convension) from the dataset and create the database.
* F-04: Identify variables needed for the analysis and explain why they will be more important for the analysis (independant and dependant variables).
* F-05: Following the goal provided in the project summary, identify possible methods or models that can be applied to solve the problem and why they are considered.
* F-06: With the variables identified and list of models found, modelize the problem mathematically and explain every step.
* F-07: With the dataset obtained after F-03 as input, apply the model to this dataset and show graphically the results with explanations.
* F-08: Compare results with the goal to reach and explain why the model succeed or failed. If it fails, keep track and start again from F-04.
* F-09: If the model succeed, simplify the analysis in terms of business and show how big the difference is.
* F-10: Conclude by recommanding the successful model and explain the advantages for the company to use it.
