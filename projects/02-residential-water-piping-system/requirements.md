# Project Requirements

## Background

Bernoulli's equation is adapted to viscous pipe flow using a friction factor, which itself depends on the flow velocity and the pipe geometry. Because velocity appears on both sides of the problem, the solution is an iterative guess-and-check computation.

Governing equation, with friction losses summed over each pipe section and minor losses summed over each component:

$$\frac{P_1}{\rho} + \frac{U_1^2}{2} + g z_1 = \frac{P_2}{\rho} + \frac{U_2^2}{2} + g z_2 + \sum f \frac{L}{d}\frac{U^2}{2} + \sum K \frac{U^2}{2} + W$$

The friction factor `f` is calculated from the Haaland correlation as a function of Reynolds number and relative roughness, with Reynolds number $Re = \rho U d / \mu$.

## Problem Statement

A residential water piping system supplies an upstairs shower through three pipe sections.

| Section | Material | Diameter | Length | Features |
|---|---|---|---|---|
| 1 | Commercial steel | 2.54 cm | 10 m | 550 kPa static supply pressure; abrupt contraction to section 2 |
| 2 | Drawn copper | 1.27 cm | 8 m | 6 m rise; two short-radius 90° elbows, two inline T-joints, one fully open globe valve; abrupt contraction to section 3 |
| 3 | Drawn copper | 0.95 cm | 1 m | 1 m rise; discharge to atmosphere through a showerhead (K = 1.5) |

Water is supplied at 20 °C and the shower is unheated.

## Requirements

1. Solve for the system velocity to within 1% error.
2. Report the volume flow rate.

## Deliverables

1. Written report describing the problem, the piping system, and the solution.
2. MATLAB m-file that solves the problem and reports the numerical results (velocity and flow rate). It must be well commented, organized, and run without errors.
3. Professional-style diagram of the pipe system, drafted in CAD or illustration software or by hand.