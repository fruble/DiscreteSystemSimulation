# 11/14/2020
# OR 635 Output Analysis for Project

library(readr)
library(dplyr)
library(ggplot2)

###################################################10% Demand##################################################################

ordertime <- read_delim(
  "../OutputFiles/10percent/OrderTime.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE
)
ordertime = data.frame(ordertime)

# Preparing Data
ordertimeavg1 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(WaitTime),
    std = sd(WaitTime),
    WaitTime = mean(WaitTime)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(1:5)) %>% 
  group_by(WaitTime) %>%
  summarize(
    NumberofChargers = min(NumberofChargers),
    NumberofDrones = min(NumberofDrones),
    max = min(max),
    std = min(std),
    scenario = min(scenario)
  )

ordertimeavg2 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime))

newOrderTime = inner_join(ordertimeavg1,
                          ordertimeavg2,
                          by = c("NumberofDrones", "NumberofChargers"))

# Boxplots for Wait Time

ggplot(newOrderTime, aes(x = as.factor(scenario), y = WaitTime.y)) +
  geom_boxplot() +
  geom_hline(yintercept = 30, color = "red") +
  labs(x = "Scenario", y = "Wait Time (minutes)", title = "Wait Time for Each Scenario") +
  theme_classic()

# % on time
# The line on the plot is at 95%

gl30min = newOrderTime %>%
  mutate(g30 = ifelse(WaitTime.y <= 30, "Less than 30 min", "Greater than 30 min"))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Orders Within 30 Minutes",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(values = c("Less than 30 min" = "gray68", "Greater than 30 min" = "gray30"))

# ANOVA for Wait Time

numberrows = newOrderTime %>%
  group_by(scenario) %>%
  summarize() %>%
  mutate(num = c(1:5))

fit <- aov(WaitTime.y ~ as.factor(scenario), data = newOrderTime)
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 10)
print(resm)

# Confidence Intervals on wait time
# 10 pairwise comparisons
# overall alpha = 0.05, per-comparison alpha = 0.005, per-comparison-per-side alpha = 0.0025
# using waitTime.y

outer_scens = c(1, 2, 3, 4)
inner_scens = c(2, 3, 4, 5)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_sd = sd(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_n = length(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_waitTime_10percent  = data.frame(outer, inner, lower, upper)
pairwise_CI_waitTime_10percent

# Costs Analysis

cost <- read_delim(
  "../OutputFiles/10percent/Cost.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE     # was False
)
cost = data.frame(cost)
colnames(cost) <-
  c(
    "Clock",
    "NumberofDrones",
    "NumberofChargers",
    "tractName",
    "Cost",
    "ClockTime",
    "day"
  )

costavg1 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(std = sd(cost), costavg = mean(cost)) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(1:5))

costavg2 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost) + min(NumberofDrones) * 1500 + min(NumberofChargers) *
              500) #Estimating the cost of drones and chargers

newcost = inner_join(costavg1, costavg2, by = c("NumberofDrones", "NumberofChargers"))

# Boxplots cost

ggplot(newcost, aes(x = as.factor(scenario), y = cost)) +
  geom_boxplot() +
  labs(x = "Scenario", y = "Cost", title = "") +
  theme_classic()

# ANOVA for Cost

numberrows = newcost %>%
  group_by(scenario) %>%
  summarize()

fit <- aov(cost ~ as.factor(scenario), data = newcost)#was data = data
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 5)
print(resm)

#pairwise confidence intervals for cost

outer_scens = c(1, 2, 3, 4)
inner_scens = c(2, 3, 4, 5)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_sd = sd(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_n = length(newcost[newcost$scenario == outer_scen, ]$cost)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_cost_10percent  = data.frame(outer, inner, lower, upper)
pairwise_CI_cost_10percent

# % Battery Failures

batterylevel <-
  read_delim(
    "../OutputFiles/10percent/BatteryLevel.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = TRUE
  )
batterylevel = data.frame(batterylevel)

# Preparing Data

batterylevelavg1 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0))) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(BatteryLevel),
    std = sd(BatteryLevel),
    BatteryLevel = mean(BatteryLevel)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(1:5))

batterylevelavg2 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0)))

