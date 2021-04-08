# Discrete System Simulation Course Term Project


## About

In this project I worked with a group of two other classmates to study the potential of a hypothetical drone delivery system based out of a local Walmart store. In this simulation parameters including order arrivals, drone travel times, and drone loading times are modeled based on real information and used to evaluate the performance of different potential configurations of chargers and drones. The java simulation code works by generating events assigning them times, and then placing them in a priority queue. As events are removed from the front of the event queue and processed statistics are recorded, the simulation clock is advanced, and future events are generated and added to the queue. After running the simulation the output data is analyzed in R using boxplots, ANOVA, Tukey tests, and pairwise confidence intervals to compare the order time and cost performance of different configurations of drones and chargers.

## Instructions

To run the simulation download the java source code in the src directory and run main.java. Main will run 10 replications (days) for each combination of a nmber of drones and a number of chargers. The number of drones evaluated can be customized by changing what is looped over in line 18, and the number of chargers evaluated can be customized by modifying line 20.
