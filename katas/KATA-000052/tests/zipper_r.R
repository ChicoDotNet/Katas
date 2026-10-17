# SPDX-License-Identifier: MIT
# Independent, copy-on-modify full-root editor, NOT a breadcrumb zipper.
suppressPackageStartupMessages(library(jsonlite))
set.seed(20261017)

leaf <- function(value) list(value=as.integer(value), left=NULL, right=NULL)
new_tree <- function(depth=0L) {
  root <- leaf(sample.int(20001,1L)-10001L)
  if(depth < 4L && runif(1L) < 0.62) root["left"] <- list(new_tree(depth+1L))
  if(depth < 4L && runif(1L) < 0.62) root["right"] <- list(new_tree(depth+1L))
  root
}
at_path <- function(root,path) {
  current <- root
  for(d in strsplit(path,"",fixed=TRUE)[[1L]]) {
    if(!nzchar(d)) next
    current <- current[[if(d=="L") "left" else "right"]]
    if(is.null(current)) stop("invalid path")
  }
  current
}
edit_at <- function(root,path,action,value) {
  if(!nzchar(path)) {
    if(action=="V") root$value <- as.integer(value)
    else root[if(action=="SL") "left" else "right"] <- list(leaf(value))
    return(root)
  }
  side <- if(substr(path,1L,1L)=="L") "left" else "right"
  child <- edit_at(root[[side]],substring(path,2L),action,value)
  root[side] <- list(child)
  root
}
scenarios <- list()
expected <- list()
for(i in seq_len(220L)) {
  original <- new_tree()
  base_json <- toJSON(original,auto_unbox=TRUE,null="null",digits=NA)
  current <- original  # R copy-on-modify; original must be preserved
  path <- ""
  ops <- list()
  for(step in seq_len(sample.int(35L,1L))) {
    focus <- at_path(current,path)
    options <- c("V","SL","SR",if(nzchar(path)) "U")
    if(!is.null(focus$left)) options <- c(options,"L")
    if(!is.null(focus$right)) options <- c(options,"R")
    action <- sample(options,1L)
    if(action %in% c("V","SL","SR")) {
      value <- as.integer(sample.int(20001L,1L)-10001L)
      current <- edit_at(current,path,action,value)
      ops[[length(ops)+1L]] <- list(op=action,value=value)
    } else {
      path <- if(action=="U") substr(path,1L,nchar(path)-1L) else paste0(path,action)
      ops[[length(ops)+1L]] <- list(op=action)
    }
  }
  stopifnot(identical(base_json,toJSON(original,auto_unbox=TRUE,null="null",digits=NA)))
  scenarios[[i]] <- list(root=original,ops=ops)
  expected[[i]] <- list(root=current,focusPath=path,focusValue=at_path(current,path)$value)
}
payload <- tempfile("ninja-r-zipper-",fileext=".json")
on.exit(unlink(payload),add=TRUE)
writeLines(toJSON(scenarios,auto_unbox=TRUE,null="null",digits=NA),payload,useBytes=TRUE)
stopifnot(length(commandArgs(trailingOnly=TRUE))==1L)
cli <- commandArgs(trailingOnly=TRUE)[[1L]]
output <- system2("node",args=shQuote(cli),stdin=payload,stdout=TRUE,stderr=FALSE)
stopifnot(is.null(attr(output,"status")))
got <- fromJSON(paste(output,collapse="\n"),simplifyVector=FALSE)
stopifnot(length(got)==length(expected))
for(i in seq_along(expected)) {
  if(!isTRUE(all.equal(got[[i]],expected[[i]],check.attributes=FALSE))) {
    stop(sprintf("Mismatch R direct-path/TS zipper in scenario %d",i))
  }
}
cat(sprintf("PASS: R verified %d independent persistent-tree editing histories\n",length(expected)))
