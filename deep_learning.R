#Set your word2vec folder
setwd("...../iclr15_run/word2vec")
digits.train <- read.csv("train.txt", header=FALSE)
digits.test <- read.csv("test.txt", header=FALSE)

digits.train$V1 <- factor(digits.train$V1, levels = -1:1)
digits.test$V1 <- factor(digits.test$V1, levels = -1:1)

library(h2o)
h2o.init(nthreads=-1, max_mem_size = "32g")
h2odigits.train <- as.h2o(digits.train, destination_frame = "h2odigits")
h2odigits.test <- as.h2o(digits.test, destination_frame = "h2odigits")

xnames <- setdiff(colnames(h2odigits.train),"V1")

ex1 <- h2o.deeplearning(
x = xnames,
y = "V1",
training_frame= h2odigits.train,
activation = "Rectifier",
hidden = c(50),
epochs = 20,
adaptive_rate = FALSE,
rate = .001,
)

h2o_test <- h2o.predict(ex1, h2odigits.test)

df_test <- as.data.frame(h2o_test)

df_test$predict <- as.numeric(as.character(df_test$predict))
p_test <- df_test
p_test$p.1 <- ifelse(df_test$predict>0,pmax(df_test$p.1,df_test$p1),pmin(df_test$p.1,df_test$p1))
p_test$p1 <- ifelse(df_test$predict>0,pmin(df_test$p.1,df_test$p1),pmax(df_test$p.1,df_test$p1))
#Set your scores folder
setwd("...../iclr15_run/scores")
write.table(p_test, file = "PARAGRAPH-TEST", row.names = FALSE, col.names = FALSE, sep=" ")
