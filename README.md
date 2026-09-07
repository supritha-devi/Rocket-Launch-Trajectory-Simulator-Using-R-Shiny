# 🚀 Rocket Launch Trajectory Simulator

An interactive R Shiny application that simulates a rocket's flight path using real physics and math formulas — built as a combined Physics + Mathematics mini-project.

## 📖 Description

This project lets you launch a virtual rocket and watch exactly what happens to it. Pick a real-world launch site on Earth (or another planet/moon), set a speed and angle, and the simulator plots the rocket's entire journey — from liftoff to peak height to landing — on an interactive graph.
It also works in reverse: choose a starting point and a destination, and the app calculates the exact speed or angle needed to reach it, using real-world map distances.
Every result comes with an optional step-by-step explanation, breaking down the formulas (trigonometry, gravity, motion equations) in plain language, so the user doesn't just see the answer — they understand how it was calculated.

## ✨ Features

- 🌍 7 planets/moons to launch from (Earth, Moon, Mars, Mercury, Venus, Jupiter, Saturn) — each with its own gravity value
- 🚀 Real launch sites on Earth, grouped by country (Kennedy Space Center, Baikonur, Sriharikota, Kourou, Tanegashima, and more)
- 🎯 Two calculation modes:
  - Know your speed & angle → find out where you'll land
  - Know your start & destination → find out the speed/angle needed to get there
- 📍 Real-world landing lookup — finds the nearest real city to your rocket's landing point
- 📊 Interactive trajectory graph with peak height and landing point labeled
- 📘 Step-by-step explanation mode — walks through every formula used, with plain-English reasoning

## 🧮 Formulas Used

| Formula | What it calculates |
|---|---|
| vx = v0·cos(angle) | Forward speed |
| vy = v0·sin(angle) | Upward speed |
| t_peak = vy/g | Time to reach the peak |
| total_time = 2·t_peak | Total flight time |
| max_height = vy²/(2g) | Highest point reached |
| range = vx·total_time | Total distance traveled |
| range = v0²·sin(2·angle)/g | Used to solve for speed or angle in destination mode |

## 🛠️ Built With

- R and Shiny — application framework
- Base R graphics — trajectory plotting
- maps package — offline city database for real-world landing lookups

## 📂 Project Structure

RocketLaunchTrajectorySimulator/
├── Rocket Launch Trajectory Simulator Using R.Rproj
├── global.R      # Shared data: gravity values, launch sites, coordinates, formulas
├── ui.R          # App layout and pages
├── server.R      # App logic, calculations, and page navigation
└── www/
    └── styles.css   # App styling

## ▶️ How to Run

1. Open Rocket Launch Trajectory Simulator Using R.Rproj in RStudio
2. Install required packages (one-time): install.packages(c("shiny", "maps"))
3. Open ui.R, server.R, or global.R
4. Click Run App

## 👩‍💻 Author

Suprithadevi M
