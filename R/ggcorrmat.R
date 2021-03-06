#' @title Visualization of a correlalogram (or correlation matrix) using
#'   'ggplot2'/'ggcorrplot'
#' @name ggcorrmat
#' @author Indrajeet Patil
#' @return Correlation matrix plot or correlation coefficient matrix or matrix of p-values.
#'
#' @param data Dataframe from which variables specified are preferentially to be
#'   taken.
#' @param cor.vars List of vairables for which the correlation matrix is to be
#'   computed and visualized.
#' @param cor.vars.names Optional list of names to be used for `cor.vars`. The
#'   names should be entered in the same order.
#' @param output Expected output from this function: "plot" (visualization
#'   matrix) or "correlations" (correlation matrix) or #' "p-values" (matrix of
#'   p-values).
#' @param type Character, "full" (default), "upper" or "lower", display full
#'   matrix, lowe triangular or upper triangular matrix.
#' @param corr.method A character string indicating which correlation
#'   coefficient is to be computed ("pearson" (default) or "kendall", or
#'   "spearman").
#' @param digits Decides the number of decimal digits to be added into the plot
#'   (Default: 2).
#' @param sig.level Significance level (Dafault: 0.05). If the p-value in p-mat
#'   is bigger than sig.level, then the correspondi#' ng correlation coefficient
#'   is regarded as insignificant.
#' @param hc.order Logical value. If `TRUE`, correlation matrix will be
#'   hc.ordered using `hclust` function (Default is `FALSE`).
#' @param hc.method The agglomeration method to be used in `hclust` (see
#'   `?hclust`).
#' @param lab Logical value. If `TRUE`, correlation coefficient values will be
#'   displayed in the plot.
#' @param colors A vector of 3 colors for low, mid, and high correlation values.
#' @param outline.color The outline color of square or circle. Default value is
#'   "gray".
#' @param ggtheme A function, `ggplot2` theme name. Default value is
#'   theme_minimal. Allowed values are the official `ggplot2` themes including
#'   `theme_gray`, `theme_bw`, `theme_minimal`, `theme_classic`, `theme_void`,
#'   etc.
#' @param title The text for the plot title.
#' @param subtitle The text for the plot subtitle.
#' @param caption The text for the plot caption.
#' @param lab_col Color to be used for the correlation coefficient labels
#'   (applicable only when `lab = TRUE`).
#' @param lab_size Size to be used for the correlation coefficient labels
#'   (applicable only when `lab = TRUE`).
#' @param insig Character used to show specialized insignificant correlation
#'   coefficients ("pch" (default) or "blank"). If "blank", the corresponding
#'   glyphs will be removed; if "pch" is used, characters (see `pch` for
#'   details) will be added on #' the corresponding glyphs.
#' @param pch Decides the glyphs to be used for insignificant correlation
#'   coefficients (only valid when `insig = "pch"`). Default value is 4.
#' @param pch.col,pch.cex The color and the cex (size) of `pch` (only valid when
#'   `insig = "pch"`). Defaults are `pch.col = "blue"` and `pch.cex = 10`.
#' @param tl.cex,tl.col,tl.srt The size, the color, and the string rotation of
#'   text label (variable names).
#'
#' @import ggcorrplot
#' @import ggplot2
#' @import dplyr
#'
#' @importFrom stats cor
#' @importFrom tibble as_data_frame
#' @importFrom tibble rownames_to_column
#' @importFrom rlang enquo
#' @importFrom rlang quo_name
#' @importFrom crayon green
#' @importFrom crayon blue
#' @importFrom crayon yellow
#' @importFrom crayon red
#'
#' @examples
#' # to get the correlalogram
#' ggcorrmat(
#' data = iris,
#' cor.vars = c(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
#' )
#'
#' # to get the correlation matrix
#' ggcorrmat(
#' data = iris,
#' cor.vars = c(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width),
#' output = "correlations"
#' )
#' # setting output = "p-values" will return the p-value matrix
#'
#' @export

