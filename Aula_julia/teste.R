
check <- function(x, v){
    x %in% v
}

v = sample(1:10000, 100000000, replace = TRUE)

tictoc::tic()
check(23, v)
tictoc::toc()

microbenchmark::microbenchmark(a = check(23, v), unit = "seconds", times = 20L)
