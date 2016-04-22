#-------------------------------------------------------------------
#Data product final project
#Purpose : Predicting Housing costs based on different predictors
#          including owner's age, income, and number of bedrooms in 
#          the house
#Date : 4/19/2016
#Author :
#-------------------------------------------------------------------

#--------------------------------- DATA SUMMARY ------------------------------------------------------------------
#The data used is from the U.S department of Housing and Urban Development website. It's the Housing Affordability
#data derived from the American Housing Survey. More info can be found here 
#https://www.huduser.gov/portal/datasets/hads/hads.html

#--------------------------------- DATA PRE-PROCESSING -----------------------------------------------------------
#load required libraries
pacman::p_load(dplyr,funModeling,caret,data.table,rpart,randomForest,rattle, ggplot2, gridExtra,shiny,DT, Cairo)

#import the data
download.file("https://www.huduser.gov/portal/datasets/hads/hads2013n_ASCII.zip", destfile = "housing_data.zip")
#unzip file
unzip("housing_data.zip")
#read the data
data <- read.table("thads2013n.txt", sep = ",", header = TRUE)
#rename variables to lower case
names(data) <- tolower(names(data))
#select variables of interest
data <- as.data.table(data) %>% select(costmed, totsal, bedrms, age1, built) 
#scaling the housing cost to yearly cost for comparison prupose to yearly income
data[, scale_cost := costmed * 12]
#remove values that are zero or less than zero
data <- data[(apply(data, 1, function(x) all(x > 0)))]

#subset to get houses built post 2009
dt <- data %>% filter(built >= 2010)

#get the overall status of the data. The status resulted in a missing values free 
#data. Alos no zero values in the data
dt_status <- df_status(dt)

#--------------------------------- DATA ANALYSIS --------------------------------------------------------------
#Partition the training data into train and test sets
inTrain <- createDataPartition(y=dt$scale_cost, p=0.6, list=FALSE)
trainset<- dt[inTrain,]; testset <- dt[-inTrain,]

#Fit models : trees, random forest and boosting 
rpFit <- train(scale_cost~.,data=trainset, method="rpart")
rfFit <- train(scale_cost~.,data=trainset, method="rf",prox=TRUE)
gbmFit <- train(scale_cost~.,data=trainset, method="gbm")
#plot models 
rp.plot <- plot(rpFit, width = 400, height = 300, title = "Recursive Part Reg Trees")
rf.plot <- plot(rfFit, width = 400, height = 300, title = "Random Forest")
gbm.plot <- plot(gbmFit, width = 400, height = 300, title = "Generalized Boosted Model")
#clearly random forest preformed better with the lowest RMSE
diagplots <- grid.arrange(rp.plot,rf.plot,gbm.plot)
#concatenating the fitted models into a single vector
model <- c("Recursive Part Reg Trees","Random Forest","Generalized Boosted Model")
#Comparing the models to get the best fitted model
rmse <- c(min(rpFit$results$RMSE),
          min(rfFit$results$RMSE),
          min(gbmFit$results$RMSE))
rsquared <- c(max(rpFit$results$Rsquared),
              max(rfFit$results$Rsquared),
              max(gbmFit$results$Rsquared))
#gathering accuracy info into a data frame
performance <- data.frame(model, rmse, rsquared)

#get 5 test datasets from the original data
testset2 <- filter(data, built %in% c(2007,2008,2009))
testset3 <- filter(data, built %in% c(2004,2005,2006))
testset4 <- filter(data, built %in% c(2001,2002,2003))
testset5 <- filter(data, built %in% c(1985,1990,2000))

#--- SERVER

shinyServer(function(input, output) {
        
        #input test dataset
        datasetInput <- reactive({
                switch(input$dataset,
                       "testset1"=testset,
                       "testset2"=testset2,
                       "testset3"=testset3,
                       "testset4"=testset4,
                       "testset5"=testset5)
        })
        #Generate a summary of measures of accuracy for 3 different models (RMSE and Rsquared)
        output$summary <- renderPrint({
                          performance
        })
        
        # customize the length drop-down menu; display 5 rows per page by default
        output$plot <- renderPlot({
                    test <- datasetInput()
                    #The random forest model is selected for prediction as it's the best
                    test$pred <- predict(rfFit, test)
                    #make a scatter plot comparing observed and predicted outcome
                    p <- ggplot(test, aes(scale_cost, pred)) + geom_point(color="cadetblue", size=2)
                    p <- p + geom_abline(intercept = 0, slope = 1, color = "orange", size = 1)
                    p <- p + xlab("Obesrved Housing Cost(year)") + ylab("Predicted Housing Cost(year)")
                    p <- p + ggtitle("Predicted vs Observed Housing Cost from a Random Forest model")
                    p <- p + theme_bw()
                    p
        })
        
        #plot dignostics plots for models
        output$diagnostics <- renderPlot({
                grid.arrange(rp.plot,rf.plot,gbm.plot)
        })
          
})