# defining the function
ggcorrmat <-
  function(data,
             cor.vars,
             cor.vars.names = NULL,
             output = "plot",
             type = "full",
             corr.method = "pearson",
             digits = 2,
             sig.level = 0.05,
             hc.order = FALSE,
             hc.method = "complete",
             lab = TRUE,
             colors = c("#6D9EC1", "white", "#E46726"),
             outline.color = "black",
             ggtheme = ggplot2::theme_gray,
             title = NULL,
             subtitle = NULL,
             caption = NULL,
             lab_col = "black",
             lab_size = 4.5,
             insig = "pch",
             pch = 4,
             pch.col = "blue",
             pch.cex = 10,
             tl.cex = 12,
             tl.col = "black",
             tl.srt = 45) {
    # creating a dataframe out of the entered variables
    df <- data %>%
      dplyr::select(.data = ., !!rlang::enquo(cor.vars)) %>%
      stats::na.omit(.)

    # renaming the columns if so desired (must be equal to the number of number of cor.vars)
    if (!is.null(cor.vars.names)) {
      # check if number of cor.vars is equal to the number of names entered
      if (length(df) != length(cor.vars.names)) {
        # display error message if not
        base::message(cat(
          crayon::red("Warning: "),
          crayon::blue(
            "The number of variable names does not equal the number of variables."
          )
        ))
      } else {
        # otherwise rename the columns with the new names
        colnames(df) <- cor.vars.names
      }
    }

    # computing correlations on all included variables
    corr.mat <-
      base::round(
        x =
          stats::cor(
            x = base::as.data.frame(df),
            method = corr.method,
            use = "everything"
          ),
        digits = digits
      )

    # compute a correlation matrix of p-values
    p.mat <-
      ggcorrplot::cor_pmat(
        x = df,
        alternative = "two.sided",
        method = corr.method
      )

    # plotting the correlalogram
    plot <- ggcorrplot::ggcorrplot(
      corr = corr.mat,
      p.mat = p.mat,
      sig.level = sig.level,
      type = type,
      hc.method = hc.method,
      hc.order = hc.order,
      lab = lab,
      outline.color = outline.color,
      ggtheme = ggtheme,
      colors = colors,
      legend.title = corr.method,
      lab_col = lab_col,
      lab_size = lab_size,
      insig = insig,
      pch = 4,
      pch.col = pch.col,
      pch.cex = pch.cex,
      tl.cex = tl.cex,
      tl.col = tl.col,
      tl.srt = tl.srt
    )

    # adding additional details to the plot
    plot <- plot +
      ggplot2::labs(
        title = title,
        subtitle = subtitle,
        caption = caption,
        xlab = NULL,
        ylab = NULL
      ) +
      ggplot2::theme(
        axis.title.x = element_blank(),
        strip.text.x = element_text(size = 12, face = "bold"),
        strip.text.y = element_text(size = 12, face = "bold"),
        strip.text = element_text(size = 12, face = "bold"),
        axis.title.y = element_blank(),
        axis.text.x = element_text(size = 12, face = "bold"),
        axis.text.y = element_text(size = 12, face = "bold"),
        axis.line = element_line(),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12, face = "bold"),
        legend.title.align = 0.5,
        legend.text.align = 0.5,
        legend.key.height = unit(1, "line"),
        legend.key.width = unit(1, "line"),
        plot.margin = unit(c(1, 1, 1, 1), "lines"),
        panel.border = ggplot2::element_rect(
          colour = "black",
          fill = NA,
          size = 1
        ),
        plot.title = ggplot2::element_text(
          color = "black",
          size = 16,
          face = "bold",
          hjust = 0.5
        ),
        plot.subtitle = ggplot2::element_text(
          color = "black",
          size = 12,
          face = "bold",
          hjust = 0.5
        )
      )

    # creating proper spacing between the legend.title and the colorbar
    plot <- legend_title_margin(plot = plot)

    # return the desired result
    if (output == "correlations") {
      # correlation matrix
      corr.mat <-
        corr.mat %>%
        base::as.data.frame(x = .) %>%
        tibble::rownames_to_column(df = ., var = "variable") %>%
        tibble::as_data_frame(x = .)
      # return the tibble
      return(corr.mat)
    } else if (output == "p-values") {
      # p-value matrix
      p.mat <-
        p.mat %>%
        base::as.data.frame(x = .) %>%
        tibble::rownames_to_column(df = ., var = "variable") %>%
        tibble::as_data_frame(x = .)
      # return the final tibble
      return(p.mat)
    } else if (output == "plot") {
      # correlalogram plot
      return(plot)
    }
  }


#' @title custom function to set upper and lower margins to legend title in
#'   ggplot2
#' @name legend_title_margin
#' @return A plot with desired margins between the legend title and the legend.
#'
#' @author Indrajeet Patil
#' @param plot Plot with the legend title whose margins need to be modified.
#' @param t.margin,b.margin Margins in grid units.
#'
#' @import grid
#' @import ggplot2
#' @import gtable
#'
#' @importFrom cowplot ggdraw
#'

legend_title_margin <- function(plot,
                                t.margin = unit(0, "mm"),
                                b.margin = unit(3, "mm")) {
  # get the plot grob
  g <- ggplot2::ggplotGrob(x = plot)

  # get the legend
  index <- base::which(x = g$layout$name == "guide-box")
  leg <- g$grobs[[index]][[1]][[1]]

  # get the legend title
  title <- leg$grobs[[4]]

  # set up the heights: for the two margins and the original title
  # unit.c produces a new unit object by combining the unit objects specified as arguments
  heights <-
    grid::unit.c(
      t.margin,
      grid::unit(x = 1, units = "grobheight", data = title),
      b.margin
    )

  # set up a column of three viewports
  vp <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 3,
      ncol = 1,
      heights = heights
    ),
    name = "vp1"
  )

  # the middle row, where the title text will appear, is named as 'child_vp'.
  child_vp <-
    grid::viewport(
      layout.pos.row = 2,
      clip = "off",
      name = "child_vp"
    )

  # put the title into a gTree containing one grob (the title) and the three viewports
  TitleText <- grid::gTree(
    children = grid::gList(title),
    vp = grid::vpTree(parent = vp, children = grid::vpList(child_vp))
  )

  # back to the legend: Set height for row 2 of legend to new height of TitleText
  leg$heights[2] <- sum(heights)

  # Add the new TitleText grob to row 2 of legend
  leg <- gtable::gtable_add_grob(
    x = leg,
    grobs = TitleText,
    t = 2,
    l = 2,
    r = 5,
    name = "TitleText"
  )

  # remove the original title
  leg$grobs <- leg$grobs[-4]
  leg$layout <- leg$layout[-4, ]

  # put the legend back into the plot
  g$grobs[[index]][[1]][[1]] <- leg

  class(g) <- c("legend_title_margin", class(g))

  # draw the plot
  g <- cowplot::ggdraw(g)

  # return the final plot
  return(g)
}