newBatteryLevel = inner_join(batterylevelavg1,
                             batterylevelavg2,
                             by = c("NumberofDrones", "NumberofChargers"))

# Plotting the barplots
# The line on the plot is at 95%

gl30min = newBatteryLevel %>%
  mutate(g30 = ifelse(
    BatteryLevel.y > 0,
    "Day's with at least one Failure",
    "Day's with Zero Failures"
  ))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Batery Failures",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(
    values = c(
      "Day's with at least one Failure" = "gray30",
      "Day's with Zero Failures" = "gray68"
    )
  )

energyused = cost %>% 
  select(NumberofChargers, NumberofDrones, day, Cost) %>% 
  mutate(energy = Cost/7.8) %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    energy.sd = sd(energy),
    energy = mean(energy)
    )

costavg3 = costavg2 %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    Cost.sd = sd(cost),
    Cost = mean(cost)
            )

AddData = inner_join(ordertimeavg1, costavg3, by = c("NumberofChargers", "NumberofDrones"))
AddData = inner_join(AddData, energyused, by = c("NumberofChargers", "NumberofDrones"))

AddData = AddData %>% 
  select(scenario = scenario, NumberofChargers, NumberofDrones, WaitTime, WaitTime.sd = std, energy, energy.sd, cost = Cost, cost.sd = Cost.sd)
AddData$scenario = as.factor(AddData$scenario)
costvtime = ggplot(data = AddData, aes(y = AddData$WaitTime, 
                                       x = AddData$cost, 
                                       fill = scenario,
                                       color = scenario)) + 
  geom_point(size = 7)+
  ylab(label = "Wait Time")+
  theme(axis.text=element_text(size=15, face = "bold"), 
        axis.title=element_text(size=20,face="bold"),
        axis.text.x = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 25, face = "bold"),
        panel.background = element_rect(fill = "white",
                                        colour = "white",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                        colour = "gray"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                        colour = "gray"))+
  geom_pointrange(aes(ymin=WaitTime-WaitTime.sd, ymax=WaitTime+WaitTime.sd))+
  scale_x_discrete(name = "Cost", limits = seq(14000, 22000, by = 1500))+
  ggtitle(label = "Wait Time vs. Cost")
costvtime

###################################################33% Demand#################################################################

ordertime <- read_delim(
  "../OutputFiles/33percent/OrderTime.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE
)
ordertime = data.frame(ordertime)

# Preparing Data
ordertimeavg1 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(WaitTime),
    std = sd(WaitTime),
    WaitTime = mean(WaitTime)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(6:10)) %>% 
  group_by(WaitTime) %>%
  summarize(
    NumberofChargers = min(NumberofChargers),
    NumberofDrones = min(NumberofDrones),
    max = min(max),
    std = min(std),
    scenario = min(scenario)
  )

ordertimeavg2 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime))

newOrderTime = inner_join(ordertimeavg1,
                          ordertimeavg2,
                          by = c("NumberofDrones", "NumberofChargers"))

# Boxplots for Wait Time

ggplot(newOrderTime, aes(x = as.factor(scenario), y = WaitTime.y)) +
  geom_boxplot() +
  geom_hline(yintercept = 30, color = "red") +
  labs(x = "Scenario", y = "Wait Time (minutes)", title = "Wait Time for Each Scenario") +
  theme_classic()

# % on time
# The line on the plot is at 95%

gl30min = newOrderTime %>%
  mutate(g30 = ifelse(WaitTime.y <= 30, "Less than 30 min", "Greater than 30 min"))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Orders Within 30 Minutes",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(values = c("Less than 30 min" = "gray68", "Greater than 30 min" = "gray30"))

# ANOVA for Wait Time

numberrows = newOrderTime %>%
  group_by(scenario) %>%
  summarize() %>%
  mutate(num = c(6:10))

fit <- aov(WaitTime.y ~ as.factor(scenario), data = newOrderTime)
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 10)
print(resm)

#pairwise confidence intervals for wait time

