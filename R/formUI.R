#' UI part of the form module (edit dialog) for editing the data of the \code{\link{crudTable}}
#'
#' @param id Shiny module identifier of the edit dialog as set by the \code{\link{crudTable}}.
#'     (The id is based on the \code{\link{crudTable}}'s namespace and ends either with
#'     \code{"newForm"} or \code{"editForm"} accordingly to whether the dialog is used for new data
#'     input or existing data update.)
#' @param ... The definition of the form, i.e. the shiny input elements whose IDs must be
#'   named after the attribute names, as expected by the DAO (see \code{\link{dataFrameDao}} or
#'   \code{\link{sqlDao}} for more information on Data Access Objects). IDs must also be namespaced,
#'   as need by the UI modules, see the example below.
#' @param newTitle A form title used for new data input
#' @param editTitle A form title used for existing data update
#' @param submitLabel Label of the submit button
#' @param cancelLabel Label of the cancel button
#'
#' @examples
#' \dontrun{
#' # A typical use of the formUI - create an edit dialog for the crudTable:
#' myFormUI <- function(id) {
#'    # create namespace - note the use of ns() below in *Input calls
#'    ns <- NS(id)
#'    formUI(id,
#'           selectInput(ns('Plant'), 'Plant', choices = levels(CO2$Plant)),
#'           selectInput(ns('Type'), 'Type', choices = levels(CO2$Type)),
#'           selectInput(ns('Treatment'), 'Treatment', choices = levels(CO2$Treatment)),
#'           numericInput(ns('conc'), 'Ambient CO2 concentration [ml/L]',
#'                        value = 100, min = 50, max = 1000),
#'           numericInput(ns('uptake'), 'CO2 uptake rates [umol/m2 sec]',
#'                        value = 0, min = 0, max = 100)
#'    )
#' }
#' }
#' @seealso \code{\link{formServerFactory}}, \code{\link{crudTable}}
#' @export
formUI <- function(id, ...,
                   newTitle = 'New',
                   editTitle = 'Edit',
                   submitLabel = 'Submit',
                   cancelLabel = 'Cancel') {
    ns <- NS(id)
    title <- ifelse(endsWith(id, '-newForm'), newTitle, editTitle)
    modalDialog(...,
                title = title,
                footer = list(
                    modalButton(cancelLabel),
                    actionButton(ns('submit'), submitLabel)
                ))
}
