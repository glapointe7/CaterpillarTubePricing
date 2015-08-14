# Description of the Dataset

### Dataset Purpose
This dataset comes from [here](https://www.kaggle.com/c/caterpillar-tube-pricing/data) and has the purpose to serve of input to help to predict the price a supplier will quote for a given tube assembly. 


### Dataset Summary
The dataset is comprised of a large number of relational tables that describe the physical properties of tube assemblies. You are challenged to combine the characteristics of each tube assembly with supplier pricing dynamics in order to forecast a quote price for each tube. The quote price is labeled as cost in the data.

### Dataset Codes
In this entire dataset, there is no blank cell. The `NA` values mean that a value is not applicable to a specific field property. The value `0` always means a numerical value, not a boolean value like `false` nor a missing value. The notation `Y` means `YES` and can be treated as the value `1`. The notation `N` means `NO` and can be treated as the value `0`. Finally, the value `NONE` means that there is no such component on a certain tube assembly. We will treat `NA` and `NONE` as `NA` values.

We can also see the code `OTHER` which is associated with the identifiant `9999`. This means that this element is another element which is not contained in the given list.

There are also many identifiant codes used in fields [Table]_id. Here are the list:

| Code           | Full name |
| -------------- | --------- |
| A              | Type End Form |
| B              | Connection Type |
| C              | Component |
| CP             | Component Type |
| EF             | Tube End Form |
| SP             | Specs (for material) |
| TA             | Tube Assembly |


### Dataset File Descriptions
There are a total of 21 CSV files in this dataset. Here is the list of files with a short description for each one.

| FileName              | Variables Number | Sample size | Description |
| --------------------- | ----------------:| -----------:| ----------- |
| train_set.csv         | 8                | 30213       | Contains information on price quotes from our suppliers. |
| test_set.csv          | 8                | 30235       | Contains information on quntities. |
| tube.csv              | 16               | 21198       | Contains information on tube assemblies. |
| bill_of_materials.csv | 17               | 21198       | Contains the list of components, and their quantities, used on each tube assembly. |
| specs.csv             | 11               | 21198       | Contains the list of unique specifications for the tube assembly. |
| tube_end_form.csv     | 2                | 27          | Contains end types that are physically formed utilizing only the wall of the tube. |
| components.csv        | 3                | 2048        | Contains the list of all of the components used. |
| comp_adaptor.csv      | 20               | 25          | Contains the list of all of the components that are of type Adaptor used. |
| comp_boss.csv         | 15               | 147         | Contains the list of all of the components that are of type Boss used. |
| comp_elbow.csv        | 16               | 178         | Contains the list of all of the components that are of type Elbow used. |
| comp_float.csv        | 7                | 16          | Contains the list of all of the components that are of type Float used. |
| comp_hlf.csv          | 9                | 6           | Contains the list of all of the components that are of type HLF used. |
| comp_nut.csv          | 11               | 65          | Contains the list of all of the components that are of type Nut used. |
| comp_sleeve.csv       | 10               | 50          | Contains the list of all of the components that are of type Sleeve used. |
| comp_straight.csv     | 12               | 361         | Contains the list of all of the components that are of type Straight used. |
| comp_tee.csv          | 14               | 4           | Contains the list of all of the components that are of type Tee used. |
| comp_threaded.csv     | 32               | 194         | Contains the list of all of the components that are of type Threaded used. |
| comp_other.csv        | 3                | 1001        | Contains the list of all of the components that are of type Other used. |
| type_component.csv    | 2                | 29          | Contains the names for each component type. |
| type_connection.csv   | 2                | 29          | Contains the names for each connection type. |
| type_end_form.csv     | 2                | 8           | Contains the names for each end form type. |


#### train_set.csv (and test_set.csv)

These files contain information on price quotes from our suppliers. Prices can be quoted in 2 ways: bracket and non-bracket pricing. Bracket pricing has multiple levels of purchase based on quantity (in other words, the cost is given assuming a purchase of quantity tubes). Non-bracket pricing has a minimum order amount (min_order) for which the price would apply. Each quote is issued with an annual_usage, an estimate of how many tube assemblies will be purchased in a given year.

| Variable           | Description |
| ------------------ | ----------- |
| id                 | Auto-increment number starting to 1. |
| tube_assembly_id   | The tube assembly ID (TA-xxxxx). |
| supplier           | The supplier who quotes the price of a tube assembly. |
| quote_date         | Date when the supplier quotes the price on a tube assembly. |
| annual_usage       | An estimate of how many tube assemblies will be purchased in a given year. |
| min_order_quantity | Non-bracket pricing has a minimum order amount for which the price would apply. |
| bracket_pricing    | Prices can be quoted in 2 ways: bracket and non-bracket pricing. Bracket pricing has multiple levels of purchase based on quantity (in other words, the cost is given assuming a purchase of quantity tubes). Non-bracket pricing has a minimum order amount (min_order) for which the price would apply. |
| quantity           | The quantity of tubes to purchase. |
| cost               | The cost depends of the bracket price and the pruchase of quantity tubes. |


#### tube.csv

This file contains information on tube assemblies, which are the primary focus of the competition. Tube Assemblies are made of multiple parts. The main piece is the tube which has a specific diameter, wall thickness, length, number of bends and bend radius. Either end of the tube (End A or End X) typically has some form of end connection allowing the tube assembly to attach to other features. Special tooling is typically required for short end straight lengths (end_a_1x, end_a_2x refer to if the end length is less than 1 times or 2 times the tube diameter, respectively). Other components can be permanently attached to a tube such as bosses, brackets or other custom features.

Source of images: [https://www.kaggle.com/c/caterpillar-tube-pricing/data](https://www.kaggle.com/c/caterpillar-tube-pricing/data)
<img src="Images/tube1.png" alt="Drawing" style="width: 500px;"/> <br /><br />
<img src="Images/tube2.png" alt="Drawing" style="width: 500px;"/> <br /><br />

| Variable           | Description |
| ------------------ | ----------- |
| tube_assembly_id   | The tube assembly ID (TA-xxxxx). |
| material_id        | The material used, represented by his ID, for the tube assembly. |
| diameter           | Typical diameter of tubes used in this tube assembly. |
| wall               | Typical wall thickness of tubes used in this tube assembly. |
| length             | Total length of this tube assembly. |
| num_bends          | Total number of bends in this tube assembly. |
| bend_radius        | Typical bend radius for this tube assembly. |
| end_a_1x           | (Y) If the end straight length is less than 1 times the tube diameter. (N) otherwise |
| end_a_2x           | (Y) If the end straight length is less than 2 times the tube diameter. (N) otherwise |
| end_x_1x           | (Y) If the end length is less than 1 times the tube diameter. (N) otherwise |
| end_x_2x           | (Y) If the end length is less than 2 times the tube diameter. (N) otherwise |
| end_a              | ID of end form tube which typically has some form of end connection allowing the tube assembly to attach to other features. |
| end_x              | ID of end form tube which typically has some form of end connection allowing the tube assembly to attach to other features. |
| num_boss           | Total number of bosses attached to a tube in this tube assembly. |
| num_bracket        | Total number of brackets attached to a tube in this tube assembly. |
| other              | Total number of other components attached to a tube in this tube assembly. |


#### bill_of_materials.csv

This file contains the list of components, and their quantities, used on each tube assembly.

| Variable           | Description |
| ------------------ | ----------- |
| tube_assembly_id   | The tube assembly ID (TA-xxxxx). |
| component_id_[x]   | The components used to build this tube assembly, where 1 <= x <= 8 an integer. |
| quantity_[x]       | Quantity of components (identified by component_id_[x]) needed to build this tube assembly, where 1 <= x <= 8 an integer. |


#### specs.csv

This file contains the list of unique specifications for the tube assembly. These can refer to materials, processes, rust protection, etc.

| Variable           | Description |
| ------------------ | ----------- |
| tube_assembly_id   | The tube assembly ID (TA-xxxxx). |
| spec[x]            | The specifications used to build this tube assembly, where 1 <= x <= 10 an integer. Note that a tube assembly may not needs any specifications. In that case, spec1 to spec10 have the value `NA`. |


#### tube_end_form.csv

Some end types are physically formed utilizing only the wall of the tube. These are listed here.

| Variable           | Description |
| ------------------ | ----------- |
| end_form_id        | The end form tube ID (EF-xxx). Note that the ID `9999` means that this end form is other than the ones contain in the list. |
| forming            | Boolean value (Yes / No) indicating if the end type is physically formed utilizing only the wall of the tube or not. |


#### components.csv

This file contains the list of all of the components used. Component_type_id refers to the category that each component falls under.

| Variable           | Description |
| ------------------ | ----------- |
| component_id       | The component ID (C-xxxx). Note that the ID `9999` means that this component is other than the ones contain in the list. |
| name               | The name of the component in uppercase. |
| component_type_id  | Refers to the component type that each component falls under. |


#### comp_[type].csv

These files contain the information classified type of components. The main types are: Adapter, Boss, Elbow, Float, Hfl, Nut, Sleeve, Straight, Tee and Threaded. The other components are listed in the file comp_other.csv. These components are not part of the main types.


#### type_[type].csv

These files contain the names for each feature (type). The types are: Component Type, Connection and End Form.

| Variable           | Description |
| ------------------ | ----------- |
| type\_[type]\_id     | The type ID. Note that the ID `9999` means that this type is other than the ones contain in the list. |
| name               | The name of the type. |