outer_scens = c(6, 7, 8, 9)
inner_scens = c(7, 8, 9, 10)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_sd = sd(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_n = length(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_waitTime_33percent  = data.frame(outer, inner, lower, upper)
pairwise_CI_waitTime_33percent

# Costs Analysis

cost <- read_delim(
  "../OutputFiles/33percent/Cost.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE#was FALSE
)
cost = data.frame(cost)
colnames(cost) <-
  c(
    "Clock",
    "NumberofDrones",
    "NumberofChargers",
    "tractName",
    "Cost",
    "ClockTime",
    "day"
  )

costavg1 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(std = sd(cost), costavg = mean(cost)) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(6:10))

costavg2 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost) + min(NumberofDrones) * 1500 + min(NumberofChargers) *
              500) #Estimating the cost of drones and chargers

newcost = inner_join(costavg1, costavg2, by = c("NumberofDrones", "NumberofChargers"))

# Boxplots cost

ggplot(newcost, aes(x = as.factor(scenario), y = cost)) +
  geom_boxplot() +
  labs(x = "Scenario", y = "Cost", title = "") +
  theme_classic()

# ANOVA for Cost

numberrows = newcost %>%
  group_by(scenario) %>%
  summarize()

fit <- aov(cost ~ as.factor(scenario), data = data)
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 5)
print(resm)

# Pairwise confidence intervals for cost

outer_scens = c(6, 7, 8, 9)
inner_scens = c(7, 8, 9, 10)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_sd = sd(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_n = length(newcost[newcost$scenario == outer_scen, ]$cost)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_cost_33percent = data.frame(outer, inner, lower, upper)
pairwise_CI_cost_33percent

# % Battery Failures

batterylevel <-
  read_delim(
    "../OutputFiles/33percent/BatteryLevel.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = TRUE
  )
batterylevel = data.frame(batterylevel)

# Preparing Data

batterylevelavg1 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0))) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(BatteryLevel),
    std = sd(BatteryLevel),
    BatteryLevel = mean(BatteryLevel)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(6:10))

batterylevelavg2 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0)))

newBatteryLevel = inner_join(batterylevelavg1,
                             batterylevelavg2,
                             by = c("NumberofDrones", "NumberofChargers"))

# Plotting the barplots
# The line on the plot is at 95%

gl30min = newBatteryLevel %>%
  mutate(g30 = ifelse(
    BatteryLevel.y > 0,
    "Day's with at least one Failure",
    "Day's with Zero Failures"
  ))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Batery Failures",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(
    values = c(
      "Day's with at least one Failure" = "gray30",
      "Day's with Zero Failures" = "gray68"
    )
  )

energyused = cost %>% 
  select(NumberofChargers, NumberofDrones, day, Cost) %>% 
  mutate(energy = Cost/7.8) %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    energy.sd = sd(energy),
    energy = mean(energy)
  )

costavg3 = costavg2 %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    Cost.sd = sd(cost),
    Cost = mean(cost)
  )

AddData = inner_join(ordertimeavg1, costavg3, by = c("NumberofChargers", "NumberofDrones"))
AddData = inner_join(AddData, energyused, by = c("NumberofChargers", "NumberofDrones"))

AddData = AddData %>% 
  select(scenario = scenario, NumberofChargers, NumberofDrones, WaitTime, WaitTime.sd = std, energy, energy.sd, cost = Cost, cost.sd = Cost.sd)
AddData$scenario = as.factor(AddData$scenario)
costvtime = ggplot(data = AddData, aes(y = AddData$WaitTime, 
                                       x = AddData$cost, 
                                       fill = scenario,
                                       color = scenario)) + 
  geom_point(size = 7)+
  ylab(label = "Wait Time")+
  theme(axis.text=element_text(size=15, face = "bold"), 
        axis.title=element_text(size=20,face="bold"),
        axis.text.x = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 25, face = "bold"),
        panel.background = element_rect(fill = "white",
                                        colour = "white",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                        colour = "gray"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                        colour = "gray"))+
  geom_pointrange(aes(ymin=WaitTime-WaitTime.sd, ymax=WaitTime+WaitTime.sd))+
  scale_x_discrete(name = "Cost", limits = seq(44000, 55000, by = 1500))+
  ggtitle(label = "Wait Time vs. Cost")
costvtime

###################################################50% Demand#################################################################

ordertime <- read_delim(
  "../OutputFiles/50percent/OrderTime.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE
)
ordertime = data.frame(ordertime)

