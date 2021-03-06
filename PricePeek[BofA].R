#Bank of America PricePeek

library(readr)
library(dplyr)
library(ggplot2)

df <- read_csv("./BAC.csv")
df_train <- subset(df, (df$Date < as.Date("2011-12-29")))
df_validate <- df[1510:2015,]
df_test <- df[2016:2517,]

#trained model values

mean_v<- mean(df_train$Volume)
max_v <- max(df_train$Volume)
min_v <- min(df_train$Volume)
med_v <-median(df_train$Volume)

mean_c <- df_train$Volume - mean_v

zval_vol <- (df_train$Volume - mean_v) / sd(df_train$Volume)

# Select the Values we're weighing plus zscores and z squared as new features. 

values_df <- df_train %>%
  cbind(Ones = 1) %>%
  select(Open, Low, Close) %>%
  mutate("zval" = zval_vol) %>%
  mutate("zvalsq" = zval_vol * zval_vol)

high_df <- df_train %>%
  select(High)

X <- as.matrix(values_df)
y <- as.matrix(high_df)

#Trained model

Id <- diag(ncol(X))
Id[1,1] <- 0
lambda <- 1001

w <- solve(t(X) %*% X + lambda*Id, t(X) %*% y)

# r squared for trained model

R2_train = 1 - t(y - y_hat) %*% (y - y_hat) / t(y - mean(y)) %*% (y - mean(y))

# Testing validate dataset test vs the trained model 

mean_val<- mean(df_validate$Volume)

zval_vol_val <- (df_validate$Volume - mean_val) / sd(df_validate$Volume)

values_df_val <- df_validate %>%
  cbind(Ones = 1) %>%
  select(Open, Low, Close) %>%
  mutate("zval" = zval_vol_val) %>%
  mutate("zvalsq" = zval_vol_val * zval_vol_val)

high_df_val <- df_validate %>%
  select(High)

X_val <- as.matrix(values_df_val)
y_val <- as.matrix(high_df_val)

y_hat_val <- X_val %*% w


R2_val = 1 - t(y_val - y_hat_val) %*% (y_val - y_hat_val) / t(y_val - mean(y_val)) %*% (y_val - mean(y_val))

print(R2_val)

# Testing the values from the test data set
mean_test<- mean(df_test$Volume)

zval_vol_test <- (df_test$Volume - mean_val) / sd(df_test$Volume)

values_df_test <- df_test %>%
  cbind(Ones = 1) %>%
  select(Open, Low, Close) %>%
  mutate("zval" = zval_vol_test) %>%
  mutate("zvalsq" = zval_vol_test * zval_vol_test)

high_df_test <- df_test %>%
  select(High)

X_test <- as.matrix(values_df_test)
y_test <- as.matrix(high_df_test)


y_hat_test <- X_test %*% w


R2_test = 1 - t(y_test - y_hat_test) %*% (y_test - y_hat_test) / t(y_test - mean(y_test)) %*% (y_test - mean(y_test))

print(R2_test)

#plotting historical values for train set

ggplot(data = df_train
       , aes(x = Date, y = y_hat)) +
  geom_line()

# Punching in current Data for prediction:

volup <- 59492344
volal <- 75041043

zval_volol <- (volup - volal) / sd(df_test$Volume)

p <- c(28.75, 28.74, 29.08,zval_volol, (zval_volol)^2)

price_peak <- t(w)%*%p

error_r <- median(abs(y-y_hat)/y)

error_r

View (price_peak)
y_hat <- X %*% w