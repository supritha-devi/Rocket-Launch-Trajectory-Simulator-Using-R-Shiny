# ============================================
# server.R
# Handles: page navigation, both calculation modes,
# plotting (with fixed label spacing), and the
# step-by-step explanation wizard
# ============================================

server <- function(input, output, session) {
  
  # ---- Which "page" is currently showing ----
  screen <- reactiveVal("setup")
  explain_step <- reactiveVal(1)
  resultData <- reactiveVal(NULL)
  
  # =========================================================
  # PAGE ROUTER
  # =========================================================
  output$pageContent <- renderUI({
    if (screen() == "setup") {
      div(class = "page-container",
          h4("Step 1: Choose how you want to calculate"),
          radioButtons("mode", NULL,
                       choices = c("🎯 I know Speed & Angle" = "known_speed_angle",
                                   "🧭 I know Start & Destination" = "known_destination"),
                       selected = "known_speed_angle"),
          uiOutput("modeSpecificUI"),
          br(),
          actionButton("calculate", "🚀 Launch! (Calculate)", class = "btn-primary btn-lg")
      )
    } else if (screen() == "result") {
      div(class = "page-container",
          plotOutput("trajectoryPlot", width = "100%", height = "380px"),
          div(class = "summary-box",
              textOutput("summaryLine1"),
              textOutput("summaryLine2")
          ),
          fluidRow(
            column(6, actionButton("goExplanation", "📘 See Explanation",
                                   class = "btn-primary", width = "100%")),
            column(6, actionButton("startOver", "🔄 Start Over",
                                   class = "btn-secondary", width = "100%"))
          )
      )
    } else if (screen() == "explanation") {
      div(class = "page-container",
          uiOutput("stepDisplay"),
          uiOutput("stepNav")
      )
    }
  })
  
  # =========================================================
  # SETUP PAGE — dynamic sub-menus
  # =========================================================
  output$modeSpecificUI <- renderUI({
    req(input$mode)
    if (input$mode == "known_speed_angle") {
      tagList(
        selectInput("planet1", "🌍 Select Planet:", choices = names(gravity_values), selected = "Earth"),
        uiOutput("locationUI1"),
        uiOutput("directionUI1"),
        numericInput("speed1", "💨 Launch Speed (m/s):", value = 1000, min = 1),
        numericInput("angle1", "📐 Launch Angle (degrees):", value = 45, min = 1, max = 89)
      )
    } else {
      tagList(
        p(class = "info-note", "🌐 Note: Destination mode uses real map distances, so only Earth locations are supported for now."),
        selectInput("startSite2", "🚀 Starting Point:", choices = earth_sites,
                    selected = all_earth_site_names[1]),
        selectInput("destSite2", "🎯 Destination:", choices = earth_sites,
                    selected = all_earth_site_names[2]),
        radioButtons("knownVar2", "🤔 Which value do you already know?",
                     choices = c("Angle" = "angle", "Speed" = "speed"), selected = "angle"),
        uiOutput("knownValueUI2")
      )
    }
  })
  
  output$locationUI1 <- renderUI({
    req(input$planet1)
    if (input$planet1 == "Earth") {
      selectInput("site1", "🚀 Select Launch Site (Starting Point):", choices = earth_sites)
    } else {
      selectInput("location1", "📍 Select Location (Starting Point):",
                  choices = other_locations[[input$planet1]])
    }
  })
  
  # Only show a compass direction picker when Earth is selected —
  # needed to figure out which real-world direction the rocket lands in
  output$directionUI1 <- renderUI({
    req(input$planet1)
    if (input$planet1 == "Earth") {
      selectInput("direction1", "🧭 Launch Direction:",
                  choices = compass_choices, selected = 90)
    }
  })
  
  output$knownValueUI2 <- renderUI({
    req(input$knownVar2)
    if (input$knownVar2 == "angle") {
      numericInput("knownAngle2", "📐 Launch Angle (degrees):", value = 45, min = 1, max = 89)
    } else {
      numericInput("knownSpeed2", "💨 Launch Speed (m/s):", value = 5000, min = 1)
    }
  })
  
  # =========================================================
  # CALCULATE — runs whichever mode is active
  # =========================================================
  observeEvent(input$calculate, {
    req(input$mode)
    
    if (input$mode == "known_speed_angle") {
      req(input$planet1, input$speed1, input$angle1)
      g <- gravity_values[[input$planet1]]
      
      landing_place <- NULL
      
      if (input$planet1 == "Earth") {
        req(input$site1, input$direction1)
        start_label <- paste0(input$site1, ", Earth")
      } else {
        req(input$location1)
        start_label <- paste0(input$location1, ", ", input$planet1)
      }
      
      r <- calculate_trajectory(input$speed1, input$angle1, g)
      
      # Only Earth has real coordinates to work out a named landing spot
      if (input$planet1 == "Earth") {
        start_coord <- site_coords[[input$site1]]
        landing_coord <- destination_point(start_coord[1], start_coord[2],
                                           as.numeric(input$direction1), r$range_val)
        landing_place <- nearest_city(landing_coord$lat, landing_coord$lon)
      }
      
      resultData(list(mode = "speed_angle", r = r, start_label = start_label,
                      dest_label = NULL, landing_place = landing_place,
                      planet = input$planet1, error = NULL))
      
    } else {
      req(input$startSite2, input$destSite2, input$knownVar2)
      
      if (input$startSite2 == input$destSite2) {
        resultData(list(mode = "destination", error =
                          "⚠️ Starting point and destination can't be the same place! Please pick two different sites."))
        screen("result")
        return()
      }
      
      g <- gravity_values[["Earth"]]
      c1 <- site_coords[[input$startSite2]]
      c2 <- site_coords[[input$destSite2]]
      R <- haversine_distance(c1[1], c1[2], c2[1], c2[2])
      
      if (input$knownVar2 == "angle") {
        req(input$knownAngle2)
        v0_solved <- solve_speed_given_angle(R, input$knownAngle2, g)
        if (is.na(v0_solved)) {
          resultData(list(mode = "destination", error =
                            "⚠️ That angle can't reach the destination. Try an angle between 1° and 89°."))
          screen("result")
          return()
        }
        r <- calculate_trajectory(v0_solved, input$knownAngle2, g)
        known_val <- "angle"
      } else {
        req(input$knownSpeed2)
        angle_solved <- solve_angle_given_speed(R, input$knownSpeed2, g)
        if (is.na(angle_solved)) {
          resultData(list(mode = "destination", error =
                            "⚠️ That speed is too low to ever reach the destination. Try a higher speed."))
          screen("result")
          return()
        }
        r <- calculate_trajectory(input$knownSpeed2, angle_solved, g)
        known_val <- "speed"
      }
      
      resultData(list(mode = "destination", r = r,
                      start_label = paste0(input$startSite2, ", Earth"),
                      dest_label = paste0(input$destSite2, ", Earth"),
                      distance = R, known = known_val, planet = "Earth", error = NULL))
    }
    
    screen("result")
  })
  
  # =========================================================
  # RESULT PAGE — plot + summary
  # =========================================================
  output$trajectoryPlot <- renderPlot({
    rd <- resultData()
    req(rd)
    
    if (!is.null(rd$error)) {
      plot.new()
      text(0.5, 0.5, rd$error, cex = 1.1, col = "#c0392b")
      return(invisible())
    }
    
    r <- rd$r
    par(mar = c(4, 4, 3, 2))
    title_text <- if (!is.null(rd$dest_label)) {
      paste0(rd$start_label, "  →  ", rd$dest_label)
    } else {
      paste0("Trajectory from ", rd$start_label)
    }
    
    plot(r$path_x, r$path_y, type = "l", col = "#2C6ECB", lwd = 3,
         xlab = "Distance (m)", ylab = "Height (m)", main = title_text,
         xlim = c(0, r$range_val * 1.08),
         ylim = c(0, r$max_height * 1.28))
    grid(col = "gray90")
    
    peak_x <- r$vx * r$time_to_peak
    points(peak_x, r$max_height, pch = 19, col = "darkred")
    text(peak_x, r$max_height, labels = paste0("Peak: ", round(r$max_height, 1), " m"),
         pos = 3, col = "darkred", cex = 0.95)
    
    points(r$range_val, 0, pch = 19, col = "darkgreen")
    text(r$range_val, 0, labels = paste0("Landing: ", round(r$range_val, 1), " m"),
         pos = 3, col = "darkgreen", cex = 0.95)
  }, res = 100)
  
  output$summaryLine1 <- renderText({
    rd <- resultData(); req(rd)
    if (!is.null(rd$error)) return(rd$error)
    
    if (rd$mode == "speed_angle") {
      paste0("🚀 Launching from: ", rd$start_label, " — at ", rd$r$angle_deg,
             "° angle with a speed of ", rd$r$v0, " m/s.")
    } else {
      paste0("🚀 Starting at: ", rd$start_label, "   🎯 Destination: ", rd$dest_label,
             "  (", round(rd$distance / 1000, 1), " km away)")
    }
  })
  
  output$summaryLine2 <- renderText({
    rd <- resultData(); req(rd)
    if (!is.null(rd$error)) return("")
    r <- rd$r
    
    if (rd$mode == "speed_angle") {
      place_text <- if (!is.null(rd$landing_place)) {
        paste0(" — near ", rd$landing_place$name, ", ", rd$landing_place$country,
               " (", round(rd$landing_place$distance_km, 1), " km from that city)")
      } else if (rd$planet == "Earth") {
        " (install the 'maps' package to see the nearest real city)"
      } else {
        ""
      }
      paste0("⏱️ Flight time: ", round(r$total_time, 2), " s   🏔️ Max height: ",
             round(r$max_height, 2), " m   📍 Lands ", round(r$range_val, 2),
             " m away", place_text, ".")
    } else {
      paste0("🔧 You'll need: speed = ", round(r$v0, 2), " m/s at angle = ", round(r$angle_deg, 2),
             "°   ⏱️ ", round(r$total_time, 2), " s flight   🏔️ Peak height: ",
             round(r$max_height, 2), " m")
    }
  })
  
  # =========================================================
  # NAVIGATION between pages
  # =========================================================
  observeEvent(input$goExplanation, {
    explain_step(1)
    screen("explanation")
  })
  observeEvent(input$startOver, {
    screen("setup")
  })
  observeEvent(input$backToResult, {
    screen("result")
  })
  observeEvent(input$doneExplain, {
    screen("result")
  })
  observeEvent(input$nextStep, {
    total <- length(explanation_steps())
    explain_step(min(explain_step() + 1, total))
  })
  observeEvent(input$prevStep, {
    explain_step(max(explain_step() - 1, 1))
  })
  
  # =========================================================
  # EXPLANATION PAGE — builds the list of steps (with emojis)
  # =========================================================
  explanation_steps <- reactive({
    rd <- resultData(); req(rd); req(is.null(rd$error))
    r <- rd$r
    steps <- list()
    
    if (rd$mode == "destination") {
      steps <- append(steps, list(
        list(emoji = "🧭", title = "Finding the Real Distance",
             body = paste0(
               "We measured the real map distance between:\n\n",
               "🚀 ", rd$start_label, "\n🎯 ", rd$dest_label, "\n\n",
               "Using each place's real coordinates and a curved-Earth distance formula:\n\n",
               "Distance = ", round(rd$distance, 1), " m  (", round(rd$distance / 1000, 1), " km)"
             ))
      ))
      
      solve_body <- if (rd$known == "angle") {
        paste0(
          "You told us the angle (", r$angle_deg, "°). Using the range formula:\n\n",
          "Range = v0² × sin(2 × angle) / g\n\n",
          "We rearranged it to solve for speed:\n\n",
          "v0 = √(Range × g ÷ sin(2 × angle)) = ", round(r$v0, 2), " m/s"
        )
      } else {
        paste0(
          "You told us the speed (", r$v0, " m/s). Using the range formula:\n\n",
          "Range = v0² × sin(2 × angle) / g\n\n",
          "We rearranged it to solve for angle:\n\n",
          "angle = 0.5 × sin⁻¹(Range × g ÷ v0²) = ", round(r$angle_deg, 2), "°"
        )
      }
      steps <- append(steps, list(
        list(emoji = "🔍", title = "Solving for the Missing Value", body = solve_body)
      ))
    }
    
    steps <- append(steps, list(
      list(emoji = "🧮", title = "Splitting the Speed into Directions",
           body = paste0(
             "One launch speed actually moves in two directions at once:\n\n",
             "➡️ Forward speed = ", r$v0, " × cos(", round(r$angle_deg, 1), "°) = ", round(r$vx, 2), " m/s\n",
             "⬆️ Upward speed = ", r$v0, " × sin(", round(r$angle_deg, 1), "°) = ", round(r$vy, 2), " m/s\n\n",
             "(This is how fast it moves sideways vs upward, at the same time)"
           )),
      list(emoji = "⏳", title = "Time to Reach the Peak",
           body = paste0(
             "Gravity constantly slows the upward speed down until it hits zero — that instant is the peak.\n\n",
             "Time to peak = Upward speed ÷ gravity\n",
             "= ", round(r$vy, 2), " ÷ ", r$g, " = ", round(r$time_to_peak, 2), " s"
           )),
      list(emoji = "🏔️", title = "Maximum Height",
           body = paste0(
             "This tells us how high it goes before gravity pulls it back down.\n\n",
             "Max height = (Upward speed)² ÷ (2 × gravity)\n",
             "= ", round(r$max_height, 2), " m"
           )),
      list(emoji = "🔁", title = "Total Flight Time",
           body = paste0(
             "Going up takes exactly as long as coming back down.\n\n",
             "Total time = 2 × Time to peak\n",
             "= ", round(r$total_time, 2), " s"
           )),
      list(emoji = "📏", title = "Range (Distance Traveled)",
           body = paste0(
             "Since forward speed never changes, distance is simply speed × time.\n\n",
             "Range = Forward speed × Total time\n",
             "= ", round(r$range_val, 2), " m"
           ))
    ))
    
    steps
  })
  
  output$stepDisplay <- renderUI({
    s <- explanation_steps()
    idx <- explain_step()
    total <- length(s)
    step <- s[[idx]]
    
    div(class = "step-card",
        div(class = "step-progress", paste0("Step ", idx, " of ", total)),
        div(class = "step-emoji", step$emoji),
        h3(step$title),
        p(style = "white-space: pre-line;", step$body)
    )
  })
  
  output$stepNav <- renderUI({
    s <- explanation_steps()
    idx <- explain_step()
    total <- length(s)
    
    fluidRow(
      column(4, if (idx > 1) actionButton("prevStep", "◀ Back", width = "100%")),
      column(4, actionButton("backToResult", "⬅ Result", class = "btn-secondary", width = "100%")),
      column(4, if (idx < total) actionButton("nextStep", "Next ▶", class = "btn-primary", width = "100%")
             else actionButton("doneExplain", "✅ Done", class = "btn-success", width = "100%"))
    )
  })
}