# Preparing Data

ordertimeavg1 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(WaitTime),
    std = sd(WaitTime),
    WaitTime = mean(WaitTime)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(11:15)) %>% 
  group_by(WaitTime) %>%
  summarize(
    NumberofChargers = min(NumberofChargers),
    NumberofDrones = min(NumberofDrones),
    max = min(max),
    std = min(std),
    scenario = min(scenario)
  )

ordertimeavg2 = ordertime %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(WaitTime = mean(WaitTime))

newOrderTime = inner_join(ordertimeavg1,
                          ordertimeavg2,
                          by = c("NumberofDrones", "NumberofChargers"))

# Boxplots for Wait Time

ggplot(newOrderTime, aes(x = as.factor(scenario), y = WaitTime.y)) +
  geom_boxplot() +
  geom_hline(yintercept = 30, color = "red") +
  labs(x = "Scenario", y = "Wait Time (minutes)", title = "Wait Time for Each Scenario") +
  theme_classic()

# % on time
# The line on the plot is at 95%

gl30min = newOrderTime %>%
  mutate(g30 = ifelse(WaitTime.y <= 30, "Less than 30 min", "Greater than 30 min"))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Orders Within 30 Minutes",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(values = c("Less than 30 min" = "gray68", "Greater than 30 min" = "gray30"))

# ANOVA for Wait Time

numberrows = newOrderTime %>%
  group_by(scenario) %>%
  summarize() %>%
  mutate(num = c(11:15))

fit <- aov(WaitTime.y ~ as.factor(scenario), data = newOrderTime)
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 10)
print(resm)

# Pairwise confidence intervals for wait time

outer_scens = c(11, 12, 13, 14)
inner_scens = c(12, 13, 14, 15)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_sd = sd(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y - newOrderTime[newOrderTime$scenario == inner_scen, ]$WaitTime.y)
    pairwise_n = length(newOrderTime[newOrderTime$scenario == outer_scen, ]$WaitTime.y)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_waitTime_50percent = data.frame(outer, inner, lower, upper)
pairwise_CI_waitTime_50percent

# Costs Analysis

cost <- read_delim(
  "../OutputFiles/50percent/Cost.txt",
  "\t",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = TRUE#was FALSE
)
cost = data.frame(cost)
colnames(cost) <-
  c(
    "Clock",
    "NumberofDrones",
    "NumberofChargers",
    "tractName",
    "Cost",
    "ClockTime",
    "day"
  )

costavg1 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost)) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(std = sd(cost), costavg = mean(cost)) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(11:15))

costavg2 = cost %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(cost = sum(Cost) + min(NumberofDrones) * 1500 + min(NumberofChargers) *
              500) #Estimating the cost of drones and chargers

newcost = inner_join(costavg1, costavg2, by = c("NumberofDrones", "NumberofChargers"))

# Boxplots for cost

ggplot(newcost, aes(x = as.factor(scenario), y = cost)) +
  geom_boxplot() +
  labs(x = "Scenario", y = "Cost", title = "") +
  theme_classic()

# ANOVA for Cost

numberrows = newcost %>%
  group_by(scenario) %>%
  summarize()

fit <- aov(cost ~ as.factor(scenario), data = newcost)
tukey <- TukeyHSD(fit)
tukey.result <- data.frame(tukey$`as.factor(scenario)`)
resm <- matrix(NA, nrow(numberrows), nrow(numberrows))
dimnames(resm) = list(numberrows$scenario, numberrows$scenario)
resm[lower.tri(resm)] <- round(tukey.result$p.adj, 5)
print(resm)


