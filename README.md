# Trabajo de Fin de Grado, Ingeniería de la salud
![image](https://github.com/rocioalonsolh/tfg-asmr/assets/79716332/ceb1db80-13be-41e6-affe-b1a65ad5e341)


## Respuesta Sensorial Meridiana Autónoma (ASMR): Análisis de la Experiencia Global y Desarrollo de una Aplicación de Recomendación supervisada de ASMR

Este proyecto, realizado por Rocío Alonso las Heras, bajo la supervisión de Antonio Canepa y Estefanía Rivas, alumna de 4º en el Grado en Ingeniería de la Salud, impartido en la Universidad de Burgos, tiene como propósito el estudio del fenómeno conocido como Respuesta Sensorial Meridiana Autónoma (ASMR en adelante), haciendo una revisión del estado del arte de las publicaciones relacionadas. 

Se pretende también realizar una propuesta de uso de este efecto en pacientes con insomnio de conciliación, revisando las carácteristicas principales de esta patología para entender cómo podría ser de utilidad para ella este fenómeno.

Por último, este repositorio va a contener el código, realizado mayormente en lenguaje R, correspondiente a la aplicación desarrollada por la alumna, que corresponde a una aplicación que permita a los usuarios una búsqueda supervisada de videos en la plataforma Youtube, basandose en sus preferencias en ASMR.

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Características](#características)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Tecnologías Utilizadas](#tecnologías-utilizadas)
5. [Agradecimientos](#agradecimientos)

## Introducción
Para poder entender este proyecto es prioritaria la aclaración de 6 puntos clave en torno a los que se ha basado:

### 1. ASMR (Respuesta Sensorial Meridiana Autónoma):

El ASMR es una experiencia sensorial que se caracteriza por una sensación de hormigueo en la piel, generalmente en la cabeza, cuello o espalda, en respuesta a estímulos auditivos o visuales específicos, como susurros suaves, crujidos, o movimientos lentos y delicados.

### 2. Insomnio de Conciliación:

Se refiere a la dificultad para conciliar el sueño al acostarse. Las personas con este tipo de insomnio pueden tener problemas para relajarse y quedarse dormidas, incluso cuando están físicamente cansadas.

### 3. Tratamientos actuales para el Insomnio de Conciliación:

Los tratamientos actuales para este problema pueden incluir terapias cognitivo-conductuales, cambios en el estilo de vida, medicamentos sedantes y enfoques de relajación. Es en el último punto, los enfoques de relajación, donde actualmente toman partido disciplinas como el yoga, la meditación o el mindfulness, donde puede entrar el ASMR como nueva propuesta para estos pacientes.

### 4. Aplicación para ASMR y Insomnio de Conciliación:

Una aplicación podría personalizar recomendaciones de contenido ASMR basándose en los gustos y preferencias del usuario, utilizando algoritmos que analizan patrones de consumo y feedback del usuario. El propósito de este trabajo será confeccionar una versión inicial de esta aplicación, así como estudiar y proponer posibles mejoras para futuras actualizaciones.

### 5. Importancia de YouTube y Creadores de Contenido de ASMR:

YouTube es una plataforma clave en la que millones de creadores producen contenido relativo a muy distintos temas, y en este caso concreto, es una gran plataforma de difusión para el contenido ASMR, con un crecimiento significativo de creadores que producen videos de esta disciplina. La interacción social en YouTube permite a los creadores conectar con sus audiencias y proporcionar experiencias personalizadas.

### 6. Desarrollo de Aplicación en RStudio con Shiny y tuber:

Para el desarrollo de esta aplicación se ha escogido utilizar RStudio con el paquete Shiny permite desarrollar aplicaciones interactivas fácilmente. Con el paquete tuber, se puede conectar la aplicación con YouTube para obtener datos y recomendaciones personalizadas de contenido ASMR. Las ventajas incluyen la flexibilidad de desarrollo y la capacidad de análisis de datos avanzada.


En resumen, una aplicación que utiliza ASMR para ayudar con el insomnio de conciliación podría ofrecer una solución personalizada y atractiva para mejorar la calidad del sueño, aprovechando las plataformas sociales como YouTube y herramientas de desarrollo como RStudio con Shiny y tuber para crear una experiencia única y efectiva.

## Características
Este proyecto se trata de una solución tecnológica para pacientes con insomnio de conciliación, que mediante una aplicación Shiny desarrollada en R, permite a los usuarios un acceso sencillo a vídeos ASMR que pueden ser beneficiosos en el tratamiento de su patología. Se trata de una aplicación web sencilla, diseñada con una base de datos local, que presenta un prototipo de una futura posible aplicación real, diseñada bajo estas pautas.

## Estructura del proyecto
Este proyecto consta de una aplicación Shiny y una base de datos, presentes en la carpeta app. Toda la documentación relativa se encuentra en la carpeta "docs". 

## Tecnologías utilizadas
Las principales herramientas utilizadas han sido
### 1. R
### 2. RStudio
### 3. SQL
### 4. SQLite-DB Browser
### 5. Shiny
### 6. Google Cloud Platform
### 7. Youtube Data API
### 8. Youtube
### 9. Visual Studio Code

## Agradecimientos
Le agradezco su ayuda tanto a Antonio como a Estefanía, por haberme guiado en este proyecto.




