library(shiny)
library(stringr)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  load('data.rda', .GlobalEnv)
  
  # Function to suggest filling the word being typed
  complete_word <- function(characters){
    characters <- paste('^',characters, sep = '')
    completed.words <- filter(one, grepl(characters, word))
    completed.words <- completed.words[order(-completed.words$tf_ratio),]$word[1:3]
    return(completed.words)
  }
  
  # General function to match the prior text input to the next word in the nGrams
  match_ngrams <- function(input, ngrams, length){
    matched_terms <-  ngrams[ngrams$prior == word(input, start = -length, end = -1),]
    matched_terms$probability <- matched_terms$tf_ratio/sum(matched_terms$tf_ratio)
    matched_terms <- matched_terms[1:3,]
    matched_terms <-  matched_terms[complete.cases(matched_terms),]
    return(matched_terms)
  }
  
  # Function to predict the next word (3 top likely words)
  # From the test data, the optimal lambda parameters are set to 0.5, 0.3 and 0.2 
  # for 2-grams, 3-grams & 4-grams respectively
  
  predict_next_word <- function(input, lambda1=0.5, lambda2=0.3, lambda3=0.2){
    
    length <- str_count(input, '\\S+')
    
    if (length == 0){
      return(NULL)
    } else if (length == 1){
      match <- match_ngrams(input, two, 1)
      
    } else if (length == 2){
      match1 <- match_ngrams(input, two, 1)
      match2 <- match_ngrams(input, three,2)
      match <- merge(match1, match2, by='next', all=TRUE)
      match[is.na(match)] <- 0
      match$score <- lambda1*match$probability.x + lambda2*match$probability.y
      match <- match[order(-match$score),]
      
    } else {
      match1 <- match_ngrams(input, two, 1)
      match2 <- match_ngrams(input, three, 2)
      match3 <- match_ngrams(input, four, 3)
      match <- merge(match1, match2, by='next', all=TRUE)
      match <- merge(match, match3, by='next', all = TRUE)
      match[is.na(match)] <- 0
      match$score <- lambda1*match$probability.x + lambda2*match$probability.y + lambda3*match$probability
      match <- match[order(-match$score),]
    }
    
    return(match[1:3,'next'])
  }
  
  
  nextWord <- reactive({
    
    inputText <- input$inputText
    
    # Complete word being typed if user has not pressed space for next word
    if (inputText == ''){
      nextWord <- ' '
      
    } else if (str_sub(inputText,-1,-1) != ' '){
      characters <- word(inputText, start = -1, end = -1)
      characters <- tolower(characters)
      nextWord <- complete_word(characters)
      
    } else {
      # If user press space, we predict the next possible word
      ptm <- proc.time() # Start timing the prediction.
      
      # Cleaning the input text
      inputText <- sub("\\s+$", "", inputText)
      inputText <- tolower(inputText)
      
      nextWord <- predict_next_word(input = inputText)
      
      time <- proc.time() - ptm 
      #print(time) # Print this out if we want to check the computation time
    }
    
    nextWord[is.na(nextWord)] <- ' ' #to handle the N/A case
    
    list(inputText, nextWord, time) # Create a list to access the reactive values
  })
  
  output$prediction1 <- renderText({
    pred <- nextWord()[[2]][1]
    if (is.na(pred)){
      ' '
    } else {pred}
  })
  
  
  output$prediction2 <- renderText({
    pred <- nextWord()[[2]][2]
    if (is.na(pred)){
      ' '
    } else {pred}
  })
  
  output$prediction3 <- renderText({
    pred <- nextWord()[[2]][3]
    if (is.na(pred)){
      ' '
    } else {pred}
  })
})
