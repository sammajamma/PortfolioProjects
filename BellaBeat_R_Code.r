# Load the required library
library(dplyr)

# Read the CSV file into a dataframe
dailyActivity <- read.csv("dailyActivity_merged.csv")

glimpse(dailyActivity)



# Calculate descriptive statistics for relevant columns
summary_data <- dailyActivity %>%
    select(TotalSteps, TotalDistance, VeryActiveMinutes) %>%
    summary()

# Print the descriptive statistics
print(summary_data)

# Group the data by 'id' and calculate summary statistics for each user
summary_data2 <- dailyActivity %>%
    group_by(Id) %>%
    summarise(
        AvgTotalSteps = mean(TotalSteps),
        AvgTotalDistance = mean(TotalDistance),
        AvgVeryActiveMinutes = mean(VeryActiveMinutes)
    )

# Group the data by 'id' and calculate the percentage of sedentary activity for each user
summary_data <- dailyActivity %>%
    group_by(Id) %>%
    summarise(
        SedentaryPercentage = mean(SedentaryMinutes / (SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes))
    ) %>%
    filter(SedentaryPercentage > 0.5) %>%
    summarise(
        UsersWithMoreThanHalfSedentary = n()
    )

# Calculate the sum of the 'LoggedActivitiesDistance' column
total_distance <- sum(dailyActivity$LoggedActivitiesDistance, na.rm = TRUE)
instance_of_activity <- sum(dailyActivity_o$LoggedActivitiesDistance > 0)
library(lubridate)

# Convert the 'ActivityDate' column to a Date type and filter out missing or invalid dates
dailyActivity <- dailyActivity %>%
    mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y")) %>%
    filter(!is.na(ActivityDate))

# Extract the weekday from the 'ActivityDate' column
dailyActivity <- dailyActivity %>%
    mutate(Weekday = weekdays(ActivityDate))

# Group the data by weekday and calculate the total active minutes for each day
activity_by_weekday <- dailyActivity %>%
    group_by(Weekday) %>%
    summarise(TotalActiveMinutes = sum(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes))

# Find the day(s) with the highest total active minutes
max_activity <- activity_by_weekday %>%
    filter(TotalActiveMinutes == max(TotalActiveMinutes))

# Print the result
print(max_activity)

# Calculate the duration of time each user wore their fitness device
device_usage <- dailyActivity %>%
    group_by(Id) %>%
    summarise(DeviceUsage = sum(as.numeric(difftime(ActivityDate + days(1), ActivityDate, units = "hours"))))

# Read the CSV file into a dataframe
sleepDay <- read.csv("sleepDay_merged.csv")

# Count the occurrences of values higher than 1 in the 'TotalSleepRecords' column
count_higher_than_one <- sum(sleepDay$TotalSleepRecords > 1)

# Print the result
print(count_higher_than_one)


# Group the data by 'Id' and count the occurrences where 'TotalSleepRecords' is greater than 1
user_counts <- sleepDay %>%
    group_by(Id) %>%
    summarise(Count = sum(TotalSleepRecords > 1))

# Sort the results in descending order
user_counts <- user_counts %>%
    arrange(desc(Count))

# Print the result
print(user_counts)

# Convert TotalMinutesAsleep to hours in a new column
sleepDay <- sleepDay %>%
    mutate(TotalHoursAsleep = TotalMinutesAsleep / 60)

# Calculate the average hours of night sleep per user
average_hours_slept <- sleepDay %>%
    group_by(Id) %>%
    summarise(AverageHoursSlept = mean(TotalHoursAsleep)) %>%
    arrange(desc(AverageHoursSlept))

# Print the result
print(average_hours_slept)

# Separate SleepDay column into SleepDate and SleepTimes columns
sleepDay <- sleepDay %>%
    separate(SleepDay, into = c("SleepDate", "SleepTimes"), sep = " ") %>%
    mutate(
        SleepDate = as.Date(SleepDate, format = "%m/%d/%Y"),
        SleepTimes = hms::as_hms(SleepTimes)
    )

# Print the updated dataframe
print(sleepDay)

# Convert date columns to appropriate date format
dailyActivity <- dailyActivity %>%
    mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y"))

# Join the dataframes on Id
merged_data <- dailyActivity %>%
    inner_join(sleepDay, by = "Id")

unique(merged_data$Id)

# Print the merged dataframe
print(merged_data)

# Rename the original full files so we can join them
dailyActivity_o <- read.csv("dailyActivity_merged.csv")
sleepDay_o <- read.csv("sleepDay_merged.csv")

# Change the datatype in the ActivityDate column from a character to a date
dailyActivity_o <- dailyActivity_o %>%
    mutate(ActivityDate = as.Date(ActivityDate, format = "%m/%d/%Y"))

# Join the dataframes on Id and ActivityDate = SleepDate
merged_data_from_original <- dailyActivity_o %>%
    inner_join(sleepDay, by = c("Id", "ActivityDate" = "SleepDate"))

