% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/combine_widgets.R
\name{combineWidgets}
\alias{combineWidgets}
\title{Combine several interactive plots}
\usage{
combineWidgets(
  ...,
  list = NULL,
  nrow = NULL,
  ncol = NULL,
  title = NULL,
  rowsize = 1,
  colsize = 1,
  byrow = TRUE,
  titleCSS = "",
  header = NULL,
  footer = NULL,
  leftCol = NULL,
  rightCol = NULL,
  width = NULL,
  height = NULL
)
}
\arguments{
\item{...}{htmlwidgets to combine. If this list contains objects that are not
htmlwidgets, the function tries to convert them into a character string which
is interpreted as html content.}

\item{list}{Instead of directly passing htmlwidgets to the function, one can
pass a list of htmlwidgets and objects coercible to character. In particular,
it can be usefull if multiple htmlwidgets have been generated using a loop
function like \code{\link[base]{lapply}}.}

\item{nrow}{Number of rows of the layout. If \code{NULL}, the function will
automatically take a value such that are at least as many cells in the
layout as the number of htmlwidgets.}

\item{ncol}{Number of columns of the layout.If \code{NULL}, the function will
automatically take a value such that are at least as many cells in the
layout as the number of htmlwidgets.}

\item{title}{Title of the view.}

\item{rowsize}{This argument controls the relative size of each row. For
instance, if the layout has two rows and \code{rowsize = c(2,1)}, then the
width of the first row will be twice the one of the second one. This
argument is recycled to fit the number of rows.}

\item{colsize}{Same as rowsize but for the height of the columns of the
layout.}

\item{byrow}{If \code{TRUE}, then the layout is filled by row. Else it is
filled by column.}

\item{titleCSS}{A character containing css properties to modify the
appearance of the title of the view.}

\item{header}{Content to display between the title and the combined widgets.
It can be a single character string or html tags.}

\item{footer}{Content to display under the combined widgets. It can be a
single character string or html tags.}

\item{leftCol}{Content to display on the left of the combined widgets. It can
be a single character string or html tags.}

\item{rightCol}{Content to display on the right the combined widgets. It can
be a single character string or html tags.}

\item{width}{Total width of the layout (optional, defaults to automatic
sizing).}

\item{height}{Total height of the layout (optional, defaults to automatic
sizing).}
}
\value{
A htmlwidget object of class \code{combineWidget}. Individual widgets
  are stored in element \code{widgets} and can be extracted or updated. This
  is useful when a function returns a \code{combineWidgets} object but user
  wants to keep only one widget or to update one of them (see examples).
}
\description{
This function combines different htmlwidgets in a unique view.
}
\details{
The function only allows table like layout : each row has the same
number of columns and reciprocally. But it is possible to create more complex
layout by nesting combined htmlwidgets. (see examples)
}
\examples{
if (require(plotly)) {
  data(iris)

  combineWidgets(title = "The Iris dataset",
    plot_ly(iris, x = ~Sepal.Length, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Sepal.Width, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Petal.Length, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Petal.Width, type = "histogram", nbinsx = 20)
  )

  # Create a more complex layout by nesting combinedWidgets
  combineWidgets(title = "The iris data set: sepals", ncol = 2, colsize = c(2,1),
    plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width, type = "scatter",
            mode = "markers", color = ~Species),
    combineWidgets(
      plot_ly(iris, x = ~Sepal.Length, type = "histogram", nbinsx = 20),
      plot_ly(iris, x = ~Sepal.Width, type = "histogram", nbinsx = 20)
    )
  )

  # combineWidgets can also be used on a single widget to easily add to it a
  # title and a footer.
  require(shiny)
  comments <- tags$div(
    "Wow this plot is so ",
    tags$span("amazing!!", style = "color:red;font-size:36px")
  )

  combineWidgets(
    plot_ly(iris, x = ~Sepal.Length, type = "histogram", nbinsx = 20),
    title = "Distribution of Sepal Length",
    footer = comments
  )

  # It is also possible to combine htmlwidgets with text or other html elements
  myComment <- tags$div(
    style="height:100\%;background-color:#eee;padding:10px;box-sizing:border-box",
    tags$h2("Comment"),
    tags$hr(),
    "Here is a very clever comment about the awesome graphics you just saw."
  )
  combineWidgets(
    plot_ly(iris, x = ~Sepal.Length, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Sepal.Width, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Petal.Length, type = "histogram", nbinsx = 20),
    myComment
  )

  # Updating individual widgets.
  myWidget <- combineWidgets(
    plot_ly(iris, x = ~Sepal.Length, type = "histogram", nbinsx = 20),
    plot_ly(iris, x = ~Sepal.Width, type = "histogram", nbinsx = 20),
    ncol = 2
  )
  myWidget


  myWidget$widgets[[1]] <- myWidget$widgets[[1]] \%>\%
    layout(title = "Histogram of Sepal Length")

  myWidget$widgets[[2]] <- myWidget$widgets[[2]] \%>\%
    layout(title = "Histogram of Sepal Width")

  myWidget


  # Instead of passing directly htmlwidgets to the function, one can pass
  # a list containing htmlwidgets. This is especially useful when the widgets
  # are generated using a loop function like "lapply" or "replicate".
  #
  # The following code generates a list of 12 histograms and use combineWidgets
  # to display them.
  samples <- replicate(12, plot_ly(x = rnorm(100), type = "histogram", nbinsx = 20),
                       simplify = FALSE)
  combineWidgets(list = samples, title = "12 samples of the same distribution")
}

}
