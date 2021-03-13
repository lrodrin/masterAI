import datetime
import math
import sys

import numpy as np
import pandas as pd
import pyqtgraph as pg
from PyQt5 import QtCore
from PyQt5.QtCore import pyqtSignal, QThread, pyqtSlot
from PyQt5.QtGui import QIntValidator, QDoubleValidator, QTextCursor
from PyQt5.QtWidgets import QMainWindow, QComboBox, QDialog, QFileDialog, \
    QMessageBox, QTableWidgetItem, QApplication

import ui_movielens
from movielens_tf_qt import Movielens_Learner, load_and_recode_pj


class Movielens_app(QMainWindow, ui_movielens.Ui_MainWindow):
    # Creamos la señal para invocar un entrenamiento
    comienza_entrenamiento = pyqtSignal(pd.DataFrame, pd.DataFrame)

    def __init__(self, parent=None):
        super().__init__(parent)

        # background / foreground in PlotWidgets
        pg.setConfigOption('background', 'w')
        pg.setConfigOption('foreground', 'k')
        self.setupUi(self)

        self.pconsola('CONSOLA (%s)\n' % datetime.datetime.now().strftime('%d/%m/%Y %H:%M'))

        self.peliculas = []  # aquí guardaré los nombres de las películas
        self.peliculas_emb = None
        self.usuarios_emb = None

        # Para ir almacenando los datos que van a ser dibujados
        self.global_step_list = []  # global step (iteración)
        self.avg_error_list = []  # error medio de entrenamiento (rescritura)
        self.avg_error_test_list = []  # error medio de entrenamiento (rescritura)
        self.avg_error_iu_list = []  # error medio de entrenamiento sólo para las preferencias de usuario

        # Los conjuntos de entrenamiento y test van "atornillados" en el código, deben ser
        # pj_train.csv y pj_test.csv respectivamente
        self._train_pj, self._new_ucodes, self._new_mcodes = load_and_recode_pj('pj_train.csv')
        self.num_users = len(self._new_ucodes)
        self.num_movies = len(self._new_mcodes)

        # validators TODO: no se usan bien, habría que comprobar cosas...
        self.le_K.setValidator(QIntValidator(2, 1000))
        self.le_minibatch.setValidator(QIntValidator(1, len(self._train_pj) // 10))
        learningrate_validator = QDoubleValidator(1e-6, 1.0, 10)
        learningrate_validator.setNotation(QDoubleValidator.ScientificNotation)
        self.le_learningrate.setValidator(learningrate_validator)
        nu_validator = QDoubleValidator(0, 1.0, 10)
        nu_validator.setNotation(QDoubleValidator.ScientificNotation)
        self.le_nu.setValidator(nu_validator)
        self.le_epochs.setValidator(QIntValidator(1, 100))
        self.le_drawevery.setValidator(QIntValidator(1, 10))

        # construimos la tabla de películas para que el usuario pueda puntuar
        self.tableWidget.setColumnCount(3)
        self.tableWidget.setRowCount(self.num_movies)
        anchura = self.tableWidget.width() - 30  # números de película
        w1 = round(anchura * 0.15)
        w2 = round(anchura * 0.65)
        w3 = anchura - (w1 + w2)
        self.tableWidget.setColumnWidth(0, w1)
        self.tableWidget.setColumnWidth(1, w2)
        self.tableWidget.setColumnWidth(2, w3)

        self.cargar_peliculas()

        # self.cargar_puntuaciones()

        # Los ejemplos de test se recodifican utilizando la codificación obtenida sobre los de entrenamiento, por
        # lo que es necesario que en el conjunto de entrenamiento aparezcan todos los usuarios y todas las películas
        # alguna vez, pero eso NO QUIERE DECIR que haya ejemplos de test en el conjunto de entrenamiento
        self._test_pj, _, _ = load_and_recode_pj('pj_test.csv', self._new_ucodes, self._new_mcodes)
        # Aquí va el sistema de aprendizaje
        self._learner = Movielens_Learner(num_users=self.num_users + 1, num_movies=self.num_movies, drawevery=1)
        self.__hiperparametros_al_gui()
        self._hay_usuario_interactivo = False
        # print(self._learner.get_params(deep=False))

        # Creamos el hilo donde se va a ejecutar el entrenamiento
        self.hilo_entrenamiento = QThread()
        self._learner.moveToThread(self.hilo_entrenamiento)
        self.hilo_entrenamiento.start()

        # Conectar signals/slots
        self.__conectarWidgets()

    @pyqtSlot(str, name='pconsola')
    def pconsola(self, text):
        cursor = self.consola.textCursor()
        cursor.movePosition(QTextCursor.End)
        cursor.insertText(text)
        # cursor.movePosition(QTextCursor.End)
        self.consola.ensureCursorVisible()

    def __hiperparametros_al_gui(self):
        self.le_K.setText(str(self._learner.K))
        self.le_learningrate.setText(str(self._learner.learning_rate))
        self.le_minibatch.setText(str(self._learner.batch_size))
        self.le_epochs.setText(str(self._learner.num_epochs))
        self.le_nu.setText(str(self._learner.nu))
        self.le_drawevery.setText(str(self._learner.drawevery))
        self.cb_semillaaleatoria.setChecked(self._learner.random_seed)

    def __conectarWidgets(self):
        # conectamos menu
        self.actionCargar_puntuaciones.triggered.connect(self.cargar_puntuaciones)
        self.actionGuardar_puntuaciones.triggered.connect(self.guardar_puntuaciones)
        self.actionCargar_modelo_entrenado.triggered.connect(self.cargar_modelo)
        self.actionGuardar_modelo_entrenado.triggered.connect(self.guardar_modelo)
        self.actionExportar.triggered.connect(self.exportar)

        # conectamos botones
        self.pb_Borrarpuntos.clicked.connect(self.borrar_puntuaciones)
        self.pb_Olvidar.clicked.connect(self.olvidar)

        # conectamos señales para entrenamiento
        self.pb_Aprender.clicked.connect(self.entrenar)
        self._learner.mensaje.connect(self.pconsola)
        self.pb_Parar.clicked.connect(self.parar_entrenamiento)
        self.comienza_entrenamiento.connect(self._learner.fit)
        self.comienza_entrenamiento.connect(self.deshabilitar_widgets_para_entrenar)
        self._learner.progreso.connect(self.progressBar.setValue)
        self._learner.entrenamiento_finalizado.connect(self.habilitar_widgets_para_entrenar)
        # self._learner.entrenamiento_finalizado.connect(self._learner.predict_iu)
        self._learner.entrenamiento_finalizado.connect(self.predecir_para_usuario)
        self._learner.computed_avg_loss.connect(self.dibujar_errores)
        self._learner.computed_embeddings.connect(self.dibujar_peliculas)
        self.cb_X.currentTextChanged.connect(self.redibujar_peliculas)
        self.cb_Y.currentTextChanged.connect(self.redibujar_peliculas)

        self._learner.grafo_construido.connect(self.deshabilitar_cambio_hparams)
        self._learner.grafo_eliminado.connect(self.habilitar_cambio_hparams)

    def mostrar_predicciones(self, predicciones):
        # las predicciones están en la columna 'predicted_score'
        for fila, valor in zip(list(range(len(predicciones))), predicciones.predicted_score):
            item = QTableWidgetItem(str(round(valor, 6)))
            item.setFlags(QtCore.Qt.ItemIsEnabled)
            self.tableWidget.setItem(fila, 2, item)

    @pyqtSlot(name='cargar_modelo')
    def cargar_modelo(self):
        # Escoger el directorio del que cargar el modelo
        fd = QFileDialog(self, 'Directorio donde está el modelo', '.', '*.csv')
        fd.setAcceptMode(QFileDialog.AcceptOpen)
        fd.setFileMode(QFileDialog.DirectoryOnly)
        if fd.exec_() == QDialog.Accepted:
            path = fd.selectedFiles()[0]
            try:
                self._learner.restore_on_created_object(path + '/model.ckpt')
                self.__hiperparametros_al_gui()
            except:
                QMessageBox.warning(self, 'Carga de modelo', 'No ha sido posible la carga del modelo')

    @pyqtSlot(name='guardar_modelo')
    def guardar_modelo(self):
        # Escoger directorio donde guardar el modelo
        fd = QFileDialog(self, 'Directorio donde está el modelo', '.', '*.csv')
        fd.setAcceptMode(QFileDialog.AcceptOpen)
        fd.setFileMode(QFileDialog.DirectoryOnly)
        if fd.exec_() == QDialog.Accepted:
            path = fd.selectedFiles()[0]

            try:
                self._learner.save(path)
            except:
                QMessageBox.warning(self, 'Guardado de modelo', 'No ha sido posible guardar el modelo')

    @pyqtSlot(name='recoger_hiperparametros')
    def recoger_hiperparametros(self):
        """
        Recoger y validar los campos de entrada de los hiperparámetros
        :return: nada
        """
        lista_hiperparams = ['K', 'nu', 'learning_rate', 'batch_size', 'num_epochs', 'drawevery', 'random_seed']
        param_actuales = self._learner.get_params(deep=False)
        param_nuevos = {}
        param_del_ui = {'K': int(self.le_K.text()), 'num_epochs': int(self.le_epochs.text()),
                        'learning_rate': float(self.le_learningrate.text()),
                        'batch_size': int(self.le_minibatch.text()), 'nu': float(self.le_nu.text()),
                        'drawevery': int(self.le_drawevery.text()), 'random_seed': self.cb_semillaaleatoria.isChecked()}

        # print('Params. actuales:', param_actuales)

        for param_nombre in lista_hiperparams:
            # line_edit = param_del_ui[param_nombre][0]
            valor = param_del_ui[param_nombre]
            # Cambiamos el valor del parámetro por el nuevo valor, que es aceptable, si es diferente
            if param_actuales[param_nombre] != valor:
                param_nuevos[param_nombre] = valor

        if len(param_nuevos) > 0:
            self._learner.set_params(**param_nuevos)

    @pyqtSlot(name='redibujar_peliculas')
    def redibujar_peliculas(self):
        texto_cb_X = self.cb_X.currentText()
        texto_cb_Y = self.cb_Y.currentText()
        if texto_cb_X != '' and texto_cb_Y != '' and self.peliculas_emb is not None:
            # Hay que leer las variables (columnas de peliculas_emb) elegidas en los combos de los ejes
            eje_x = int(texto_cb_X) - 1
            eje_y = int(texto_cb_Y) - 1
            peliculas_emb_x = self.peliculas_emb[eje_x, :]
            peliculas_emb_y = self.peliculas_emb[eje_y, :]
            # p = pg.mkPen('k', width=2)

            pdi = self.graphicsView_pelis.plot({'x': peliculas_emb_x,
                                                'y': peliculas_emb_y},
                                               pen=None, symbol='o', symbolPen='b', symbolBrush='w', clear=True)

            pdi.sigPointsClicked.connect(self.mostrar_titulos_en_consola)

            # Etiquetar las de los extremos (izquierda, derecha, arriba y abajo)
            # izquierda
            max_length = 40
            min_x = peliculas_emb_x.min()
            index_min_x = peliculas_emb_x.argmin()
            titulo = self.peliculas[index_min_x]
            titulo = titulo[:max_length]
            etiqueta = pg.TextItem(text=titulo, color='k')
            etiqueta.setPos(min_x, peliculas_emb_y[index_min_x])
            self.graphicsView_pelis.addItem(etiqueta)
            # derecha
            max_x = peliculas_emb_x.max()
            index_max_x = peliculas_emb_x.argmax()
            titulo = self.peliculas[index_max_x]
            titulo = titulo[:max_length]
            etiqueta = pg.TextItem(text=titulo, color='k')
            etiqueta.setPos(max_x, peliculas_emb_y[index_max_x])
            self.graphicsView_pelis.addItem(etiqueta)
            # abajo
            min_y = peliculas_emb_y.min()
            index_min_y = peliculas_emb_y.argmin()
            titulo = self.peliculas[index_min_y]
            titulo = titulo[:max_length]
            etiqueta = pg.TextItem(text=titulo, color='k')
            etiqueta.setPos(peliculas_emb_x[index_min_y], min_y)
            self.graphicsView_pelis.addItem(etiqueta)
            # arriba
            max_y = peliculas_emb_y.max()
            index_max_y = peliculas_emb_y.argmax()
            titulo = self.peliculas[index_max_y]
            titulo = titulo[:max_length]
            etiqueta = pg.TextItem(text=titulo, color='k')
            etiqueta.setPos(peliculas_emb_x[index_max_y], max_y)
            self.graphicsView_pelis.addItem(etiqueta)

            if self._hay_usuario_interactivo:
                if self._learner.K == 2:
                    usuario_x = self.usuarios_emb[eje_x]
                    usuario_y = self.usuarios_emb[eje_y]

                    self.graphicsView_pelis.plot({'x': [usuario_x],
                                                  'y': [usuario_y]},
                                                 pen=None,
                                                 symbol='x', symbolPen='r',
                                                 clear=False)

                    # y dibujamos una linea entre el usuario y el (0, 0)
                    self.graphicsView_pelis.plot({'x': [usuario_x, 0],
                                                  'y': [usuario_y, 0]},
                                                 pen='r',
                                                 symbol=None,
                                                 clear=False)

                    angulo = math.degrees(math.atan(usuario_y / usuario_x))
                    # print(usuario_x, usuario_y, angulo)
                    l = pg.InfiniteLine(angle=90 + angulo, pos=(0, 0), pen=pg.mkPen(color='r', width=4))
                    self.graphicsView_pelis.addItem(l)

    @pyqtSlot(np.ndarray, np.ndarray, name='dibujar_peliculas')
    def dibujar_peliculas(self, usuarios_emb, peliculas_emb):
        self.peliculas_emb = peliculas_emb
        self.usuarios_emb = usuarios_emb
        self.redibujar_peliculas()

    # @pyqtSlot(QtCore.QObject, QtCore.QObject, name='dialgoconio')
    def mostrar_titulos_en_consola(self, pdi, l):
        # print('Lista de longitud', len(l))
        lista_de_puntos = []
        for obj in l:
            obj_x = obj.pos().x()
            obj_y = obj.pos().y()
            lista_de_puntos.append((obj_x, obj_y))
        todas_las_x = pdi.getData()[0]
        todas_las_y = pdi.getData()[1]
        for i in range(len(todas_las_x)):
            if (todas_las_x[i], todas_las_y[i]) in lista_de_puntos:
                self.pconsola('--> %s\n' % self.peliculas[i])
        self.pconsola('\n')

    @pyqtSlot(int, float, float, float, name='dibujar_errores')
    def dibujar_errores(self, gs, avg_error, error_test, error_iu):
        pen_train = pg.mkPen('k', width=2)
        pen_test = pg.mkPen('r', width=2)
        pen_user = pg.mkPen('b', width=2)
        # Lista de coordenadas X
        self.global_step_list.append(gs)
        # Lista de coordenadas Y del error de entrenamiento
        self.avg_error_list.append(avg_error)
        self.graphicsView_errores.plot(self.global_step_list, self.avg_error_list, pen=pen_train,
                                       name='Error reescritura', clear=True)
        # Lista de coordenadas Y del error de test
        self.avg_error_test_list.append(error_test)
        self.graphicsView_errores.plot(self.global_step_list, self.avg_error_test_list, pen=pen_test,
                                       name='Error en test', clear=False)
        # Lista de coordenadas Y del error de usuario (puede ser nan, pero hay que guardarlo igual)
        self.avg_error_iu_list.append(error_iu)
        if not np.isnan(error_iu):
            self.graphicsView_errores.plot(self.global_step_list, self.avg_error_iu_list, pen=pen_user,
                                           name='Error usuario', clear=False)
        # print('He recibido datos:', gs, avg_error)

    def cargar_peliculas(self):
        movies = pd.read_csv('movies.csv')
        self.peliculas = movies.Title
        for fila, pelicula in zip(range(len(movies.Title)), movies.Title):
            # Columna de puntuaciones (espacio vacío de momento)
            _PUNTUACIONES = ['']
            _PUNTUACIONES.extend([str(i) for i in range(1, 11)])
            item = QComboBox()
            for i in _PUNTUACIONES:
                item.addItem(str(i))
            self.tableWidget.setCellWidget(fila, 0, item)
            # Columna de nombres de películas
            item = QTableWidgetItem(pelicula)
            item.setFlags(QtCore.Qt.ItemIsEnabled)  # pero no editable
            self.tableWidget.setItem(fila, 1, item)
            # Columna de valoraciones (para cuando el modelo esté entrenado)
            item = QTableWidgetItem('--')
            item.setFlags(QtCore.Qt.ItemIsEnabled)
            self.tableWidget.setItem(fila, 2, item)

    # def mas_datos(self):
    #     filas = self.tableWidget.rowCount()
    #     self.tableWidget.setRowCount(filas+1)
    #     a_new_number = random()*50
    #     self.tableWidget.setItem(filas, 0, QTableWidgetItem(str(a_new_number)))
    #     self.data.append(a_new_number)
    #     self.graphicsView_pelis.plot(self.data, pen='k')
    @pyqtSlot(name='cargar_puntuaciones')
    def cargar_puntuaciones(self):
        # Leer datos de las valoraciones de las películas
        # formato:
        #   movie, score
        idButton = QMessageBox.question(self, 'Carga de puntuaciones',
                                        'Es posible que se reescriban puntuaciones.\n\n¿Quieres continuar?')
        if idButton == QMessageBox.Yes:
            fd = QFileDialog(self, 'Fichero de puntuaciones', '.', '*.csv')
            fd.setAcceptMode(QFileDialog.AcceptOpen)
            if fd.exec_() == QDialog.Accepted:
                fichero = fd.selectedFiles()[0]
                try:
                    puntuaciones = pd.read_csv(fichero)
                    for i in range(len(puntuaciones)):
                        pelicula = puntuaciones.iloc[i].movie
                        puntos = puntuaciones.iloc[i].score
                        # print(pelicula, puntos)
                        # it = self.tableWidget.item(pelicula, 0)
                        # it.setText(str(puntos))
                        it = self.tableWidget.cellWidget(pelicula, 0)
                        it.setCurrentText(str(puntos))
                    # QMessageBox.information(self, 'Carga de puntuaciones', 'Puntuaciones cargadas')
                except:
                    QMessageBox.warning(self, 'Carga de puntuaciones', 'No ha sido posible la carga')

    @pyqtSlot(name='exportar')
    def exportar(self):
        """
        Exporta la representación de los usuarios y películas a formato csv
        :return: Nada
        """
        usuarios, peliculas = self._learner.getEmbeddings()
        if usuarios is not None:
            # Convierto las matrices en DataFrames
            usuarios_df = pd.DataFrame(usuarios, columns=['U' + str(i) for i in range(1, 1 + usuarios.shape[1])])
            peliculas_df = pd.DataFrame(peliculas, columns=['M' + str(i) for i in range(1, 1 + peliculas.shape[1])])

            # Escoger directorio donde guardar el modelo
            fd = QFileDialog(self, 'Directorio para almacenar los usuarios y películas', '.', '')
            fd.setAcceptMode(QFileDialog.AcceptOpen)
            fd.setFileMode(QFileDialog.DirectoryOnly)
            if fd.exec_() == QDialog.Accepted:
                path = fd.selectedFiles()[0]

                try:
                    usuarios_fn = path + '/usuarios.csv'
                    peliculas_fn = path + '/peliculas.csv'
                    usuarios_df.to_csv(usuarios_fn, sep=';', decimal=',')
                    peliculas_df.to_csv(peliculas_fn, sep=';', decimal=',')
                except:
                    QMessageBox.warning(self, 'Exportar modelo',
                                        'No ha sido posible exportar los usuarios y pelíuculas')
        else:
            QMessageBox.warning(self, 'Exportar modelo', 'No hay representación que exportar!!')

    @pyqtSlot(name='guardar_puntuaciones')
    def guardar_puntuaciones(self):
        # Toma los datos de las valoraciones de las películas de la tabla y los guarda en un CSV
        # con el formato:
        #   movie, score
        puntuaciones = []
        peliculas = []
        filas = self.tableWidget.rowCount()
        for f in range(filas):
            texto = self.tableWidget.cellWidget(f, 0).currentText()
            if len(texto) > 0:
                score = int(texto)
                puntuaciones.append(score)
                peliculas.append(f)

        if len(puntuaciones) > 0:
            datos = pd.DataFrame(columns=['movie', 'score'])
            datos.movie = peliculas
            datos.score = puntuaciones
            # print(datos)
            fd = QFileDialog(self, 'Fichero de puntuaciones', '.', '*.csv')
            fd.setAcceptMode(QFileDialog.AcceptSave)
            if fd.exec_() == QDialog.Accepted:
                fichero = fd.selectedFiles()[0]
                try:
                    datos.to_csv(fichero, index=False)
                except:
                    QMessageBox.warning(self, 'Guardar puntuaciones', 'No se han podido guardar las puntuaciones')
        else:
            QMessageBox.warning(self, 'Guardar puntuaciones', 'No hay puntuaciones que guardar')

    @pyqtSlot(name='borrar_puntuaciones')
    def borrar_puntuaciones(self):
        idButton = QMessageBox.question(self, 'Borrar puntuaciones', '¿Quieres eliminar las puntuaciones?')
        if idButton == QMessageBox.Yes:
            filas = self.tableWidget.rowCount()
            for f in range(filas):
                # it = self.tableWidget.item(f, 0)
                # it.setText('')
                it = self.tableWidget.cellWidget(f, 0)
                it.setCurrentText('')

    def _crea_pjs_de_usuario(self):
        """
        Recupera las valoraciones introducidas por el usuario en la aplicación y crea
        un DataFrame con los juicios de preferencias que se derivan de esas puntuaciones.

        :return: DataFrame con las columnas *user*, *bset*, *worst*, preparado para ser concatenado
        a los juicios de preferencias del resto de usuarios y formar parte del conjunto de
        entrenamiento
        """
        # Leer las puntuaciones de la aplicación
        filas = self.tableWidget.rowCount()
        # columnas = self.tableWidget.columnCount()

        valoraciones = []  # formato [(pelicula, valoración), ... ]
        for f in range(filas):
            texto = self.tableWidget.cellWidget(f, 0).currentText()
            if len(texto) > 0:
                valor = int(texto)
                valoraciones.append((f, valor))

        # Y convertirlos en juicios de preferencias, con el mismo formato del conjunto de entrenamiento
        #    usuario, mejor película, peor película
        # donde el código de usuario será el último disponible, es decir, será self.num_users
        mejores = []
        peores = []
        for i in range(len(valoraciones) - 1):
            for j in range(i + 1, len(valoraciones)):
                pelicula_i = valoraciones[i][0]
                valor_i = valoraciones[i][1]
                pelicula_j = valoraciones[j][0]
                valor_j = valoraciones[j][1]
                if valor_i > valor_j:
                    mejores.append(pelicula_i)
                    peores.append(pelicula_j)
                elif valor_i < valor_j:
                    mejores.append(pelicula_j)
                    peores.append(pelicula_i)

        puntuaciones = pd.DataFrame(columns=['user', 'best_movie', 'worst_movie'])
        puntuaciones.best_movie = mejores
        puntuaciones.worst_movie = peores
        puntuaciones.user = [self.num_users] * len(mejores)
        return puntuaciones

    @pyqtSlot(name='habilitar_cambio_hparams')
    def habilitar_cambio_hparams(self):
        self.le_K.setEnabled(True)
        # self.le_nu.setEnabled(True)
        # self.le_learningrate.setEnabled(True)
        self.cb_semillaaleatoria.setEnabled(True)

    @pyqtSlot(name='deshabilitar_cambio_hparams')
    def deshabilitar_cambio_hparams(self):
        self.le_K.setEnabled(False)
        # self.le_nu.setEnabled(False)
        # self.le_learningrate.setEnabled(False)
        self.cb_semillaaleatoria.setEnabled(False)

    @pyqtSlot(name='habilitar_widgets_para_entrenar')
    def habilitar_widgets_para_entrenar(self):
        self.widgets_habilitados(True)

    @pyqtSlot(name='deshabilitar_widgets_para_entrenar')
    def deshabilitar_widgets_para_entrenar(self):
        self.widgets_habilitados(False)
        self.progressBar.setRange(0, 100)  # Va a ir en porcentaje
        self.progressBar.reset()

    def widgets_habilitados(self, estado=True):
        # Hay widgets que tras el primer entrenamiento deben quedar deshabilitados hasta que se cree un nuevo modelo:
        # self.le_nu, self.le_learningrate, self.le_K, self.cb_semillaaleatoria, van aparte
        lista_widgets = [self.le_epochs, self.le_minibatch, self.le_drawevery,
                         self.le_learningrate, self.le_nu,
                         self.pb_Olvidar, self.pb_Borrarpuntos, self.pb_Aprender,
                         self.menuBar, self.tableWidget]

        for w in lista_widgets:
            w.setEnabled(estado)

        self.pb_Parar.setEnabled(not estado)  # Este botón va al revés que todos lo demás
        self.repaint()  # teóricamente, esto no debería ser necesario, pero a veces la ventana no refresca bien...

    def _predicciones_para_usuario(self, ):
        if self._hay_usuario_interactivo:
            # Creamos el dataframe para hacer la predicción para el usuario interactivo (el último) con todas las peliculas
            for_prediction = pd.DataFrame(columns=['user', 'movie'])
            for_prediction.movie = list(range(self.num_movies))
            # En este objeto, self.num_users contiene el número de usuario SIN tener en cuenta el usuario interactivo
            # así que éste tendrá por código self.num_users, ya que los cargados desde el conjunto de entrenamiento
            # se recodifican (si es necesario) y toman los valores de 0 a self.num_users - 1
            for_prediction.user = [self.num_users] * self.num_movies
            predicted_scores = self._learner.predict(for_prediction)
        else:
            predicted_scores = None
        return predicted_scores

    @pyqtSlot(name='predecir_para_usuario')
    def predecir_para_usuario(self):
        results = self._predicciones_para_usuario()
        if results is not None:
            # Mostramos las predicciones en la tabla de películas
            self.mostrar_predicciones(results)
            # Y mostramos las top/bottom 'n' películas en orden
            results.sort_values(ascending=False, inplace=True, by='predicted_score')
            top_n = 10
            self.pconsola('TOP {:d} películas\n'.format(top_n))
            plantilla = '{:3d}) {:s} -- [{:f}]\n'
            for i in range(top_n):
                pelicula = self.peliculas[results.movie.iloc[i]]
                score = results.predicted_score.iloc[i]
                self.pconsola(plantilla.format(i + 1, pelicula, score))
            self.pconsola('\nBOTTOM {:d} películas\n'.format(top_n))
            for i in range(top_n):
                pelicula = self.peliculas[results.movie.iloc[-(i + 1)]]
                score = results.predicted_score.iloc[-(i + 1)]
                self.pconsola(plantilla.format(self.num_movies - i, pelicula, score))

            # Y ahora mostramos una lista de 'n' películas NO VISTAS que recomendamos al usuario
            # Para ello, creamos una lista de películas puntuadas y luego recorremos la lista de predicciones
            # saltando aquellas que han sido puntuadas, hasta llegar a 'n' recomendaciones
            filas = self.tableWidget.rowCount()

            pelis_valoradas = []  # Lista de índices de películas valoradas por el usuario
            for f in range(filas):
                texto = self.tableWidget.cellWidget(f, 0).currentText()
                if len(texto) > 0:
                    pelis_valoradas.append(f)

            self.pconsola('\nRECOMENDACIONES: {:d} películas\n'.format(top_n))
            i = 0
            recomendadas = 0
            while recomendadas < top_n and i < len(results.movie):
                indice = results.movie.iloc[i]
                if indice not in pelis_valoradas:
                    pelicula = self.peliculas[indice]
                    score = results.predicted_score.iloc[i]
                    self.pconsola(plantilla.format(recomendadas + 1, pelicula, score))
                    recomendadas += 1
                i += 1

    @pyqtSlot(name='entrenar')
    def entrenar(self):
        # Leemos todos los hiperparámetros, los asignamos al recomendador
        self.recoger_hiperparametros()

        # Rellenar los combos si están vacíos (primer entrenamiento) para dibujar los embeddings de las películas
        if self.cb_X.currentText() == '':
            for i in range(self._learner.K):
                self.cb_X.addItem(str(i + 1))
                self.cb_Y.addItem(str(i + 1))
            self.cb_X.setCurrentText(self.cb_X.itemText(0))
            self.cb_Y.setCurrentText(self.cb_X.itemText(1))

        # Construir el PlotDataItem para dibujar las películas, y las etiquetas necesarias
        # construir_pdi_peliculas()

        # Si hay valoraciones del usuario interactivo, hay que crear los juicios de preferencias de dicho
        # usuario y añadirlos al conjunto de entrenamiento
        # Datos del usuario interactivo, si los hay
        train_pj_interactive = self._crea_pjs_de_usuario()
        # print(train_pj_interactive)
        if len(train_pj_interactive) > 0:
            self._hay_usuario_interactivo = True
            # Se concatenan sus preferencias al conjunto de entrenamiento
            train_data = pd.concat([self._train_pj, train_pj_interactive])
            train_data = train_data.reset_index(drop=True)
            # train_data.to_csv('pa_entrenar.csv', index=False)
        else:
            self._hay_usuario_interactivo = False
            train_data = self._train_pj  # no hay datos de usuario interactivo

        test_data = self._test_pj

        # ... y emitimos la señal de entrenamiento
        # El segundo parámetro es para que evalúe el error en test que se va produciendo mientras se entrena
        # se hace con propósitos méramente académicos, un sistema real no lo haría
        self.comienza_entrenamiento.emit(train_data, test_data)

    @pyqtSlot(name='parar_entrenamiento')
    def parar_entrenamiento(self):
        self.pconsola('--- Interrupción de entrenamiento solicitada ---\n')
        self._learner.stop_fit()

    # def test(self):
    #     self._learner.predict(self._test_pj)

    def olvidar(self):
        idButton = QMessageBox.question(self, 'Olvidar Modelo',
                                        'Se va a reiniciar todo el proceso de aprendizaje\n\n¿Deseas continuar?')
        if idButton == QMessageBox.Yes:
            self.graphicsView_pelis.clear()
            self.graphicsView_errores.clear()
            self.consola.clear()
            self.cb_X.clear()
            self.cb_Y.clear()
            self._learner.reset_graph()  # reset_model()
            # ... y borramos la columna de valoraciones, ya que no hay modelo
            self.borrar_valoraciones()
            # ... borramos los datos producidos durante el entde error de entrenamiento
            self.global_step_list = []
            self.avg_error_list = []
            self.avg_error_test_list = []
            self.avg_error_iu_list = []
            self.peliculas_emb = None
            self.usuarios_emb = None

            # No hace falta borrar gráficos y consola de mensajes y combos de pintar películas, ya lo
            # hacemos conectando la señal emitida del botón a los .clear correspondientes

            QMessageBox.information(self, 'Borrar modelo', 'MODELO BORRADO!!\n\nHay que reentrenar el sistema...')

    def borrar_valoraciones(self):
        filas = self.tableWidget.rowCount()
        for i in range(filas):
            it = self.tableWidget.item(i, 2)
            it.setText('-x-')


if __name__ == '__main__':
    app = QApplication(sys.argv)
    form = Movielens_app()
    form.show()
    app.exec_()
