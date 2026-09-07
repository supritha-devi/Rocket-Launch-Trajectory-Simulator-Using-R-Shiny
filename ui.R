# ============================================
# ui.R
# A single full-width container. The server swaps
# between 3 "pages": Setup -> Result -> Explanation
# ============================================

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  div(class = "app-header",
      titlePanel("🚀 Rocket Launch Trajectory Simulator")
  ),
  
  # Everything below is rendered dynamically by the server
  # based on which "page" the user is currently on.
  uiOutput("pageContent")
)
