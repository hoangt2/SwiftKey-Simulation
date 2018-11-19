library(shiny)

# Define UI for application that draws a histogram
shinyUI(fixedPage(
  tabsetPanel(
    tabPanel('SwiftKey',
           h3('SwiftKey Simulation'),
           
           h5('Created by Tung Hoang'),
           
           verticalLayout(
             textInput('inputText', ' ', width = '560px'),
             fixedRow(
               column(width = 2, textOutput('prediction1')),
               column(width = 2, textOutput('prediction2')),
               column(width = 2, textOutput('prediction3'))
             ),
             br(),
             img(src='keyboard.jpg', align = "left"),
          
             tags$head(tags$style("#prediction1{font-size: 18px ; background-color: #ededed; text-align:center}"),
                       tags$style("#prediction2{font-size: 18px ; background-color: #ededed; text-align:center}"),
                       tags$style("#prediction3{font-size: 18px ; background-color: #ededed; text-align:center}")
                       )
             )
  ),
  tabPanel('How It Works',
           withMathJax(),
           
           h4('Markov Chains & N-Grams models'),
           tags$ul(
             tags$li('In this application, we use Markov Chains with N-gram models (2-, 3- and 4-grams) to find the next most likely word.'),
             tags$li('The N-grams models are the single or combination of words, for example "thank"(1-gram), "thank you"(2-grams), "thank you for" (3-grams), etc.'),
             tags$li('N-grams were calculated using the training data which came from blogs, news and Twitter text archives'),
             tags$li('With Markov assumption, we approximate the probability of the next words by the condition on the previous word(s):')
           ),
           helpText('$$P(w_{i}|w_{1}w_{2}...w_{i-1}) = P(w_{i}|w_{i-k}...w_{i-1})$$'),
           
           h4('Interpolation'),
           tags$ul(
             tags$li('In a backoff model, we first use the 4-grams to find the most probabale word; if no such combination of previous words exists in 4-grams, we use 3-grams, otherwise 2-grams.'),
             tags$li('However,  a better approach is Linear Interpolation, i.e. combining 4-grams, 3-grams and 2-grams with certain weights (lambdas)')
           ),
           helpText('$$\\begin{aligned}P^{}(w_{i}|w_{i-1}w_{i-2}w_{i-3}) = \  \\lambda_{1}P(w_{i}|w_{i-1}) \\ + \\lambda_{2}P(w_{i}|w_{i-1}w_{i-2}) \\ + \\lambda_{3}P(w_{i}|w_{i-1}w_{i-2}w_{i-3})\\ \\end{aligned}$$'),
           helpText('$$with \\  \\lambda_{1} + \\lambda_{2} + \\lambda_{3} = 1$$'),
           
           h4('Setting the lambdas'),
           tags$ul(
             tags$li('We need to find the lambda that maximize the predicted probability of the unseen data (highest test accuracy)'),
             tags$li('So first I created a new corpus consisting of random 1000 four-words phrases and use it as the test data.'),
             tags$li('Then I made a grid search matrix for all the combination of lambda totalling 1 with each step of 0.1 to make sure that the amount of combinations is reasonable for computation (n=34)'),
             tags$li('The optimal combination of lambda is 0.5, 0.3 and 0.2 for lambda1, lambda2, and lambda3 respectively')
           ),
           
           h4('Performance'),
           tags$ul(
             tags$li('The Shiny application loads and runs very fast'),
             tags$li('The predictions are computed quickly with unoticeable delay (less than 0.2 second)'),
             tags$li('According to the test data, the accuracy rate is approximately 18%'),
             tags$li('Partly due to the small trained data (N-grams) occupying only 21Mb')
             )
           )
  )
))
