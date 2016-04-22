

library(shiny)

shinyUI(fluidPage(
           titlePanel("Housing Cost Prediction"),
           sidebarLayout( 
                sidebarPanel(
                        # Setting id makes input$tabs give the tabName of currently-selected tab
                        selectInput("dataset", "Choose a test set:", 
                                    choices = c("testset1", "testset2", "testset3", "testset4", "testset5")),
                        helpText("Purpose: predicting Housing costs based on different predictors",
                                 "including owner's age, income, and number of bedrooms in", 
                                 "the house. The model is trained with the recursive partition regression trees, random forest",
                                 "and the generalized boosted model algorithms. Random Forest outperformed the 3 algorithms",
                                 "and is chosen as final model. The test sets above will show how well",
                                 "it predicts. Results are shown on the scatterplot of the observed vs.",
                                 "the predicted housing costs under the -plot- tab.")
                ),
       
                mainPanel(
                        tabsetPanel(
                                
                                tabPanel('model summary', verbatimTextOutput('summary'),plotOutput("diagnostics")),
                                tabPanel('plot', plotOutput('plot'))
                             
                        )
                
                )

           )
        
))
