#Primero cargamos las librerías

library("forecast")
library("aTSA")
library("car")


#Importamos los datos a usar y les damos estructura de una serie de tiempo

MA <- read.delim("C:/Users/jesus/Downloads/MAccidentes.txt",header = FALSE)

y <- ts(MA$V1, frequency = 12, start = 1973)

#Graficamos los datos para darnos una idea de cómo se comportan los datos

ts.plot(y,main="Muertes Accidentales EE.UU.(1973-1978)", col="darkblue",
        ylab="Muertes")

#Podemos ver una clara componente estacional en los datos

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(y,20, main="Autocorrelación simple")
Pacf(y,20, main="Autocorrelación parcial")

#Vemos que la función de autocorrelación no se hace completamente cero para 20
# rezagos y para la parcial tampoco se muestra muy claro, aunque después del 
# primer rezago parece hacerse 0, lo que podría llevarnos a proponer un modelo 
# con parte MA(1). Intentaremos transformar los datos para ver si se arreglan
# estos problemas. trabajaremos con log(y)

ly<- log(y)


#Graficamos los datos para darnos una idea de cómo se comportan los datos

layout(1:1)
ts.plot(ly, ylab="log(y)",main="Muertes Accidentales EE.UU.(1973-1978)", col="darkblue")

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(ly,20, main="Autocorrelación simple(log(y))")
Pacf(ly,20, main="Autocorrelación parcial(log(y))")

#Tampoco se resuelve este problema asi que por ultimo intentaremos con la
# transformación sqrt(y)


sy<- sqrt(y)


#Graficamos los datos para darnos una idea de cómo se comportan los datos

layout(1:3)
ts.plot(sy, ylab="sqrt(y)",main="Muertes Accidentales EE.UU.(1973-1978)", col="darkblue")

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(sy,20,main="Autocorrelación simple(sqrt(y))")
Pacf(sy,20, main="Autocorrelación parcial(sqrt(y))")

#Las funciones de autocorrelación se siguen comportando igual.Finalmente 
# veremos cómo se comporta la serie diferenciada ya que la original no parece 
# ser estacionaria 

layout(1:1)
ts.plot(diff(MA$V1),ylab="diff(y)",main="Diferencias de muertes accidentales", col="darkblue")

#El problema de estacionariedad parece haberse arreglado.
#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
acf(diff(ly),20, main="Autocorrelación simple(diff(log(y)))")
pacf(diff(ly),20, main="Autocorrelación parcial(diff(log(y)))") 


#Lo anterior parece indicarnos que deberíamos de ajustar un modelo MA(1) a la
# serie original diferenciada.
#Usaremos la función auto.arima para encontrar el mejor modelo 
# y la mejor transformacion

autoy<- auto.arima(y,lambda = "auto")

#Lo anterior nos indica que se trata de un modelo IMA(1,1), con componente
# estacional IMA(1,1), además el lambda usado es -0.033 lo que para facilitar
# cálculos podríamos usar lambda=0(logaritmo) y no habría mucha diferencia.

#A continuación se grafican los residuales del ajuste

layout(1:2)
plot(residuals(autoy), main="Residuos estandarizados")

plot(residuals(autoy,type='response'),main="Residuos")

### Verificamos la normalidad de los residuales### 
par(mfrow=c(1,2)) 
hist(resid(autoy),main="Histograma de residuales") 
qqnorm(resid(autoy),main="Q-Q plot de residuales") 
qqline(resid(autoy)) 

#Realizamos la prueba de Durbin-Watson

durbinWatsonTest(as.vector(residuals(autoy)))

###Prueba de estacionariedad de Dickey-Fuller para los residuales 
### del modelo seleccionado
adf.test(resid(autoy))

###Prueba de independencia de Box-Pierce para los residuales 
### del modelo seleccionado

Box.test(resid(autoy),lag=12)

#Prueba de Ljung-Box

Box.test(diff(y^(-0.033)),lag=1,type = "Ljung-Box")

Box.test(diff(y^(-0.033)),lag=12,type = "Ljung-Box")


#Graficamos los residuales y sus funciones de autocorrelación

layout(1:3)
ts.plot(resid(autoy),main="Residuales de SIMA(1,1)(1,1)",xlab="año",ylab="") 
acf(resid(autoy), main="Autocorrelación Simple",ci.col="black",ylab="") 
pacf(resid(autoy),main="Autocorrelación Parcial",ci.col="black")

#Esto parecería indicarnos que deberíamos de agregar una estructura de 
# dependencia a los errores. Por esto propondremos un modelo SIMA(1,2)(1,2)

propy<- arima(log(y),order=c(1,1,1),seas=list(order=c(0,1,1),period=12)) 

propy
autoy

#Entonces hacemos los pronósticos con este ajuste seleccionado por 
# SARIMA(0,1,1)(0,1,1)(lambda=0)

autoy1<- arima(log(y),order=c(0,1,1),seas=list(order=c(0,1,1),period=12)) 


#A continuación se grafican los residuales del ajuste

layout(1:2)
plot(residuals(autoy1), main="Residuos Estandarizados")

plot(residuals(autoy1,type='response'), main="Residuos")

### Varificamos la normalidad de los residuales### 
par(mfrow=c(1,2)) 
hist(resid(autoy1),main="Histograma de residuales") 
qqnorm(resid(autoy1),main="Q-Q plot de residuales") 
qqline(resid(autoy1)) 

#Realizamos la prueba de Durbin-Watson

durbinWatsonTest(as.vector(residuals(autoy1)))

###Prueba de estacionariedad de Dickey-Fuller para los residuales 
### del modelo seleccionado

adf.test(resid(autoy1))

###Prueba de independencia de Box-Pierce para los residuales 
### del modelo seleccionado
Box.test(resid(autoy1))

#Prueba de Ljung-Box

Box.test(diff(log(y)),lag=1,type = "Ljung-Box")

Box.test(diff(log(y)),lag=12,type = "Ljung-Box")

#Graficamos los residuales y sus funciones de autocorrelación

layout(1:3)
ts.plot(resid(autoy1),main="Residuales de SIMA(1,1)(1,1)(lambda=0)",xlab="año",ylab="") 
acf(resid(autoy1), main="Autocorrelación Simple",ci.col="black",ylab="") 
pacf(resid(autoy1),main="Autocorrelación Parcial",ci.col="black")


# Estimados y pronósticos 


layout(1:1)
fit=fitted.values(autoy1)
ten=cbind(log(y),fit)
ts.plot(ten,col=1:2,main="Muertes original y estimado por ARIMA(lambda=0)",xlab="Año"
        ,ylab="Muertes")
bandas <- expression("Muertes original", "Muertes con SARIMA(0,1,1)(0,1,1)")
legend(1973,8.9, bandas,lty=1, col=c(1,2),cex=.5)


# Pronósticos de muertes accidentales
fore = predict(autoy1, n.ahead=6)
ts.plot(ten,fore$pred,col=1:3,xlab="Año",ylab="log(Muertes)",
        main="Pronósticos de muertes accidentales(log(y))")
lines(fore$pred,col="red")
lines(fore$pred+fore$se, lty="dashed", col="blue")
lines(fore$pred-fore$se, lty="dashed", col="blue")
bandas <- expression("Muertes original", "Muertes con SARIMA(0,1,1)(0,1,1)")
legend(1973,8.9, bandas,lty=1, col=c(1,2),cex=.5)
