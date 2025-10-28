
# Useful R scripts --------------------------------------------------------

# pacman package and p_load command makes it easy to install and load commands
if (!require(pacman)) install.packages(pacman) 
p_load(tidyverse, skimr, Hmisc, janitor)

# Check package version
packageVersion("insight")

# build a data frame
df <- tibble(
  'first name' = c("Alice", "Bob", "Charlie", "James", "Natalie", "Chris", "Dylan", "Anna", "Andrew", "Kate"),
  'Age in years' = c(25, 30, 22, 18, 27, 28, 16, 28, 29, 32)
)

df <- as.data.frame(df)

# data exploration (first thing you'd want to do)
class(df)
class(df$'Age in years')
glimpse(df) # my fave to get idea of data type you have
# summary statistics
summary(df) # most basic base stat
skim(df) # skim package (good to skim distribution and stat)
describe(df) # Hmisc package (good for finding missing)

# add new column
# by $, good if only need to add one
df$'Legal Age' <- ifelse(df$'Age in years' > 18, "TRUE", "FALSE")
head(df, 10)


# fast way to clean names
df_clean_nows_allcap <- clean_names(df, "screaming_snake") # my fave to follow EPA naming convention
View(df_clean_nows_allcap)

df_clean_nows_alllower <- clean_names(df, "snake")
View(df_clean_nows_alllower)

# check colnames
colnames(df_clean_nows_alllower)
remove_empty(df, "cols") # good for removing empty columns (janitor package)

# list unique
list(unique(df_clean_nows_alllower$first_name))

# count number of occurrences
nrow(df)

# by mutate, good if want to add multiple
df_clean <- df_clean_nows_alllower %>%
  group_by(legal_age) %>%
  mutate(average_age = mean(age_in_years, na.rm = TRUE))

View(df_clean)

# read_csv()
# write_csv()


ggplot(df_clean, aes(first_name, age_in_years)) +
  geom_col()


# Copy table to excel to use with ampler extension for powerpoint
library(clipr)
write_clip(data_summary_table)


# User interaction --------------------------------------------------------
# use file.choose to choose a file interactively
setwd(file.choose())
choose.dir()

# Reading GIS data --------------------------------------------------------


