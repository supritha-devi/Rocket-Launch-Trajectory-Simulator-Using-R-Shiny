# Rocket Launch Trajectory Simulator

> An interactive R Shiny application for simulating and analyzing rocket trajectories using projectile-motion equations, gravitational models, and real-world geographic data.

---

## Overview

**Rocket Launch Trajectory Simulator** is an interactive Physics and Mathematics application developed using **R and Shiny**.

The application models the trajectory of a rocket from launch to landing using mathematical equations of projectile motion. Users can select a celestial body, configure launch parameters, visualize the resulting trajectory, and analyze key flight characteristics.

The application also provides a destination-based calculation mode that determines the launch conditions required to reach a selected destination.

An optional step-by-step explanation feature presents the mathematical calculations in a clear and understandable manner, making the application suitable for both simulation and educational purposes.

---

## Key Features

### Multi-Body Simulation

The application supports seven celestial bodies, each with its corresponding gravitational acceleration:

- Earth
- Moon
- Mars
- Mercury
- Venus
- Jupiter
- Saturn

### Real-World Launch Sites

For Earth-based simulations, users can select from real-world launch locations, including:

- Kennedy Space Center
- Baikonur Cosmodrome
- Satish Dhawan Space Centre, Sriharikota
- Guiana Space Centre, Kourou
- Tanegashima Space Center
- Other supported launch locations

### Simulation Modes

The application provides two calculation modes.

#### Speed and Angle Mode

Users provide:

- Celestial body
- Launch location
- Initial velocity
- Launch angle

The simulator calculates:

- Horizontal velocity
- Vertical velocity
- Time to maximum height
- Total flight time
- Maximum altitude
- Horizontal range
- Landing coordinates
- Nearest city

#### Destination Mode

Users specify:

- Starting location
- Destination
- Required calculation parameter

The application uses the geographic distance between the selected locations to determine the required launch conditions, such as initial velocity or launch angle.

### Trajectory Visualization

The simulator generates a trajectory graph representing the rocket's flight path.

The visualization identifies:

- Launch point
- Maximum altitude
- Landing point
- Flight distance

### Landing Location Detection

The calculated landing coordinates are compared against geographic city data to identify the nearest real-world city.

### Step-by-Step Explanations

An optional explanation mode presents the formulas and calculations used by the simulator in a structured, plain-language format.

This helps users understand not only the result, but also how the result was obtained.

---

## Mathematical Model

The simulator is based on standard projectile-motion equations.

### Horizontal Velocity

```text
vx = v₀ × cos(θ)

On Fri, 25 Sep, 2026, 10:47 am SUPRITHADEVI M 25AD102, <25ad102@drngpit.ac.in> wrote:

🚀 Rocket Launch Trajectory Simulator
An interactive R Shiny application that simulates a rocket's flight path using real physics and math formulas — built as a combined Physics + Mathematics mini-project.

📖 Description

This project lets you launch a virtual rocket and watch exactly what happens to it. Pick a real-world launch site on Earth (or another planet/moon), set a speed and angle, and the simulator plots the rocket's entire journey — from liftoff to peak height to landing — on an interactive graph. It also works in reverse: choose a starting point and a destination, and the app calculates the exact speed or angle needed to reach it, using real-world map distances. Every result comes with an optional step-by-step explanation, breaking down the formulas (trigonometry, gravity, motion equations) in plain language, so the user doesn't just see the answer — they understand how it was calculated.
---
Features

- 7 planets/moons to launch from (Earth, Moon, Mars, Mercury, Venus, Jupiter, Saturn) — each with its own gravity value
- Real launch sites on Earth, grouped by country (Kennedy Space Center, Baikonur, Sriharikota, Kourou, Tanegashima, and more)
- Two calculation modes:
              Know your speed & angle → find out where you'll land
              Know your start & destination → find out the speed/angle needed to get there
- Real-world landing lookup — finds the nearest real city to your rocket's landing point
- Interactive trajectory graph with peak height and landing point labeled
- Step-by-step explanation mode — walks through every formula used, with plain-English reasoning
- Formulas Used

Formula	What it calculates

vx = v0·cos(angle)	Forward speed
vy = v0·sin(angle)	Upward speed
t_peak = vy/g	Time to reach the peak
total_time = 2·t_peak	Total flight time
max_height = vy²/(2g)	Highest point reached
range = vx·total_time	Total distance traveled
range = v0²·sin(2·angle)/g	Used to solve for speed or angle in destination mode
---
Built With

R and Shiny — application framework
Base R graphics — trajectory plotting
maps package — offline city database for real-world landing lookups
---
📂 Project Structure

RocketLaunchTrajectorySimulator/ ├── Rocket Launch Trajectory Simulator Using R.Rproj ├── global.R # Shared data: gravity values, launch sites, coordinates, formulas ├── ui.R # App layout and pages ├── server.R # App logic, calculations, and page navigation └── www/ └── styles.css # App styling
---
How to Run

Open Rocket Launch Trajectory Simulator Using R.Rproj in RStudio
Install required packages (one-time): install.packages(c("shiny", "maps"))
Open ui.R, server.R, or global.R
Click Run App
---
Author
Suprithadevi M





