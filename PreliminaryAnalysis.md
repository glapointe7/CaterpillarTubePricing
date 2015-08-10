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

Since the entire dataset is approximatively 6.8 Mb, we will use

* MySQL (with MySQL WorkBench) to store the data
* R (with RStudio Version 0.99.465) to produce the analysis code
* Python (version 3.4)
* Dia to build the relational schema of the database and other schemas if needed

The configuration for MySQL is the following:

The kind of computer used for this project:

* Processor: Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz
* Cores: 4
* RAM: 8 GB
* Company Name: HP (Hewlett-Packard)

The Operating System used is Linux Mint 17.1

The project files will be stored in github under the folder [CaterpillarTubePricing](https://github.com/glapointe7/CaterpillarTubePricing)

## Naming Convension
For the database:

* Database: AaaaaBbbbb
* Tables: AaaaaBbbbb
* Cross reference tables: Aaaaa_Bbbbb
* Fields: aaaaaBbbbb

For the R language:

* Functions: aaaaBbbbb
* Local variables: aaaa_bbbb
* Constants: AAAA_BBBB
* Lists: AaaaaBbbbb
* Dataset: Aaaaa_Bbbbb

## Database Structure
In this section, we will show the [relational schema of the database](https://github.com/glapointe7/CaterpillarTubePricing/blob/master/Caterpillar.dia).
