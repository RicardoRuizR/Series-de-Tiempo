# Consumo de agua

Se va a analizar el conjunto de datos MAccidentes.txt para elegir el modelo que mejor se ajuste a los datos y generar pronósticos hacia futuro dependiendo de la unidad de tiempo.

El archivo MAccidentes.txt contiene el número de muertes por accidentes mensuales en Estados Unidos. La base de datos cuenta con 72 registros que van de 1973 a 1979.

# Análisis

Importamos los datos a utilizar y les damos una estructura de series de tiempo con periodicidad anual.

![Gráfica de los datos como serie de tiempo](/imagenes/Grafica1.png)

Se ve claramente una componente estacional en los datos por lo que vamos a tomar este acercamiento en el análisis.

Ahora graficamos la función de autocorrelación y la función de autocorrelación parcial para ver si es claro el modelo a proponer.

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica2.png)

Vemos que la función de autocorrelación no se hace completamente cero para 20 rezagos y para la parcial tampoco se muestra muy claro, aunque después del primer rezago parece hacerse 0, lo que podría llevarnos a proponer un modelo con parte MA(1).

Transformamos los datos con el logaritmo para ver como se comporta la serie y proponer con mayor certeza un modelo. 

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica3.png)

Ahora trabajando con la serie diferenciada obtenemos las siguientes gráficas.

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica4.png)

Lo anterior parece indicarnos que deberíamos de ajustar un modelo MA(1) a la serie original diferenciada. Ahora usando la función autoarima nos dice que usemos la transformación y^-0.033 por lo que el modelo inicial a proponer es un IMA(1,1) con componente estacional IMA(1,1).

Tomando este ajuste hagamos algunos diagnósticos con los residuales.

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica5.png)

Comprobemos la normalidad de stos residuales.

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica6.png)

Podemos ver que los residuos se ajustan a una distribución normal, aunque no tan bien.
Ahora obtengamos distintos estadísticos con estos residuales.

|Durbin-Watson | Dickey-Fuller(p) | Box-Pierce(p) | Ljung-Box(lag=1)p | Ljung-Box(lag=12)p |
|--------------|------------------|---------------|-------------------|--------------------|
| 1.9265       | 0.01             | 0.9018        | 0.9734            | 1.396e-09          |

De los estadísticos anteriores podemos decir varias cosas.

- Los errores no están correlacionados.(Durbin-Watson)
- No hay raíces unitarias.(Dickey-Fuller)
- Los errores se distribuyen de forma independientes.(Box-Pierce)
- Los datos de la serie son no correlacionados entre ellos pero sí cuando pensamos en una repetición
anual.(Ljung-Box)

Como la transformación obtenida automáticamente es muy cercana al 0 podemos proponer un nuevo modelo con los datos transformados usando el logaritmo natural para transformar los datos pero ahora sin tomar las diferencias pues el proceso ya es estacionario. Las funciones de autocorrelación de estos datos ya las observamos, así, propondremos un modelo SARIMA(0,1,1)(0,1,1).

Obtenemos los AIC de ambos modelos siendo estos
 
| Modelo automático | Modelo propuesto |
|-------------------|------------------|
| -248              | -235             | 
 
 Como estos valores del AIC son muy cercanos haremos un diagnóstico de los residuos para ver qué modelo seleccionamos. Hagamos los diagnósticos necesarios para este nuevo modelo.

  ![Gráfica de las funciones de autocorrelación](/imagenes/Grafica7.png)
  
Haciendo la prueba de normalidad de los residuales.

![Gráfica de las funciones de autocorrelación](/imagenes/Grafica8.png)

Vemos que estos residuales se aproximan mejor a la distribución normal ajustandose mejor a la linea
recta. Ahora obtengamos distintos estadísticos con estos residuales.

|Durbin-Watson | Dickey-Fuller(p) | Box-Pierce(p) | Ljung-Box(lag=1)p | Ljung-Box(lag=12)p |
|--------------|------------------|---------------|-------------------|--------------------|
|2.03          |  0.01            | 0.7829        |  1.474e-09        |   2.2e-16          |

De los estadísticos anteriores podemos decir varias cosas.
- Los errores no están correlacionados.(Durbin-Watson)
- No hay raíces unitarias.(Dickey-Fuller)
- Los errores se distribuyen de forma independientes.(Box-Pierce)
- Los datos de la serie son no correlacionados entre ellos ni cuando pensamos en una repetición
anual.(Ljung-Box)
Finalmente decidimos hacer las estimaciones y pronósticos con el modelo propuesto.

  ![Gráfica de las funciones de autocorrelación](/imagenes/Grafica2.png)

Decidimos quedarnos con el modelo propuesto ya que tomando en cuenta su diagnóstico de residuales
y comparándolo con el del modelo hecho automáticamente se comportan mejor aunque los pronósticos
no estén tan alejados.
