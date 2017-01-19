## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(manipulateWidget)

## ----kmeans, message=FALSE-----------------------------------------------
library(plotly)
data(iris)

plotClusters <- function(xvar, yvar, nclusters) {
  clusters <- kmeans(iris[, 1:4], centers = nclusters)
  clusters <- paste("Cluster", clusters$cluster)
  
  plot_ly(x = ~iris[[xvar]], y = ~iris[[yvar]], color = ~clusters,
          type = "scatter", mode = "markers") %>% 
    layout(xaxis = list(title=xvar), yaxis = list(title=yvar))
}

# plotClusters("Sepal.Width", "Sepal.Length", 3)

## ----eval = FALSE--------------------------------------------------------
#  varNames <- names(iris)[1:4]
#  
#  manipulateWidget(
#    plotClusters(xvar, yvar, nclusters),
#    xvar = mwSelect(varNames),
#    yvar = mwSelect(varNames, value = "Sepal.Width"),
#    nclusters = mwSlider(1, 10, value = 3)
#  )

## ----eval=FALSE----------------------------------------------------------
#  manipulateWidget(
#    myPlotFun(country),
#    country = mwSelect(c("BE", "DE", "ES", "FR"))
#  )

## ----eval=FALSE----------------------------------------------------------
#  manipulateWidget(
#    myPlotFun(distribution, range, title),
#    distribution = mwSelect(choices = c("gaussian", "uniform")),
#    range = mwSlider(2000, 2100, value = c(2000, 2100), label = "period"),
#    title = mwText()
#  )

## ----eval=FALSE----------------------------------------------------------
#  help(package = "manipulateWidget")

## ----combine, warning=FALSE, out.width="100%"----------------------------
library(dygraphs)

plotRandomTS <- function(id) {
  dygraph(data.frame(x = 1:10, y = rnorm(10)), main = paste("Random plot", id))
}

combineWidgets(plotRandomTS(1), plotRandomTS(2))

## ----combine_complex_layout, , out.width="100%"--------------------------
combineWidgets(
  ncol = 2, colsize = c(2, 1),
  plotRandomTS(1),
  combineWidgets(
    ncol = 1,
    plotRandomTS(2),
    plotRandomTS(3),
    plotRandomTS(4)
  )
)

## ----combine_content, , out.width="100%", out.height=400-----------------
combineWidgets(
  plotRandomTS(1),
  plotRandomTS(2),
  plotRandomTS(3),
  plotRandomTS(4),
  title = "Four random plots",
  header = "Here goes the header content. <span style='color:red'>It can include html code</span>.",
  footer = "Here goes the footer content.",
  leftCol = "<div style='margin-top:150px;'>left column</div>",
  rightCol = "<div style='margin-top:150px;'>right column</div>"
)

## ----eval = FALSE--------------------------------------------------------
#  mydata <- data.frame(x = 1:100, y = rnorm(100))
#  manipulateWidget(
#    dygraph(mydata[range[1]:range[2], ],
#            main = title, xlab = xlab, ylab = ylab),
#    range = mwSlider(1, 100, c(1, 100)),
#    "Graphical parameters" = list(
#      title = mwText("Fictive time series"),
#      xlab = mwText("X axis label"),
#      ylab = mwText("Y axis label")
#    )
#  )

## ----eval=FALSE----------------------------------------------------------
#  mydata <- data.frame(x = 1:100, y = rnorm(100))
#  
#  myPlot <- function(type, lwd) {
#    if (type == "points") {
#      plot_ly(mydata, x= ~x, y = ~y, type = "scatter", mode = "markers")
#    } else {
#      plot_ly(mydata, x= ~x, y = ~y, type = "scatter", mode = "lines",
#              line = list(width = lwd))
#    }
#  }
#  
#  manipulateWidget(
#    myPlot(type, lwd),
#    type = mwSelect(c("points", "lines"), "points"),
#    lwd = mwSlider(1, 10, 1),
#    .display = list(lwd = type == "lines")
#  )

## ----eval=FALSE----------------------------------------------------------
#  lon <- rnorm(10, sd = 20)
#  lat <- rnorm(10, sd = 20)
#  
#  myMapFun <- function(radius, color, initial, session) {
#    if (initial) {
#      # Widget has not been rendered
#      map <- leaflet() %>% addTiles()
#    } else {
#      # widget has already been rendered
#      map <- leafletProxy("output", session) %>% clearMarkers()
#    }
#  
#    map %>% addCircleMarkers(lon, lat, radius = radius, color = color)
#  }
#  
#  manipulateWidget(myMapFun(radius, color, .initial, .session),
#                   radius = mwSlider(5, 30, 10),
#                   color = mwSelect(c("red", "blue", "green")))
#  

## ----eval=FALSE----------------------------------------------------------
#  mydata <- data.frame(
#    timeId = 1:100,
#    series1 = rnorm(100),
#    series2 = rnorm(100),
#    series3 = rnorm(100)
#  )
#  manipulateWidget(
#    dygraph(mydata[range[1]:range[2], c("timeId", series)], main = title),
#    range = mwSlider(1, 100, c(1, 100)),
#    series = mwSelect(c("series1", "series2", "series3")),
#    title = mwText(),
#    .compare = list(
#      title = list("First chart", "Second chart"),
#      series = NULL
#    )
#  )

## ----eval = FALSE--------------------------------------------------------
#  myPlotFun <- function(distribution, range, title) {
#    randomFun <- switch(distribution, gaussian = rnorm, uniform = runif)
#    myData <- data.frame(
#      year = seq(range[1], range[2]),
#      value = randomFun(n = diff(range) + 1)
#    )
#    combineWidgets(
#      ncol = 2, colsize = c(2, 1),
#      dygraph(myData, main = title),
#      combineWidgets(
#        plot_ly(x = myData$value, type = "histogram"),
#        paste(
#          "The graph on the left represents a random time series generated using a <b>",
#          distribution, "</b>distribution function.<br/>",
#          "The chart above represents the empirical distribution of the generated values."
#        )
#      )
#    )
#  
#  }
#  
#  manipulateWidget(
#    myPlotFun(distribution, range, title),
#    distribution = mwSelect(choices = c("gaussian", "uniform")),
#    range = mwSlider(2000, 2100, value = c(2000, 2100), label = "period"),
#    title = mwText()
#  )
#  

