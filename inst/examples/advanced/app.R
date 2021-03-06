library(shiny)
library(shinyjs)
library(crudtable)
library(DBI)
library(RSQLite)


#########################################################################
# 1. Database initialization
#########################################################################

# Create an in-memory database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

# Register database cleanup on stop of the shiny app
shiny::onStop(function() { dbDisconnect(con) })

# Create an empty data frame
df <- data.frame(date=numeric(),
                 service=character(),
                 amount=numeric(),
                 discount=numeric(),
                 total=numeric(),
                 paid=logical())

# Save the data frame into SQLite as table 'invoice'
dbWriteTable(con, 'invoice', df)

# Create a Data Access Object
dao <- sqlDao(con,
              table = 'invoice',
              typecast = list(date=typecastDateToNumeric()))



#########################################################################
# 2. Static data initialization
#########################################################################

# Dictionary of services
servicePrices <- list(oil=150, tires=100, wash=30)


#########################################################################
# 3. Edit form user interface definition
#########################################################################

# Create edit form dialog
myFormUI <- function(id) {
    ns <- NS(id)
    formUI(id,
        dateInput(ns('date'), 'Date', weekstart = 1, value = Sys.Date()),
        selectInput(ns('service'), 'Service', choices = names(servicePrices)),
        disabled(
            numericInput(ns('price'), 'Unit price', value = NA)
        ),
        numericInput(ns('amount'), 'Amount', value = 1, min = 1, max = 10),
        numericInput(ns('discount'), 'Discount (%)', value = 0, min = 0, max = 10),
        disabled(
            numericInput(ns('total'), 'Total', value = NA, min = 0, max = 1000000)
        ),
        checkboxInput(ns('paid'), 'Paid', value = FALSE)
    )
}


#########################################################################
# 4. Initialize the default server-side form handler
#########################################################################

# Create standard edit form dialog handler that will be used in a custom handler
defaultFormServer <- formServerFactory(
    dao = dao,
    validators = c(
        validator('amount',
                  'Amount must be odd',
                  function(v) { !is.null(v) && !is.na(v) && v %% 2 != 0 }),
        filledValidator(names(dao$getAttributes()))
    )
)


#########################################################################
# 5. Create custom server-side form handler
#########################################################################

# Create custom edit form dialog handler
myFormServer <- function(input, output, session) {
    # first do the default behaviour
    res <- defaultFormServer(input, output, session)

    # then compute some input values
    observe({
        # must observe the load trigger to ensure the re-computation after data loading
        res$loadTrigger()

        # now we can compute some inputs
        service <- input$service
        amount <- input$amount
        discount <- input$discount
        if (!is.null(service)) {
            price <- servicePrices[[service]]
            total <- price * amount * (1 - discount / 100)
            updateNumericInput(session, 'price', value = price)
            updateNumericInput(session, 'total', value = total)
        }
    })

    # return the result of the default handler
    res
}


#########################################################################
# 6. Shiny app initialization
#########################################################################

# User Interface
ui <- fluidPage(
    titlePanel('Invoices'),
    hr(),
    crudTableUI('crud')
)

# Server-side
server <- function(input, output, session) {
    callModule(crudTable, 'crud', dao, myFormUI, myFormServer)
}

# Run the shiny app
shinyApp(ui = ui, server = server)
