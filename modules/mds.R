### -------------------------------------------------------------------- ###
###                            MODULE MDS
### -------------------------------------------------------------------- ###
library(edgeR)
library(RColorBrewer)
set2.palette <- brewer.pal(8, "Set2")

# TODO a nested module for glimma MDS

### FUNCTIONS
### -------------------------------------------------------------------- ###


### UI
### -------------------------------------------------------------------- ###
mdsOutput <- function(id) {
  # Create a namespace function using the provided id
  ns <- NS(id)
  
  # plotOutput(ns("mds"))
  tagList(
    fluidRow(plotOutput(ns("mds"))),
    br(),
    fluidRow(actionButton(ns("runGlimma"), label = "Glimma MDS")),
    htmlOutput(ns("glimmaMDS"))
  )
}


### SERVER
### -------------------------------------------------------------------- ###
mds <- function(input, output, session, mdsGroupingFeature, dgeObjNorm) {

  # Output the MDS 
  output$mds <- renderPlot({
    ## if there is a feature for patients clustering, plot the MDS
    ## with a different color for each group
    if (mdsGroupingFeature() != "") {
      feat <- as.factor(dgeObjNorm()$samples[, as.character(mdsGroupingFeature())])
      plotMDS(dgeObjNorm(),
              pch = 16,
              main = "MDS",
              col = set2.palette[as.numeric(feat)])
      legend(
        "topleft",
        col = set2.palette,
        pch = 16,
        legend = levels(as.factor(feat))
      )
    } else { 
      ## otherwise, just use 1 color
      plotMDS(dgeObjNorm(), 
              pch = 16, 
              main = "MDS",
              col = set2.palette[as.numeric(
                as.factor(
                  dgeObjNorm()$samples$group
                  )
                )]
      )
    }
  })
  
  # Glimma interactive MDS
  observeEvent(input$runGlimma, {
    if (mdsGroupingFeature() != "") {
      glMDSPlot(
        dgeObjNorm(),
        labels = rownames(dgeObjNorm()$samples),
        groups = dgeObjNorm()$samples[, as.character(mdsGroupingFeature())]
      )
    } else {
      glMDSPlot(dgeObjNorm(), labels = rownames(dgeObjNorm()$samples))
    }
  })
  
  output$glimmaMDS <- renderUI({
    includeHTML("glimma-plots/MDS-Plot.html")
  })
}
