install.packages("pacman")
library(pacman)
pacman::p_load(pacman, dplyr, ggplot2, rio, gridExtra, scales, ggcorrplot, caret, e1071)

df=read.csv("C:/Users/SANTHOSH RAM/Documents/project/archive (2)/train.csv")
head(df)
summary(df)
plot(train$ram,train$price_range,main="Ram VS Price range",col="blue",type='l',xlab = "RAM",ylab="Price Range")
plot(train$int_memory,train$price_range,main="Memory VS Price range",col="red",type='l',xlab = "Internal memory",ylab="Price Range")
threeg=table(train$three_g)
fourg=table(train$four_g)
pie_labels <- paste0(round(100 * threeg/sum(threeg), 2), "%")
pie(threeg, labels = pie_labels)
pie_labels2 <- paste0(round(100 * fourg/sum(fourg), 2), "%")
pie(fourg, labels = pie_labels2)




corr <- round(cor(df), 8)
ggcorrplot(corr)

regmodel=lm(price_range~ram+battery_power+px_height+px_width,data=df)
regmodel
summary(regmodel)

df$blue <- as.factor(df$blue)
df$dual_sim <- as.factor(df$dual_sim)
df$four_g <- as.factor(df$four_g)
df$price_range <- as.factor(df$price_range)

p1 <-  ggplot(df, aes(x=blue, fill=blue)) +
  theme_bw() +
  geom_bar() +
  ylim(0, 1050) +
  labs(title = "Bluetooth") +
  scale_x_discrete(labels = c('Not Supported','Supported'))
p2 <- ggplot(df, aes(x=dual_sim, fill=dual_sim)) +
  theme_bw() +
  geom_bar() +
  ylim(0, 1050) +
  labs(title = "Dual Sim") +
  scale_x_discrete(labels = c('Not Supported','Supported'))
p3 <- ggplot(df, aes(x=four_g, fill=four_g)) +
  theme_bw() +
  geom_bar() +
  ylim(0, 1050) +
  labs(title = "4 G") +
  scale_x_discrete(labels = c('Not Supported','Supported'))
grid.arrange(p1, p2, p3, nrow = 1)

prop.table(table(df$blue)) # cell percentages
prop.table(table(df$dual_sim)) # cell percentages
prop.table(table(df$four_g)) # cell percentages

p1 <-  ggplot(df, aes(x=price_range, y = battery_power, color=price_range)) +
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4) +
  labs(title = "Battery Power vs Price Range")
p2 <- ggplot(df, aes(x=price_range, y = mobile_wt, color=price_range)) +
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4) +
  labs(title = "Phone Weight vs Price Range")
p3 <- ggplot(df, aes(x=price_range, y = ram, color=price_range)) +
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=4) +
  labs(title = "RAM vs Price Range")
grid.arrange(p1, p2, p3, nrow = 1)

data = data.frame(MagaPixels = c(df$fc, df$pc), 
                  Camera = rep(c("Front Camera", "Primary Camera"), 
                               c(length(df$fc), length(df$pc))))
ggplot(data, aes(MagaPixels, fill = Camera)) + 
  geom_bar(position = 'identity', alpha = .5)

df$blue <- as.numeric(df$blue)
df$dual_sim <- as.numeric(df$dual_sim)
df$four_g <- as.numeric(df$four_g)
df$price_range <- as.numeric(df$price_range)

## 75% of the sample size
smp_size <- floor(0.75 * nrow(df))

# set the seed to make our partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(df)), size = smp_size)

train <- df[train_ind, ]
test <- df[-train_ind, ]

x_train <- subset(train, select = -price_range)
y_train <- train$price_range
x_test <- subset(test, select = -price_range)
y_test <- test$price_range

model <- svm(x_train, y_train, type = 'C-classification',kernel = 'linear') 
print(model)
summary(model)

pred <- predict(model, x_test)

pred <- as.factor(pred)
y_test <- as.factor(y_test)
confusionMatrix(y_test, pred)
