---
title: "Preliminary Analysis"
output: html_document
---

## Project
Company: Caterpillar

Subject group: Industrial Engineering

The objective of this project is to predict the price a supplier will quote for a given tube assembly. Like snowflakes, it's difficult to find two tubes in Caterpillar's diverse catalogue of machinery that are exactly alike. Tubes can vary across a number of dimensions, including base materials, number of bends, bend radius, bolt patterns, and end types. Currently, Caterpillar relies on a variety of suppliers to manufacture these tube assemblies, each having their own unique pricing model.

The data are certified valid and are found [here](https://www.kaggle.com/c/caterpillar-tube-pricing/data).


## Technologies
Here is the list of languages and softwares that will be used for this project. 

#### Languages

* MySQL 5.5.44 to store the data since the entire dataset is approximatively 6.8 Mb
* R to produce the analysis code
* Python 3.4

#### Sofwares

* MySQL WorkBench version 6.0.8.11354
* RStudio Version 0.99.465
* IDLE Version 3.4.0
* Dia to build the relational schema of the database and other schemas if needed

#### Configuration details
The configuration for MySQL is the following:
TBD

Packages used for this project are:
TBD

#### Type of computer

* Processor: Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz
* Cores: 4
* RAM: 8 GB
* Company Name: HP (Hewlett-Packard)

#### Operating System
The Operating System used is Linux Mint 17.1

#### Project Server
The project files will be stored in github under the folder [CaterpillarTubePricing](https://github.com/glapointe7/CaterpillarTubePricing)


## Naming Convension
For the database:

* Database: Upper camel case (AaaaaBbbbb)
* Tables: Upper camel case (AaaaaBbbbb)
* Cross reference tables: Aaaaa_Bbbbb
* Fields: Lower camel case (aaaaaBbbbb)

For the R language:

* Functions: aaaaBbbbb
* Function parameters: aaaa_bbbb
* Local variables: aaaa_bbbb
* Constants: AAAA_BBBB
* Lists: AaaaaBbbbb
* Dataset: Aaaaa_Bbbbb

For the Python language:

TBD

## Database Structure
In this section, we will show the [relational schema of the database](https://github.com/glapointe7/CaterpillarTubePricing/blob/master/Caterpillar.dia).
