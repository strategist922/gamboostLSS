################################################################################
#
# USE THIS SCRIPT TO REPLACE ALL OCCURENCES OF *.Rout.save WITH NEW *.Rout FILES
#
# Author: Benjamin Hofner, 2013
#
# USAGE:
#   Use
#     ## To copy test output
#     Rscript copy_Rout_to_Routsave.R "path='pkg'" "vignettes=FALSE"
#     ## To copy vignette output
#     Rscript copy_Rout_to_Routsave.R "path='pkg'" "vignettes=TRUE"
#
#   or use
#     ## To copy test output
#     Rscript copy_Rout_to_Routsave.R "path='patch'" "vignettes=FALSE"
#     ## To copy vignette output
#     Rscript copy_Rout_to_Routsave.R "path='patch'" "vignettes=TRUE"
#
################################################################################

## Get command line arguments
args <- commandArgs(TRUE)
if (length(args) > 2)
    stop("specify (at maximum) two arguments (i.e., which and vignettes)")
eval(parse(text=args))
if (length(args) == 0) {
    vignettes <- FALSE
    path <- "pkg"
}

if (is.null(path))
    path <- "pkg"

if (is.null(vignettes))
    vignettes <- FALSE

which <- "gamboostLSS"
check_path <- "gamboostLSS.Rcheck/"

################################################################################
## Copy output of test files

if (vignettes == FALSE) {

    ## Get relevant file names
    ROUT <- list.files(path = check_path, pattern = ".Rout$", recursive = TRUE)
    ROUT2 <- paste(check_path, ROUT, sep ="")

    ROUT.SAVE <- list.files(path = path, pattern = ".Rout.save$", recursive = TRUE)
    ROUT.SAVE <- paste(path, "/", ROUT.SAVE, sep ="")
    ROUT.SAVE <- ROUT.SAVE[grep("test", ROUT.SAVE)]

    ## sort ROUT.SAVE
    idx <- rep(NA, length(ROUT))
    for (i in 1:length(ROUT))
        idx[i] <- grep(ROUT[i], ROUT.SAVE)
    ROUT.SAVE <- ROUT.SAVE[idx]

    cbind(ROUT2, ROUT.SAVE)

    cat("\n\nCopy *.Rout to *.Rout.save:\n---------------------------\n")

    for (i in 1:length(ROUT))
        print(file.copy(ROUT2[i], ROUT.SAVE[i], overwrite = TRUE))

    cat("#########################################################################",
        "# To revert changes simply use:",
        ifelse(path == "pkg",
               "#   git checkout -- pkg/tests",
               "#   git checkout -- patch/tests"),
        "#########################################################################",
        sep = "\n")

}

################################################################################
## Copy output of vignettes

if (vignettes == TRUE) {
    vpath <- paste(path, "vignettes", sep ="/")

    ## get vignette output as created by R CMD check:
    vROUT <- list.files(path = check_path, pattern = ".Rnw.log$")
    if (length(vROUT) > 0) {
        vROUT2 <- paste(check_path, vROUT, sep ="")

        vROUT.SAVE <- list.files(path = vpath, pattern = ".Rout.save",
                                 recursive = TRUE)
        vROUT.SAVE <- paste(vpath, vROUT.SAVE, sep = "/")

        ## sort
        filenames <- gsub("(.*)\\.Rnw\\.log", "\\1", vROUT)
        idx <- sapply(filenames, function(fn)
                      res <- grep(paste(fn, "\\.Rout\\.save$", sep=""), vROUT.SAVE))

        vROUT.SAVE <- vROUT.SAVE[idx]

        cbind(vROUT2, vROUT.SAVE)

        cat("\n\nCopy *.Rnw.log to *.Rout.save:\n---------------------------\n")

        for (i in 1:length(vROUT))
            print(file.copy(vROUT2[i], vROUT.SAVE[i], overwrite = TRUE))

        cat("#########################################################################",
            "# To revert changes simply use:",
            ifelse(path == "pkg",
                   "#   git checkout -- pkg/vignettes",
                   "#   git checkout -- patch/vignettes"),
            "#########################################################################",
            sep = "\n")
    } else {
        cat("\n\nNOTE: No changes in output of vignettes.\n\n")
    }
}
