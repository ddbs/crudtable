#' Creates a data table view capable of CRUD operations.
#'
#' This shiny module allows to view data in a datatable and also add new data, modify existent
#' records or delete the records. This UI widget consists of a \code{\link[DT]{datatable}} view,
#' which contains buttons for editing and deleting of table rows, and an action button for the
#' creation of new records.
#'
#' This function is the UI part of the module. For server part see \code{\link{crudTable}}.
#'
#' @param id The ID of the widget
#' @param newButtonLabel Label of the button for adding of new records. If 'NULL', the button is not
#'   shown.
#' @param newButtonIcon Icon of the button for adding of new records
#' @param newButtonClass Class of the button for adding of new records
#' @param newButtonWidth The width of the button, e.g. '400px' or '100\%'
#' @return An editable data table widget
#' @seealso \code{\link{crudTable}}
#' @export
#' @examples
#' \dontrun{
#' library(shiny)
#' library(crudtable)
#'
#' # Create Data Access Object
#' dao <- dataFrameDao(CO2)
#'
#' # Create edit form dialog
#' myFormUI <- function(id) {
#'     ns <- NS(id)
#'     formUI(id,
#'            selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
#'            selectInput(ns('Type'), 'Type', choices = c('Quebec', 'Mississippi')),
#'            selectInput(ns('Treatment'), 'Treatment', choices = c('nonchilled', 'chilled')),
#'            numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]',
#'                         value = 100, min = 50, max = 1000),
#'            numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]',
#'                         value = 0, min = 0, max = 100),
#'     )
#' }
#'
#' # Create edit form dialog handler
#' myFormServer <- formServerFactory(dao$getAttributes())
#'
#' # User Interface
#' ui <- fluidPage(
#'     crudTableUI('crud')
#' )
#'
#' # Server-side
#' server <- function(input, output, session) {
#'     callModule(crudTable, 'crud', dao, myFormUI, myFormServer)
#' }
#'
#' # Run the shiny app
#' shinyApp(ui = ui, server = server)
#' }
crudTableUI <- function(id,
                        newButtonLabel = 'New Record',
                        newButtonIcon = icon('plus'),
                        newButtonClass = 'btn-primary',
                        newButtonWidth = NULL) {
    assert_that(is_scalar_character(id))
    assert_that(is.null(newButtonLabel) || is_scalar_character(newButtonLabel))
    assert_that(is.null(newButtonClass) || is_scalar_character(newButtonClass))
    assert_that(is.null(newButtonWidth) || is_scalar_character(newButtonWidth))

    ns <- NS(id)
    args <- list(
        shinyFeedback::useShinyFeedback(),
        shinyjs::useShinyjs()
    )
    if (!is.null(newButtonLabel)) {
        args <- c(args, list(
            actionButton(ns('newButton'),
                         label = newButtonLabel,
                         class = newButtonClass,
                         icon = newButtonIcon,
                         width = newButtonWidth),
            tags$br(),
            tags$br()
        ))
    }
    args <- c(args, list(
        DT::dataTableOutput(ns('table'))
    ))
    do.call(tagList, args)
}