#pairwise confidence intervals for cost - note: this set was not tested yet
outer_scens = c(11, 12, 13, 14)
inner_scens = c(12, 13, 14, 15)
outer = c()
inner = c()
lower = c()
upper = c()
for (outer_scen in outer_scens) {
  for (inner_scen in inner_scens) {
    outer = c(outer, outer_scen)
    inner = c(inner, inner_scen)
    pairwise_mean = mean(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_sd = sd(newcost[newcost$scenario == outer_scen, ]$cost - newcost[newcost$scenario == inner_scen, ]$cost)
    pairwise_n = length(newcost[newcost$scenario == outer_scen, ]$cost)
    pairwise_CI_error = -1 * (pairwise_sd/sqrt(pairwise_n))*qt(0.0025,pairwise_n - 1)
    pairwise_CI_lower = pairwise_mean - pairwise_CI_error
    pairwise_CI_upper = pairwise_mean + pairwise_CI_error
    lower = c(lower, pairwise_CI_lower)
    upper = c(upper, pairwise_CI_upper)
  }
  inner_scens = tail(inner_scens,length(inner_scens) - 1)
}
pairwise_CI_cost_50percent = data.frame(outer, inner, lower, upper)
pairwise_CI_cost_50percent

# % Battery Failures

batterylevel <-
  read_delim(
    "../OutputFiles/50percent/BatteryLevel.txt",
    "\t",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = TRUE
  )
batterylevel = data.frame(batterylevel)

# Preparing Data

batterylevelavg1 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0))) %>%
  group_by(NumberofDrones, NumberofChargers) %>%
  summarize(
    max = max(BatteryLevel),
    std = sd(BatteryLevel),
    BatteryLevel = mean(BatteryLevel)
  ) %>%
  ungroup(NumberofChargers, NumberofDrones) %>%
  mutate(scenario = c(11:15))

batterylevelavg2 = batterylevel %>%
  group_by(NumberofChargers, NumberofDrones, day) %>%
  summarize(BatteryLevel = sum(ifelse(BatteryLevel < 0, 1, 0)))

newBatteryLevel = inner_join(batterylevelavg1,
                             batterylevelavg2,
                             by = c("NumberofDrones", "NumberofChargers"))

# Plotting the barplots
# The line on the plot is at 95%

gl30min = newBatteryLevel %>%
  mutate(g30 = ifelse(
    BatteryLevel.y > 0,
    "Day's with at least one Failure",
    "Day's with Zero Failures"
  ))

ggplot(gl30min) +
  geom_bar(aes(
    x = as.factor(scenario),
    fill = as.factor(g30),
    y = 500 * (..count.. / sum(..count..))
  )) +
  labs(fill = "Legend",
       title = "Number of Batery Failures",
       x = 'Scenario',
       y = "Percent") +
  theme_classic() +
  geom_hline(yintercept = 95, color = "red") +
  scale_fill_manual(
    values = c(
      "Day's with at least one Failure" = "gray30",
      "Day's with Zero Failures" = "gray68"
    )
  )
energyused = cost %>% 
  select(NumberofChargers, NumberofDrones, day, Cost) %>% 
  mutate(energy = Cost/7.8) %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    energy.sd = sd(energy),
    energy = mean(energy)
  )

costavg3 = costavg2 %>% 
  group_by(NumberofChargers, NumberofDrones) %>% 
  summarize(
    Cost.sd = sd(cost),
    Cost = mean(cost)
  )

AddData = inner_join(ordertimeavg1, costavg3, by = c("NumberofChargers", "NumberofDrones"))
AddData = inner_join(AddData, energyused, by = c("NumberofChargers", "NumberofDrones"))

AddData = AddData %>% 
  select(scenario = scenario, NumberofChargers, NumberofDrones, WaitTime, WaitTime.sd = std, energy, energy.sd, cost = Cost, cost.sd = Cost.sd)
AddData$scenario = as.factor(AddData$scenario)
costvtime = ggplot(data = AddData, aes(y = AddData$WaitTime, 
                                       x = AddData$cost, 
                                       fill = scenario,
                                       color = scenario)) + 
  geom_point(size = 7)+
  ylab(label = "Wait Time")+
  theme(axis.text=element_text(size=15, face = "bold"), 
        axis.title=element_text(size=20,face="bold"),
        axis.text.x = element_text(size = 15, face = "bold"),
        plot.title = element_text(size = 25, face = "bold"),
        panel.background = element_rect(fill = "white",
                                        colour = "white",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                        colour = "gray"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                        colour = "gray"))+
  geom_pointrange(aes(ymin=WaitTime-WaitTime.sd, 
                      ymax=WaitTime+WaitTime.sd))+
  scale_x_discrete(name = "Cost", limits = seq(68000, 79000, by = 1500))+
  ggtitle(label = "Wait Time vs. Cost")
costvtime
