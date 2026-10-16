# Objectives

## Purpose

Predict the load-carrying capability of a multi-angle carbon/epoxy laminate subjected to combined in-plane loads and bending/twisting moments, using Classical Lamination Theory (CLT) and a first-ply-failure (FPF) approach.

## Scope

- **Material:** IM7/3501-6 unidirectional prepreg, Vf = 0.675, 0.006 in ply thickness
- **Layup:** [0/10/20/40/60/80/90]s, 14 plies
- **Loading:** combined N_x, N_y, N_xy and M_x, M_y, M_xy
- **Failure criterion:** maximum stress, with a factor of safety of 1.5
- **Assumptions:** linear-elastic plies, perfect bonding between plies, Kirchhoff plate kinematics, no thermal or moisture effects

## Objectives

1. Compute the ply reduced stiffness matrix **Q** and transform it to the laminate axes (**Q̄**) for each ply angle.
2. Assemble the laminate **A**, **B**, and **D** stiffness matrices.
3. Solve for mid-surface strains and curvatures under the applied load set.
4. Determine and plot strains and stresses through the laminate thickness, in both laminate (x-y) and material (L-T) axes.
5. Compute margins of safety for fiber, matrix, and shear failure on the top and bottom of every ply, and identify the critical ply and failure mode.
6. Determine the critically safe load set (MoS = 0) by scaling the applied loads.

## Deliverables

| Deliverable | Location |
|---|---|
| Analysis script (MATLAB) | [`code/composite.m`](code/composite.m) |
| Written report with results | [`report.md`](report.md) |
| Through-thickness plots | [`figures/`](figures/) |

## Skills Demonstrated

- Composite laminate mechanics (CLT, ply transformations, laminate stiffness)
- Strength analysis and failure criteria for fiber-reinforced composites
- Numerical implementation and visualization in MATLAB
- Technical reporting of results, margins, and design implications
