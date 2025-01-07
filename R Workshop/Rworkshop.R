#Intro to POLI 428
#R Review: loops, combinations, indices, vectorization, and functions

#Author: Sam Lee
#Last Updated: 01/06/2024

##### 1. Read in the Data #####

#These files contain recent employment data (2016-2024) for each county in MN
#as well as election results by county in terms of percentages
#       where R indicates the proportion of the votes that were for the Republican nominee
#       and D indicates the proportion of the votes that were for the Democrat nominee in both the 2020 and 2024 elections
#
#In the employment file, LF represents the labor force, E represents the employment, U the employment, and UR the employment rate

election = read.csv("https://raw.githubusercontent.com/SamLeeBYU/RWorkshop/main/R%20Workshop/data/election-data-mn.csv")
employment = read.csv("https://raw.githubusercontent.com/SamLeeBYU/RWorkshop/main/R%20Workshop/data/employment-mn.csv")

summary(election)
summary(employment)

#Additional Notes: employment data was retrieved from the BLS and election data was
#                  scraped from CNN

##### 2. Indices, Matrices, and Data Frames #####

#Definitions:
# A matrix in R is a two-dimensional array where all elements are of the same type (numeric, character, etc.).
# It is essentially a rectangular table of elements organized in rows and columns.

# A data frame in R is a two-dimensional table-like structure where columns can have different types of data.
# It is commonly used for storing datasets in R as it allows heterogeneous data types across columns
# but maintains uniformity within each column.

#Run dim() and str() on both election and employment to see the dimensions (# of rows, # of columns) and data tpe of each column

dim(...)
str(...)

# Indices in R are used to access specific elements of a matrix or data frame using their row and column positions.

#This extracts the first element in the first column --- since both data frames and matrices are two-dimensional
#indices function the same for both  data types
employment[1, 1]
#This is also equivalent to
employment$Year[1] #(Since year represents the first column)

#Implicit indices work by omitting either a column index or a row index to indicate that you want the **entire** row or **entire** column
#Omitting the first index (the row index) indicates that we want all rows for column 1.
employment[,1]
#This is equivalent to
employment$Year

#We can use vectors to indicate which index we want as well
#This statement gets the first five rows and columns 1, 6, and 7 in a single statement
employment[1:5, c(1, 6, 7)]

##### 3. Loops and Vectorization #####
#Loops in R tend to be really slow (they're okay for a small number of iterations)
#We use vectorization to attain a similar speed demonstrated in lower level languages, such as C++

#Find the sum of squares of the R column for 2024 in the election data

#I'll help you out here by filtering to the year 2024
#Note that this gets all of the columns through implicit indexing and
#all of the years that satisfy Year == 2024
election_2024 <- election[election$Year == 2024, ]

#First subtract each value in the R column from the mean of R and then square each value
#place it in the deviations vector
squared_deviations = numeric(nrow(election_2024))
for(i in 1:nrow(election_2024)){
  ...
}
#Now sum it up to find the sum of squares
squared_deviation_sum = 0
for(i in 1:length(squared_deviations)){
  ...
}
squared_deviation_sum

#Vectorization approach
#We can do the same thing as above with much less and faster code

#Without going too much into the mathematical details of what qualifies as a 'vector',
#   Vectors are simply a one dimensional set of numbers.

#When you add two vectors of the same length, each element is added to the corresponding element:
1:3 + 1:3
#is equivalent to c(1 + 1, 2 + 2, 3 + 3)
#This also works for any other one-to-one mathematical operator

#Thus we can apply this concept to the problem above
#Take time to understand what this does

#Does this match your answer from above?
sum((election_2024$R - mean(election_2024$R))^2)

#Find the sums of squares for the 2020 election column R
election_2020 <- ...

##### 4. Functions #####

# A function in R is a reusable block of code that performs a specific task.
# Functions take inputs (called arguments), process them, and return an output.

#Basic syntax
my_function <- function(...){
  ...
}

#Ex: Finding the mean of the employment rate for a given county and year
#Make sure you understand what this function is doing here
get_mean <- function(v="ER", county, year){
  #Note the 'filter' function which some of you may have used before works the exact same way
  subset <- employment[employment$Year == year & employment$County == county, ]
  return(mean(subset[[v]], na.rm=T))
}
get_mean(county="Aitkin", year=2024)

#Your turn: Write a function that calculates the difference in R (from the elections data) for a given
#county between years 2024 and 2020 (hint: you only need one argument)

get_diff <- ...

##### 5. Putting it all together #####

#In the 2024 presidential election one of the most frequently cited top issues for voters was the economy and inflation
#Suppose we are interested in seeing how the employment (as a general measure of the state of the economy) affects
#the way voters voted on an aggregate level in Minnesota

#One way to examine this effect is to see how the change in employment from 2020 to 2024 affected the change in voting outcomes in Minnesota
#This is a (albeit simplified and perhaps naive) version of a difference-in-differences model which we will discuss later in the class

#1. To begin, use your get_diff function to calculate the voting differences in D (in the elections data for each county)
#You may use a for loop or vectorization here (using the get_diff function, as it turns out, is not required, but still may be used)

counties <- unique(election$County) #87 counties

election_differences <- ...
election_differences <- (election_2024$D) - (election_2020$D)

#The differences vector defined above should only have 87 elements (the number of counties in MN)
length(election_differences)

#2. Now we want to get the difference in employment from 2020 to 2024 for each county
# To simplify things a bit, for now let's just compare the **mean** employment rate (UR) for each county from 2020 to 2024

#First get the mean employment rate for each county in year 2020
# (you may use a similar process that you did above, only this time you may use the get_mean function that I defined earlier)

e_2020 <- ...

#Do the same thing for 2024
e_2024 <- ...

#Now find the differences for each county from 2020 to 2024
e_differences <- ...

#This again should be a vector of 87 elements
length(e_differences)

#3. Now we can measure the effect of the change of employment on election outcomes in MN
#Use the simple linear regression model y = b0 + b1*x where y is the change in voting outcomes and x is the change in employment outcomes

#We can do this with the lm(.) function

#Weight each observation by the labor force in that county (you don't need to do anything here)
weights = sapply(counties, function(c) get_mean("LF", c, year=2024))
#The weights represent the proportion of the state's total labor force in 2024
#This standardizes the weights so that they sum to 1
weights = weights/sum(weights) 

#Specify the linear model
model <- lm(..., weights=weights)

#4. Let's graph our results with the following ggplot code
library(ggplot2)

ggplot(mapping=aes(x = e_differences, y = election_differences))+
  geom_point(aes(size = weights))+
  geom_line(aes(y = model$fitted.values), )+
  theme_minimal()+
  labs(
    x = "Change in Employment",
    y = "Change in the Proportion of Votes for the Democrat Nominee"
  )


#What do we see? The simple linear regression model may not be the best at estimating this relationship (misspecification).
#   There is also plenty of room for endogeneity---meaning, that there are other confounding variables that are driving this
#   relationship other than the change in employment alone; Small counties tended to vote Republican, and Larger counies tended to vote Democrat.
#   From a practical standpoint, most counties voted for Trump regardless of the change in employment. The counties where the employment
#   rate mattered the most were in large counties---and in those counties, the better the economy did over the past four years the more people,
#   on average, in that county swayed more blue.