# CTAccessibilityTool
The scripts below were run on a MacBookPro Intel Core i7 quad-core, 1.7 GHz.

R version:
platform       x86_64-apple-darwin15.6.0   
arch           x86_64                      
os             darwin15.6.0                
system         x86_64, darwin15.6.0        
status                                     
major          3                           
minor          6.2                         
year           2019                        
month          12                          
day            12                          
svn rev        77560                       
language       R                           
version.string R version 3.6.2 (2019-12-12)

## data.zip
#### RAW DATA:
Those are the raw data used in our analysis and should be given as input to the main_index_computation procedure, to obtain local and national index for all/selected countries.

Geocoded_complete.csv: in this file all the addresses found in the clinical trials.gov database (query  column) are collected, together with results of their geolocalization, which means define the latitude and longitude (lat and lon columns). The other columns were not used but left in the file for completeness.

citynames.csv: list of addresses as they are found in the clinical trials.gov database (column Address). This file is necessary since typos may affect the quality of the results, and they needed to be corrected. The column Real provides the correct name. This file was curated by hand and all the cities in the Real column were geolocalized.

Studies.csv: collection of all the information regarding clinical trials that can be found from clinicaltrilas.gov: phase, date of registration, conditions, types, locations, funding agency, enrolment…
It was created from the Download_and_preprocessing procedure.

pop_density_nasa.csv: population from the GPW_v4 database. the columns xcenter and ycenter define the longitude and latitude of the population grid point.

Incidence_touse.csv: this table comes from GLOBOCAN2018. For each country the income class (Class) from the World Bank, the cancer incidence (Value  and Rate) are reported. The Value is given by number of cancer patients over 10,000 inhabitants. The Rate is Value/10,0000

#### RESULTS and TEST SETS:
Those files represents the results obtained by computation of local and national index from our algorithm.
They are obtained by the main_index_computation procedure and can be used as input (for a selected country) in the 
main_optimization procedure.

local_data_and_index.txt: collection of data for grid points of each nation (name_long).
Data are: density population (density_nolog_YEAR), log of cancer patient (density_YEAR), latitude (lat) and longitude (lon) of the grid point, address of closest research location (Address_YEAR) and distance from grid point (Km_YEAR), number of studies in the research location (nstudies_YEAR), local accessibility index (index_YEAR), the threshold used to remove grid posts with small population from the analysis (threshold).
Data are provided for years 2005-2019.

national_index_final.xlsx: summary of national index for all country with defined income class in the years 2005-2019. Data from each country are: the Cancer incidence, the Income class, the total number of studies in the country (Total studies YEAR) and the national index computed for the country (Accessibility Index YEAR)

## MAIN SCRIPTS
Installation.R: installation of necessary libraries and dependencies to run all the codes

simulation_insilico.R: we tested our local accessibility index on several simulated configurations, which are built and analysed in this script. Basic grid and research locations are defined with their own population density, number of studies etc. The index is then computed for each configuration, changing parameters.

Download_and_preprocessing.R: downloads data from the AACT database connected to clinicaltrials.gov.
Data are merged to create the complete dataset of clinical trials with agency, phase, submission date and year, country and exact trial facilities.

THE COMPUTATION OF THE LOCAL AND NATIONAL INDEX ON THE PROVIDED RAW DATA CAN START DIRECTLY FROM HERE:
main_index_computation.R: 
computation of accessibility index for all countries in three main steps: basic index, addition of incidence in the data, addition of log of the incidence.
Output are the local index for all the grid points in the countries and the national index. Index are computed for years 2005-2019.

main_optimization.R: 
identification of two optimal locations to maximise the national accessibility for a selected country. In the script we provide an example of the running algorithm for Italy. 

## FUNCTIONS
distance.R: function to compute the distance from each grid point of the specified country to the closest research location. The location with minimum distance and the distance (Km) are given as output

index.R: functions to compute the basic local index for the first step p the analysis. It works on single grid point provided the distance from closest research location, number of studies in the location and population in the grid point.

compute_index.R: this function puts together all the info from data density and clinical trials, to correctly compute the index for all the grid points in a nation and to provide the national index.

Optimize_acc_log.R: function to compute accessibility when we want to identify the optimal location to maximise accessibility.  It is called in the main_optimization procedure. All the grid points in selected country are added one by one to the accessibility computation and updated national indexes are then returned.

index_simulation_log.R: this function is called in the simulation_insilico procedure. It computes index for simulated configurations.
