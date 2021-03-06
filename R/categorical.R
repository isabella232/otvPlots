# SPDX-Copyright: Copyright (c) Capital One Services, LLC 
# SPDX-License-Identifier: Apache-2.0 
# Copyright 2017 Capital One Services, LLC 
#
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
#
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
#
# Unless required by applicable law or agreed to in writing, software distributed 
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied. 
# 
# See the License for the specific language governing permissions and limitations under the License. 


###########################################
#      Plots for Categorical Data         #
###########################################
#' Create plots and summary statistics for a categorical variable
#' 
#' Output plots include a bar plot with cateogries ordered by global counts,
#' and trace plots of categories' proportions over time. This function is also
#' appliable to a binary varible, which is treated as categorical in this 
#' package. In addition to plots, a \code{data.table} of summary statistics
#' are generated, on global counts and proportions by cateory, and proportions 
#' by category over time. 
#' 
#' @inheritParams PrepData
#' @param dataFl A \code{data.table} of data; must be the output of the
#'   \code{\link{PrepData}} function. 
#' @param myVar The name of the variable to be plotted
#' @param kCategories If a categorical variable has more than \code{kCategories},
#'   trace plots of only the \code{kCategories} most prevalent categories are
#'   plotted.  
#' @param normBy The normalization factor for rate plots, can be \code{"time"}
#'   or \code{"var"}. If \code{"time"}, then for each time period of 
#'   \code{dateGp}, counts are normalized by the total counts over all 
#'   categories in that time period. This illustrates changes of categories' 
#'   proportions over time. If \code{"var"}, then for each category, its counts 
#'   are normalized by the total counts over time from only this category. This
#'   illustrates changes of categories' volumes over time.
#' @export
#' @return 
#'   \item{p}{A \code{grob} (i.e., \code{ggplot} grid) object, including a 
#'     bar plot, and trace plots of categories' proportions. If the number of 
#'     categories is larger than \code{kCategories}, then trace plots of only the
#'     \code{kCategories} most prevalent categories are be plotted. For a binary
#'     variable, only the trace plot of the less prevalent category is plotted.}
#'   \item{catVarSummary}{A \code{data.table}, contains categories' proportions 
#'     globally, and over-time in each time period in \code{dateGp}. Each row is
#'     a category of the categorical (or binary) variable \code{myVar}. The row
#'     whose \code{category == 'NA'} corresponds to missing. Categories are 
#'     ordered by global prevalence in a descending order.}
#'     
#' @seealso Functions depend on this function:
#'          \code{\link{PlotVar}},
#'          \code{\link{PrintPlots}},
#'          \code{\link{vlm}}.
#' @seealso This function depends on:
#'          \code{\link{PlotBarplot}},
#'          \code{\link{PlotRatesOverTime}},
#'          \code{\link{PrepData}}.
#'          
#' @section License:
#' Copyright 2017 Capital One Services, LLC Licensed under the Apache License,
#' Version 2.0 (the "License"); you may not use this file except in compliance
#' with the License. You may obtain a copy of the  License at
#' http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
#' or agreed to in writing, software distributed under the License is 
#' distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
#' KIND, either express or implied. See the License for the specific language 
#' governing permissions and limitations under the License.
#' @examples
#' data(bankData)
#' bankData <- PrepData(bankData, dateNm = "date", dateGp = "months", 
#'                     dateGpBp = "quarters", weightNm = NULL)
#' # Single histogram is plotted for job type since there are 12 categories
#' plot(PlotCatVar(myVar = "job", dataFl = bankData, weightNm =  NULL, 
#'                      dateNm = "date", dateGp = "months")$p)
#'                      
#' plot(PlotCatVar(myVar = "job", dataFl = bankData, weightNm = NULL, 
#'                      dateNm = "date", dateGp = "months", kCategories = 12)$p)
#'
#'
#' ## Binary data is treated as categorical,  and only the less frequent 
#' ## category is plotted over time.
#' plot(PlotCatVar(myVar = "default", dataFl = bankData, weightNm = NULL, 
#'                      dateNm = "date", dateGp = "months")$p)

PlotCatVar <- function(myVar, dataFl, weightNm = NULL, dateNm, dateGp,
                            kCategories = 9, normBy = "time") { #!# previous name: PlotDiscreteVar
  count <- NULL
  
  p <- PlotBarplot(dataFl = dataFl, myVar = myVar, weightNm = weightNm)
  newLevels <- as.character(p$data[order(-count)][[myVar]])
  
  p2 <- PlotRatesOverTime(dataFl = dataFl, dateGp = dateGp, weightNm = weightNm,
                          myVar = myVar, newLevels = newLevels, normBy = normBy,
                          kCategories = kCategories)
  
  p  <- gridExtra::arrangeGrob(ggplot2::ggplotGrob(p), p2$p, widths = c(1, 2))
  
  return(list(p = p, catVarSummary = p2$catVarSummary))
}

