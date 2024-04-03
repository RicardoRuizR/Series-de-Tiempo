#Importamos los datos a utilizar y les damos una estructura de tiempo

C.A <- c(CA$V2,CA$V4)

y <- ts(C.A,frequency = 1,start = 1957)

#Graficamos los datos para darnos una idea de cómo se comportan los datos

ts.plot(y,main="Consumo de agua(1957-1990)", col="darkblue")

#No se ve una componente estacional en los datos

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(y,10)
Pacf(y,10)

#Estas funciones de correlación parecen indicarnos que son estadísticamente 0
# desde el primer rezago. No hay un modelo claro a proponer.

#Intentaremos transformar los datos para ver que ocurre con la serie. 
#Trabajaremos con log(y)

ly<- log(y)


#Graficamos los datos para darnos una idea de cómo se comportan los datos

layout(1:1)
ts.plot(ly,main="Consumo de agua(1957-1990)", col="darkblue")

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(ly,10)
Pacf(ly,10)

#Las gráficas se siguen comportando de la misma manera
#asi que por ultimo intentaremos con la transformación sqrt(y)


sy<- sqrt(y)


#Graficamos los datos para darnos una idea de cómo se comportan los datos

layout(1:1)
ts.plot(sy,main="Consumo de agua(1957-1990)", col="darkblue")

#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer

layout(1:2)
Acf(sy,10)
Pacf(sy,10)

#Las funciones de autocorrelación se siguen comportando igual. Finalmente 
# veremos cómo se comporta la serie diferenciada ya que la original no parece 
# ser estacionaria 

layout(1:1)
ts.plot(diff(C.A),main="Diferencias del consumo de agua")

#El problema de estacionariedad parece haberse arreglado.
#Ahora graficamos la función de autocorrelación y la función de autocorrelación
# parcial para ver si es claro el modelo a proponer
acf(diff(C.A),10)
pacf(diff(C.A),10)


#Usaremos la función auto.arima para encontrar el mejor modelo y 
#la mejor transformacion

autoy<- auto.arima(y,lambda = "auto")

#Lo anterior nos indica que el modelo propueso es un ARIMA(0,1,0) con los datos
# transformados con un lambda=0.56. Para facilitar cálculos podríamos usar
# lambda=0.5 y no habría mucha diferencia. Primero haremos un diagnóstico de 
# los residuales del ajuste hecho automaticamente.

#A continuación se grafican los residuales del ajuste

plot(residuals(autoy))

plot(residuals(autoy,type='response'))

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
Box.test(resid(autoy))

#Graficamos los residuales y sus funciones de autocorrelación

layout(1:3)
ts.plot(resid(autoy),main="Residuales de ARIMA(0,1,0)",xlab="año",ylab="") 
acf(resid(autoy), main="Autocorrelación Simple",ci.col="black",ylab="") 
pacf(resid(autoy),main="Autocorrelación Parcial",ci.col="black")

#Esto parecería indicarnos que deberíamos de agregar una estructura de 
# dependencia a los errores. Por esto propondremos un modelo SIMA(1,2)(1,2)

propy<- arima(sqrt(y),order=c(0,1,1)) 

propy
autoy

#A continuación se grafican los residuales del ajuste

layout(1:2)
plot(residuals(propy))

plot(residuals(propy,type='response'))

### Verificamos la normalidad de los residuales### 
par(mfrow=c(1,2)) 
hist(resid(propy),main="Histograma de residuales") 
qqnorm(resid(propy),main="Q-Q plot de residuales") 
qqline(resid(propy)) 

#Realizamos la prueba de Durbin-Watson

durbinWatsonTest(as.vector(residuals(propy)))

###Prueba de estacionariedad de Dickey-Fuller para los residuales 
### del modelo seleccionado
adf.test(resid(propy))

###Prueba de independencia de Box-Pierce para los residuales 
### del modelo seleccionado
Box.test(resid(propy))

#Vemos que el modelo propuesto nos da mejores resultados en los estadísticos 
# de prueba y las gráficas de residuales que el hecho por la función auto.arima

#Entonces hacemos los pronósticos con este ajuste seleccionado por 
# ARIMA(0,1,1)(lambda=0.5)

# Estimados y pronósticos 


layout(1:1)
fit=fitted.values(propy)
ten=cbind(sqrt(y),fit)
ts.plot(ten,col=1:2,main="Consumo de agua original y estimado",xlab="Año"
        ,ylab="Muertes")
bandas <- expression("Consumo original", "Consumo con ARIMA(0,1,1)")
legend(1957,0.5, bandas,lty=1, col=c(1,2),cex=.5)


# Pronósticos de muertes accidentales
fore = predict(propy, n.ahead=6)
ts.plot(ten,fore$pred,col=1:3,xlab="Año",ylab="Muertes",
        main="Pronósticos de consumo de agua")
lines(fore$pred,col="red")
lines(fore$pred+fore$se, lty="dashed", col="blue")
lines(fore$pred-fore$se, lty="dashed", col="blue")
bandas <- expression("Consumo original", "Consumo con ARIMA(0,1,1)")
legend(1957,0.5, bandas,lty=1, col=c(1,2),cex=.5)






