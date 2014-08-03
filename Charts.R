library(rCharts) ## devtools::install_github("ramnathv/rCharts@dev")
library(rPlotter) ## devtools::install_github("woobe/rPlotter")
 
## Using Theoph as the demo data.
dat <- Theoph
 
## Initialise rCharts-parcoords
p1 <- rCharts$new()
p1$setLib(system.file('parcoords', package = 'rCharts'))
 
## Adjust output size
p1$set(padding = list(top = 50, bottom = 50,
left = 50, right = 50),
width = 960, height = 500)
 
## Brew some colours with rPlotter x Bart Simpson
set.seed(1234)
n_col <- length(unique(dat$Subject))
pal <- colorRampPalette(extract_colours(
"http://www.allfreevectors.com/images/Free%20Vector%20Bart%20Simpson%2002%20The%20Simpsons2980.jpg",
7), interpolate = "spline")(n_col)
 
## rCharts magic here ...
p1$set(
data = toJSONArray(dat, json = F),
range = unique(dat$Subject),
colorby = 'Subject',
colors = pal)
 
## Remember to add "afterScript" (this is needed for now)
p1$setTemplate(afterScript = '<script></script>')
 
## Save as HTML
p1$save("index.html", cdn=TRUE)
