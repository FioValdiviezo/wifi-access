rm(list = ls())
cls <- function() cat(rep("\n",100))
wd <- "C:/Users/Z50-CORE-I5/Desktop/Social Mobility Measure/Gaps Measure"
setwd(wd)
cls()
#/************************************************************************************************************************************************
# Filename: Project
# Author: Fiorella Valdiviezo
# Date: 23/August 2021
#
# Purpose: This file generates the script to build a vis of the percentage of users who use the internet by age and state in Peru.
# Data source: ENAHO 2020 - 300 Module, INEI.
#
# Created files: -
#**************************************************************************************************************************************************/

install.packages('patchwork')
install.packages("ggthemes")
options("install.lock"=FALSE)
install.packages("ggthemes") 
install.packages('ggthemes', dependencies = TRUE, INSTALL_opts = '--no-lock')
library("devtools")
install_github(c("hadley/ggplot2", "jrnold/ggthemes"))
library(tidyverse)
library(haven)
library(patchwork)
library(ggthemes)
library(ggrepel)


# Import data
library("readxl")
data = read_excel("C:/Users/Z50-CORE-I5/Desktop/Social Mobility Measure/Gaps Measure/data.xlsx",sheet = "datos") 

# Create Sub Data 
sub1 <- data %>% 
  transmute(state= as.factor(state), edad = as.numeric(edad), wifi = internet, weight = weight) %>% 
  arrange(state, edad) %>% 
  group_by(state, edad, wifi) %>% 
  mutate(weightparc = sum(weight)) %>% 
  count(weightparc) %>% 
  ungroup() %>% 
  group_by(state, edad) %>% 
  mutate(weighttot = sum(weightparc), percent = weightparc/weighttot) %>% 
  filter(wifi == 1, edad <= 80)

state_labels <- read_excel("C:/Users/Z50-CORE-I5/Desktop/Social Mobility Measure/Gaps Measure/regiones.xlsx",
                         col_names = TRUE) %>% 
  transmute(state= as.factor(`state`), names= `region`)

sub1 <- left_join(sub1, state_labels, by = c("state" = "state")) 

highs <- sub1 %>% 
  group_by(edad) %>% 
  summarize(mean_percent = mean(percent)) %>% 
  filter(edad %in% c(6,9,12,15,17,30, 60))



# Prime
prime <- sub1 %>% 
  group_by(edad) %>% 
  summarize(mean_percent = mean(percent)) %>% 
  ggplot(aes(edad, mean_percent)) +
  geom_line(color = "#3b88b5", size = 1.2) +
  scale_x_continuous(expand = c(0,0)) +
  geom_point(data = highs, color = "#3b88b5", size = 3) +
  geom_text_repel(data = highs, aes(label = paste(round(mean_percent*100, 1), "%", sep = "")), 
                  color = "#3b88b5", size = 4, nudge_y = -0.1, nudge_x = -0.1, segment.color = 'transparent') +
  labs(x = NULL, 
       y = NULL,
       title = " Acceso a internet por edad y dominio",
       subtitle = str_wrap("El gráfico superior muestra el porcentaje promedio de usuarios que utilizan internet por edad en Perú: a los 17 años el 82.6% de los usuarios acceden a internet, 
       a partir de entonces el porcentaje comienza a reducirse. Además de los niños de 9 años, solo el 72,1% tiene acceso a Internet.
       A los 60 años, solo es el 27.2%. El gráfico inferior ilustra el porcentaje por edad y dominio geográfico.", 120)) +
  theme_tufte() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        plot.title = element_text(size = 25, hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(size = 13, hjust = 0.5),
        panel.grid = element_line(linetype = 1, color = alpha("#E5E7E9", 0.6), size = 0.5))


# Heatmap
heatmap <- ggplot(sub1, aes(x = edad, y = state, fill = percent)) +
  geom_tile(color = "white", size = 0.05) +
  geom_vline(xintercept = 60, color = "black", linetype = 1, size = 0.7) +
  scale_x_continuous(breaks = seq(6, 90, 1), position = "top", expand = c(0,0)) +
  scale_y_discrete(limits = rev(levels(sub1$state)), labels = rev(state_labels$names))  +
  scale_fill_gradient(low = "#f9f8c9", high = "#2f77af", 
                      breaks = c(0.01, 0.25, 0.50, 0.75, 1), labels = c("0%", "25%", "50%", "75%", "100%"),
                      name = "Porcentaje de usuarios que acceden a internet") +
  scale_colour_gradient2() +
  labs(x = NULL, y = NULL, caption = "Fuente: ENAHO 2020, INEI\nElaborado por Fiorella Valdiviezo (@fiolyn23)") +
  theme_tufte() +
  theme(legend.position = "bottom",
        legend.key.width = unit(1, "cm"),
        axis.text.x = element_text(angle = 90, hjust = 1),
        axis.text.y = element_text(size = 10),
        axis.ticks.y = element_blank(),
        plot.caption = element_text())

# Patchwork 
vis <- patchwork::wrap_plots(prime, heatmap, heights = c(0.3,1), ncol = 1)

# Export vis
ggsave("fv_internet_users.png", vis, width = 10, height = 12)




