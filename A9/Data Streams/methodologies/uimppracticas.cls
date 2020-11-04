\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{uimppracticas}[2020/10/25 Clase personalizada de Laura Rodríguez Navas para prácticas de la UIMP]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                   Plantilla Prácticas UIMP                               %%%
%%%                Universidad Internacional Menéndez Pelayo                 %%%
%%%                   Laura Rodríguez Navas                                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Biblioteca para los encabezados y pie de página
\RequirePackage{fancyhdr}
%Biblioteca para el lenguaje en español
\RequirePackage[spanish, es-noindentfirst, es-noshorthands, es-tabla]{babel}
%Bilioteca para cambiar márgenes de las páginas
\RequirePackage{geometry}
%Biblioteca para saber cual es la última página
\RequirePackage{lastpage}
%Biblioteca de caracteres aceptados
\RequirePackage[utf8]{inputenc}
%Biblioteca para permitir el uso de diferentes headers y footers
\RequirePackage{etoolbox}
%Bibliotecas de imágenes
\RequirePackage{graphicx}
%Biblioteca para usar diferentes columnas
\RequirePackage{multicol}
%Biblioteca para alinear algunas líneas
\RequirePackage{ragged2e}
%Usar fuentes de tipo vectorial
\RequirePackage[T1]{fontenc}
%Fuente helvética
\RequirePackage[scaled]{helvet}
%Hiperlinks
\RequirePackage{hyperref}
% Mostrar Bibliografía en Índice
\RequirePackage[nottoc]{tocbibind}

%Poner la fuente como predeterminada
\renewcommand\familydefault{\sfdefault}

%Poner un espacio vertical entre párrafos
\setlength{\parskip}{\baselineskip}%
\setlength{\parindent}{0pt}%

%Cambiar márgenes de la página
\geometry{margin=2.5cm}
\setlength\parindent{0pt}

\hypersetup{
    colorlinks=true,
    linkcolor=black,
    filecolor=magenta,      
    urlcolor=cyan,
}


%Comando para insertar la cabecera
%1 -> Tamaño línea separación
%2 -> Cabecera izquierda
%3 -> Cabecera centro
%4 -> Cabecera derecha
\newcommand{\headerpr}[4][0]{
  \renewcommand{\headrulewidth}{#1pt}
  \lhead{#2}
  \chead{#3}
  \rhead{#4}
}

%Comando para insertar la pie de página
%1 -> Tamaño línea separación
%2 -> Pie de página izquierda
%3 -> Pie de página centro
%4 -> Pie de página derecha
\newcommand{\footerpr}[4][0]{
  \renewcommand{\footrulewidth}{#1pt}
  \lfoot{#2}
  \cfoot{#3}
  \rfoot{#4}
}

%Título e imagen centrado
%1 -> Nombre de la imagen
%2 -> Carrera
%3 -> Curso
%4 -> Asignatura
%5 -> Título práctica
\newcommand{\centeredtitle}[5]{
  \begin{center}
    \vspace{10mm}

    \includegraphics[width=80mm]{#1}

    \LARGE #2

    \vspace{5mm}

    \Large #3

    \vspace{25mm}

    \textbf{\LARGE #4}

    \vspace{10mm}

    \textbf{\Huge #5}

    \vspace{40mm}
  \end{center}
  \normalsize
}


%Imágenes centradas
%1 -> Tamaño imagen (Opcional)
%2 -> Path Imagen
\newcommand{\imgcenter}[2][80]{
  \begin{center}
    \includegraphics[width=#1mm]{#2}
  \end{center}
}