###########################################
#       Discrete Plotting Functions       #
###########################################
#' Creates a bar plot for a discrete (or binary) variable
#'
#' @inheritParams PlotCatVar
#' @export
#' @return A \code{ggplot} object with a histogram of \code{myVar} ordered by 
#'   category frequency
#'   
#' @seealso Functions depend on this function:
#'          \code{\link{PlotCatVar}}.
#' @seealso This function depends on:
#'          \code{\link{PrepData}}.
#'          
#' @section License:
#' Copyright 2017 Capital One Services, LLC Licensed under the Apache License,
#' Version 2.0 (the "License"); you may not use this file except in compliance
#' with the License. You may obtain a copy of the  License at
#' http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
#' or agreed to in writing, software distributed under the License is 
#' distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
#' KIND, either express or implied. See the License for the specific language 
#' governing permissions and limitations under the License.
#' @examples
#' data(bankData)
#' bankData = PrepData(bankData, dateNm = "date", dateGp = "months", 
#'                     dateGpBp = "quarters", weightNm = NULL)
#' PlotBarplot(bankData, "job")
#' 
#' ## NA will be included as a category if any NA are present
#' bankData[sample.int(.N)[1:1000], education := NA]
#' PlotBarplot(bankData, "education")

PlotBarplot <- function(dataFl, myVar, weightNm = NULL){ #!# previous name: PlotHistogram

  count <- NULL
  
  ## A subset dataset to work on
  dataSub <- dataFl[, c(myVar, weightNm), with = FALSE]
  ## NA is converted to a character, i.e., treated as a new category
  dataSub[is.na(get(myVar)) | get(myVar) == "", (myVar) := "NA"]
  
  ## Create glbTotals, a frequency table of myVar 
  if (is.null(weightNm)) {
    glbTotals <- dataSub[, list(count = .N), by = myVar]
  } else {
    glbTotals <- dataSub[, list(count = sum(get(weightNm))), by = myVar]
  }
  
  ## Create newLevels, a vector of category names, in descending order of counts
  newLevels <- unlist(glbTotals[order(-count), myVar, with = FALSE])
  glbTotals[, (myVar) := factor(get(myVar), levels = newLevels)]
  
  p <- ggplot2::ggplot(glbTotals, ggplot2::aes_string(x = myVar,
                                                      y = "count",
                                                      group = myVar)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::scale_x_discrete(labels = abbreviate, breaks = newLevels) +
    ggplot2::theme(text = ggplot2::element_text(size = 10))
  return(p)
}


#' Creates trace plots of categories' proportions over time for a discrete (or
#' binary) variable
#'
#' @inheritParams PlotCatVar
#' @param newLevels categories of \code{myVar} in order of global frequency
#' @export
#' @return A list:
#'   \item{p}{\code{ggplot} object, trace plots of categories' proportions 
#'     \code{myVar} over time.}
#'   \item{catVarSummary}{A \code{data.table}, contains categories' proportions 
#'     globally, and over-time in each time period in \code{dateGp}. Each row is
#'     a category of the categorical (or binary) variable \code{myVar}. The row
#'     whose \code{category == 'NA'} corresponds to missing. Categories are 
#'     ordered by global prevalence in a descending order.}
#'     
#' @seealso Functions depend on this function:
#'          \code{\link{PlotCatVar}}.
#' @seealso This function depends on:
#'          \code{\link{PrepData}}.
#'          
#' @section License:
#' Copyright 2017 Capital One Services, LLC Licensed under the Apache License,
#' Version 2.0 (the "License"); you may not use this file except in compliance
#' with the License. You may obtain a copy of the  License at
#' http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
#' or agreed to in writing, software distributed under the License is 
#' distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
#' KIND, either express or implied. See the License for the specific language 
#' governing permissions and limitations under the License.
#' @examples
#' data(bankData)
#' bankData$weight = rpois(nrow(bankData), 5)
#' bankData <- PrepData(bankData, dateNm = "date", dateGp = "months", 
#'                      dateGpBp = "quarters", weightNm = "weight")
#' PlotRatesOverTime(dataFl = bankData, dateGp = "months", weightNm = "weight",
#'                   myVar = "job", newLevels = NULL, normBy = "time")
#' 
PlotRatesOverTime <- function(dataFl, dateGp, myVar, normBy = "time",
                             weightNm = NULL, newLevels = NULL, kCategories = 9){ #!# previous name: PlotHistOverTime
  N.x <- NULL
  N.y <- NULL
  rate <- NULL
  N <- NULL
  count <- NULL
  global_count <- NULL
  global_rate <- NULL
  variable <- NULL
  
  ## A subset dataset to work on
  dataSub <- dataFl[, c(dateGp, myVar, weightNm), with = FALSE]
  ## NA is converted to a character, i.e., treated as a new category
  dataSub[is.na(get(myVar)) | get(myVar) == "", (myVar) := "NA"]
  
  ## Create glbTotals, a frequency table of myVar 
  ## Create newLevels, a vector of category names, in descending order of counts
  if (is.null(newLevels)){
    if (is.null(weightNm)) {
      glbTotals <- dataSub[, list(count = .N), by = myVar]
    } else {
      glbTotals <- dataSub[, list(count = sum(get(weightNm))), by = myVar]
    }
    
    newLevels <- glbTotals[order(-count), myVar, with = FALSE][[myVar]]
  }
  
  ## Compute counts by category and time
  if (is.null(weightNm)) {
    countData <- dataSub[, .N, by = c(myVar, dateGp)]
    if (normBy == "time"){
      countBy <- dataSub[, .N, by = c(dateGp)]
    } else {
      if (normBy == "var") {
        countBy <- dataSub[, .N, by = c(myVar)]
      }
    }
  } else {
    countData <- dataSub[, list(N = sum(get(weightNm))), by = c(myVar, dateGp)]
    if (normBy == "time"){
      countBy <- dataSub[, list(N = sum(get(weightNm))), by = c(dateGp)]
    } else {
      if (normBy == "var") {
        countBy <- dataSub[, list(N = sum(get(weightNm))), by = c(myVar)]
      }
    }
  }
  
  ## Make sure countData contains all cateogires and all times
  crossLevels <- CJ(unique(countData[[dateGp]]), unique(countData[[myVar]]))
  setnames(crossLevels, c("V1", "V2"), c(dateGp, myVar))
  countData <- merge(crossLevels, countData, all.x = TRUE, by = c(dateGp, myVar))
  countData[is.na(N), N := 0]
  countData[, (myVar) := factor(get(myVar), levels = newLevels)]
  
  ## Combine countData (numerator) and countBy (denominator) as rateBy
  if (normBy == "time"){
    rateBy <- merge(countData, countBy, by = dateGp)
  } else {
    if (normBy == "var") {
      rateBy  <- merge(countData, countBy, by = myVar)
    }
  }
  
  ## Compute the rates: 
  ## For a certain time, N.x is the count of the category, N.y is the total counts
  rateBy[, rate := N.x / N.y]
  rateBy[, (myVar) := factor(get(myVar), levels = newLevels)]
  
  ## Compute summary statistics in a wide format
  cbytime = copy(rateBy);
  names(cbytime)[names(cbytime) == myVar] = 'category'
  names(cbytime)[names(cbytime) == dateGp] = 'date_group'
  ## Compute global counts and rates
  cglobal = cbytime[, list(global_count = sum(N.x)), by = 'category'];
  cglobal[, global_rate := global_count / sum(global_count)];
  ## Change cbytime into the wide format
  cbytime = dcast(cbytime[, c('date_group', 'category', 'rate')], 
                  category ~ date_group, value.var = 'rate');
  ## Combine cglobal into cbytime
  cbytime = merge(cglobal, cbytime, by = 'category')
  ## Add a column: variable
  cbytime[, variable := myVar];
  setcolorder(cbytime, c(ncol(cbytime), 1:(ncol(cbytime) - 1)))
  ## Add a row of NA being all zero, if no missing
  if('NA' %in% cbytime$category == FALSE){
    cbytime = rbind(cbytime, as.list(rep(NA, ncol(cbytime)))) 
    cbytime[nrow(cbytime), 1:2] = list(myVar, 'NA')
    cbytime[nrow(cbytime), 3:(ncol(cbytime))] = 0;
  }
  
  ## Plot less frequent category only for a binary variable.
  ## This helps when there is a large class imbalance, because the range of y-axis for all trace plots is the same.
  if (length(newLevels) == 2) {
    rateBy <- rateBy[get(myVar) == newLevels[2]]
  }
  
  if(length(newLevels) <= kCategories){
    p <- ggplot2::ggplot(rateBy,
                         ggplot2::aes_string(x = dateGp, y = "rate"))   
  } else {
    p <- ggplot2::ggplot(rateBy[get(myVar) %in% newLevels[1:kCategories]],
                         ggplot2::aes_string(x = dateGp, y = "rate"))
  }
  
  p <- p +
    ggplot2::geom_line(stat = "identity")  +
    ggplot2::facet_wrap(stats::as.formula(paste("~", myVar))) +
    ggplot2::ylab("") +
    ggplot2::scale_x_date() +
    ggplot2::theme(axis.text.x=ggplot2::element_text(angle = 30, hjust = 1)) +
    ggplot2::scale_y_continuous(labels=scales::percent)
  
  return(list(p = p, catVarSummary = cbytime));
  
}
