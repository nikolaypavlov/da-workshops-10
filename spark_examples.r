# Spark initialization in R studio
  
Sys.setenv(SPARK_HOME = "/usr/local/Cellar/apache-spark/1.6.1/libexec")
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))

library(SparkR)
sc <- sparkR.init(master="local[2]")
sqlContext <- sparkRSQL.init(sc)

# Create Spark Data Frame from faithful dataset
df <- createDataFrame(sqlContext, faithful)

# Print information about this data frame
df 

# Print out frist 10 rows
head(df, 10)

# How many rows do we have?
nrow(df)

# Select only the "eruptions" column
head(select(df, "eruptions")) 

# Filter the DataFrame to only retain rows with wait times shorter than 50 mins
head(filter(df, df$waiting < 50))

# Count the number of times each waiting time appears
by_waiting_time <- groupBy(df, df$waiting)
waiting_counts <- summarize(by_waiting_time, count = count(df$waiting))
head(waiting_counts)

# Sort the output from the aggregation to get the most common waiting times
sorted_counts <- arrange(waiting_counts, desc(waiting_counts$count))
head(sorted_counts)

# Convert waiting time to seconds
df$waiting_secs <- df$waiting * 60
head(df)

# SQL queries
registerTempTable(df, "faithful")
df_subset <- sql(sqlContext, "SELECT * FROM faithful WHERE waiting >= 50 AND waiting <= 60")

# Fit a gaussian GLM model over the dataset.
df <- createDataFrame(sqlContext, iris)
model <- glm(Sepal_Length ~ Sepal_Width + Species, data = df, family = "gaussian")
summary(model)

# Make predictions based on the model.
predictions <- predict(model, newData = df)
head(select(predictions, "Sepal_Length", "prediction"))