# Print the merged dataframe
print(merged_data)

merged_data <- dailyActivity %>%
    inner_join(sleepDay, by = "Id")


# Join the dataframes on Id and ActivityDate = SleepDate
merged_data <- dailyActivity_o %>%
    inner_join(sleepDay, by = c("Id", "ActivityDate" = "SleepDate"))

# See how many users there were that used their device to track both activity
# and sleep
unique(merged_data_from_original$Id)

# Count the number of unique user IDs
unique_user_count <- merged_data %>%
    distinct(Id) %>%
    nrow()

# Print the result
print(unique_user_count)

# Compare this to the total users in the dailyActivity_o data frame
unique(dailyActivity_o$Id)


# Calculate the total sleep duration in hours per day of the week
sleep_summary <- merged_data %>%
    group_by(Weekday = weekdays(ActivityDate, abbreviate = TRUE)) %>%
    summarise(TotalSleepHours = sum(TotalMinutesAsleep / 60))

# Order the days of the week by total sleep duration in descending order
sleep_summary <- sleep_summary %>%
    arrange(desc(TotalSleepHours))

# Calculate average sleep hours per weekday
sleep_summary_avg <- merged_data %>%
  group_by(Weekday = weekdays(ActivityDate, abbreviate = TRUE)) %>%
  summarise(AvgSleepHours = mean(TotalMinutesAsleep / 60))

# Order the weekdays by average sleep duration in descending order
sleep_summary_avg <- sleep_summary_avg %>%
  arrange(desc(AvgSleepHours))
# Print the result
print(sleep_summary)
print(sleep_summary_avg)

library(ggplot2)

# Create a bar plot to visualize total sleep hours for each weekday
ggplot(sleep_summary, aes(x = reorder(Weekday, desc(TotalSleepHours)), y = TotalSleepHours)) +
        geom_bar(stat = "identity", fill = "orchid", alpha = 0.7) +
        labs(x = "Weekday", y = "Total Sleep Hours") +
        ggtitle("Total Sleep Hours by Weekday") +
        theme_minimal()

# Create a bar plot to visualize total sleep hours for each weekday
ggplot(sleep_summary_avg, aes(x = reorder(Weekday, desc(TotalSleepHours)), y = TotalSleepHours)) +
        geom_bar(stat = "identity", fill = "orchid", alpha = 0.7) +
        labs(x = "Weekday", y = "Total Sleep Hours") +
        ggtitle("Total Sleep Hours by Weekday") +
        theme_minimal()

# Create a scatter plot to visualize the correlation
ggplot(dailyActivity_o, aes(x = VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes, y = Calories)) +
        geom_point() +
        labs(x = "Total Active Minutes", y = "Calories") +
        ggtitle("Correlation: Total Active Minutes vs Calories") +
        theme_minimal()

# Create a scatter plot with smoothing
ggplot(dailyActivity_o, aes(x = VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes, y = Calories)) +
        geom_point() +
        geom_smooth(method = "lm", se = FALSE, color = "pink") +
        labs(x = "Total Active Minutes", y = "Calories") +
        ggtitle("Correlation: Total Active Minutes vs Calories") +
        theme_minimal()

# Create a bar plot of total active minutes by weekday
ggplot(activity_by_weekday, aes (x = Weekday, y = TotalActiveMinutes)) +
        geom_bar(stat = "identity", fill = "orchid", alpha = 0.7) +
        geom_text(aes(label = ifelse(TotalActiveMinutes == max(TotalActiveMinutes), TotalActiveMinutes, "")),
                  vjust = -0.5, color = "navy") +
        labs(x = "Weekday", y = "Total Active Minutes") +
        ggtitle("Total Active Minutes by Weekday") +
        theme_minimal()

# Create a bar plot of average hours slept per user with tilted text
ggplot(average_hours_slept, aes(x = reorder(Id, AverageHoursSlept), y = AverageHoursSlept)) +
  geom_bar(stat = "identity", fill = "orchid", alpha = 0.7) +
  labs(x = "User ID", y = "Average Hours Slept") +
  ggtitle("Average Hours of Night Sleep per User") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # Create correlation variable
correlation <- cor(merged_data$TotalSteps, merged$TotalMinutesAsleep)
correlation <- round(correlation, 2)

# Create a scatter plot to show correlation between sleep time in minutes and total steps
ggplot(data = merged_data, aes(x = TotalSteps, y = TotalMinutesAsleep)) +
        geom_point() +
        labs(x = "Total Steps", y = "Total Minutes Asleep", title = "Correlation: Total Steps vs. Total Minutes Asleep") +
        geom_smooth(method = "lm", se = FALSE) +
        annotate("text", x = max(dailyActivity$TotalSteps), y = max(sleepDay$TotalMinutesAsleep),
                 label = paste("Correlation:", correlation), hjust = 1, vjust = 1) +
        theme_minimal()

