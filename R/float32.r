### These below should be imported from the `float` package when it's windows
### version is fixed. 
setClassUnion("Int", c("integer", "matrix"))
setClass("float32",
  representation(
    Data="Int"
  )
)
float32 <- function(x){
  new("float32", Data = as.integer(x))
}
