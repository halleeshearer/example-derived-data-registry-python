# Derive personality scores (extraversion and plasticity) from Big Five Inventory item responses

library(dplyr)
library(tidyverse)
library(magrittr)
library(codebook)
library(stringr)

# paths
output_dir <- "/your/path/to/derived-data-reg/data/"

# load and prepare the data
bfi_data <- rio::import("https://osf.io/s87kd/download", "csv") # data itself 
bfi_data$id <- paste0("id_", str_pad(1:nrow(bfi_data), 3, pad = "0", side = "left")) # add subject ids
dict <- rio::import("https://osf.io/cs678/download", "csv") # data dictionary

# reverse score items 
reversed_items <- dict %>% filter(Keying == -1) %>% pull(variable)

bfi_data <- bfi_data %>% 
  rename_at(reversed_items,  add_R)

bfi_data <- bfi_data %>% 
  mutate_at(vars(matches("\\dR$")), reverse_labelled_values)

# calculate scores
bfi_data$extraversion <- bfi_data %>% dplyr::select(E1R:E5) %>% aggregate_and_document_scale()
bfi_data$plasticity <- bfi_data %>% dplyr::select(E1R:E5, O1:O5R) %>% aggregate_and_document_scale() 

# prepare derived data with ids only 
personality_vars <- bfi_data %>% select(id, extraversion, plasticity) 

# save to derived data registry
write.csv(x = personality_vars, file = paste0(output_dir, "bfi_personality.csv"), row.names = F)