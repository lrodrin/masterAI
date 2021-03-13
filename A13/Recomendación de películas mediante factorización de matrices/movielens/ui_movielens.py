# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'movielens.ui'
#
# Created by: PyQt5 UI code generator 5.10.1
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets
from pyqtgraph import PlotWidget


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1210, 784)
        MainWindow.setMinimumSize(QtCore.QSize(1210, 784))
        MainWindow.setMaximumSize(QtCore.QSize(1210, 784))
        MainWindow.setToolTip("")
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.graphicsView_pelis = PlotWidget(self.centralwidget)
        self.graphicsView_pelis.setGeometry(QtCore.QRect(160, 10, 491, 391))
        self.graphicsView_pelis.setObjectName("graphicsView_pelis")
        self.graphicsView_errores = PlotWidget(self.centralwidget)
        self.graphicsView_errores.setGeometry(QtCore.QRect(160, 440, 491, 311))
        self.graphicsView_errores.setToolTip("")
        self.graphicsView_errores.setObjectName("graphicsView_errores")
        self.tableWidget = QtWidgets.QTableWidget(self.centralwidget)
        self.tableWidget.setGeometry(QtCore.QRect(660, 420, 542, 331))
        self.tableWidget.setMaximumSize(QtCore.QSize(16777215, 751))
        self.tableWidget.setObjectName("tableWidget")
        self.tableWidget.setColumnCount(3)
        self.tableWidget.setRowCount(0)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(0, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(1, item)
        item = QtWidgets.QTableWidgetItem()
        self.tableWidget.setHorizontalHeaderItem(2, item)
        self.consola = QtWidgets.QPlainTextEdit(self.centralwidget)
        self.consola.setGeometry(QtCore.QRect(660, 10, 541, 391))
        self.consola.setReadOnly(True)
        self.consola.setObjectName("consola")
        self.cb_Y = QtWidgets.QComboBox(self.centralwidget)
        self.cb_Y.setGeometry(QtCore.QRect(50, 200, 104, 26))
        self.cb_Y.setObjectName("cb_Y")
        self.cb_X = QtWidgets.QComboBox(self.centralwidget)
        self.cb_X.setGeometry(QtCore.QRect(340, 410, 104, 26))
        self.cb_X.setObjectName("cb_X")
        self.line = QtWidgets.QFrame(self.centralwidget)
        self.line.setGeometry(QtCore.QRect(10, 410, 141, 31))
        self.line.setFrameShape(QtWidgets.QFrame.HLine)
        self.line.setFrameShadow(QtWidgets.QFrame.Sunken)
        self.line.setObjectName("line")
        self.formLayoutWidget_3 = QtWidgets.QWidget(self.centralwidget)
        self.formLayoutWidget_3.setGeometry(QtCore.QRect(10, 440, 141, 85))
        self.formLayoutWidget_3.setObjectName("formLayoutWidget_3")
        self.layout_variables = QtWidgets.QFormLayout(self.formLayoutWidget_3)
        self.layout_variables.setContentsMargins(0, 0, 0, 0)
        self.layout_variables.setObjectName("layout_variables")
        self.label_4 = QtWidgets.QLabel(self.formLayoutWidget_3)
        self.label_4.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignTrailing | QtCore.Qt.AlignVCenter)
        self.label_4.setObjectName("label_4")
        self.layout_variables.setWidget(0, QtWidgets.QFormLayout.LabelRole, self.label_4)
        self.le_epochs = QtWidgets.QLineEdit(self.formLayoutWidget_3)
        self.le_epochs.setText("")
        self.le_epochs.setObjectName("le_epochs")
        self.layout_variables.setWidget(0, QtWidgets.QFormLayout.FieldRole, self.le_epochs)
        self.le_minibatch = QtWidgets.QLineEdit(self.formLayoutWidget_3)
        self.le_minibatch.setText("")
        self.le_minibatch.setObjectName("le_minibatch")
        self.layout_variables.setWidget(1, QtWidgets.QFormLayout.FieldRole, self.le_minibatch)
        self.label_6 = QtWidgets.QLabel(self.formLayoutWidget_3)
        self.label_6.setObjectName("label_6")
        self.layout_variables.setWidget(2, QtWidgets.QFormLayout.LabelRole, self.label_6)
        self.le_drawevery = QtWidgets.QLineEdit(self.formLayoutWidget_3)
        self.le_drawevery.setObjectName("le_drawevery")
        self.layout_variables.setWidget(2, QtWidgets.QFormLayout.FieldRole, self.le_drawevery)
        self.label_5 = QtWidgets.QLabel(self.formLayoutWidget_3)
        self.label_5.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignTrailing | QtCore.Qt.AlignVCenter)
        self.label_5.setObjectName("label_5")
        self.layout_variables.setWidget(1, QtWidgets.QFormLayout.LabelRole, self.label_5)
        self.verticalLayoutWidget = QtWidgets.QWidget(self.centralwidget)
        self.verticalLayoutWidget.setGeometry(QtCore.QRect(10, 290, 151, 112))
        self.verticalLayoutWidget.setObjectName("verticalLayoutWidget")
        self.layout_fijos = QtWidgets.QVBoxLayout(self.verticalLayoutWidget)
        self.layout_fijos.setContentsMargins(0, 0, 0, 0)
        self.layout_fijos.setObjectName("layout_fijos")
        self.cb_semillaaleatoria = QtWidgets.QCheckBox(self.verticalLayoutWidget)
        self.cb_semillaaleatoria.setChecked(True)
        self.cb_semillaaleatoria.setObjectName("cb_semillaaleatoria")
        self.layout_fijos.addWidget(self.cb_semillaaleatoria)
        self.fl_fijos_texto = QtWidgets.QFormLayout()
        self.fl_fijos_texto.setObjectName("fl_fijos_texto")
        self.label = QtWidgets.QLabel(self.verticalLayoutWidget)
        self.label.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignTrailing | QtCore.Qt.AlignVCenter)
        self.label.setObjectName("label")
        self.fl_fijos_texto.setWidget(0, QtWidgets.QFormLayout.LabelRole, self.label)
        self.le_K = QtWidgets.QLineEdit(self.verticalLayoutWidget)
        self.le_K.setToolTipDuration(5)
        self.le_K.setText("")
        self.le_K.setObjectName("le_K")
        self.fl_fijos_texto.setWidget(0, QtWidgets.QFormLayout.FieldRole, self.le_K)
        self.label_2 = QtWidgets.QLabel(self.verticalLayoutWidget)
        self.label_2.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignTrailing | QtCore.Qt.AlignVCenter)
        self.label_2.setObjectName("label_2")
        self.fl_fijos_texto.setWidget(1, QtWidgets.QFormLayout.LabelRole, self.label_2)
        self.le_learningrate = QtWidgets.QLineEdit(self.verticalLayoutWidget)
        self.le_learningrate.setText("")
        self.le_learningrate.setObjectName("le_learningrate")
        self.fl_fijos_texto.setWidget(1, QtWidgets.QFormLayout.FieldRole, self.le_learningrate)
        self.label_3 = QtWidgets.QLabel(self.verticalLayoutWidget)
        self.label_3.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignTrailing | QtCore.Qt.AlignVCenter)
        self.label_3.setObjectName("label_3")
        self.fl_fijos_texto.setWidget(2, QtWidgets.QFormLayout.LabelRole, self.label_3)
        self.le_nu = QtWidgets.QLineEdit(self.verticalLayoutWidget)
        self.le_nu.setText("")
        self.le_nu.setObjectName("le_nu")
        self.fl_fijos_texto.setWidget(2, QtWidgets.QFormLayout.FieldRole, self.le_nu)
        self.layout_fijos.addLayout(self.fl_fijos_texto)
        self.verticalLayoutWidget_2 = QtWidgets.QWidget(self.centralwidget)
        self.verticalLayoutWidget_2.setGeometry(QtCore.QRect(10, 561, 151, 192))
        self.verticalLayoutWidget_2.setObjectName("verticalLayoutWidget_2")
        self.verticalLayout = QtWidgets.QVBoxLayout(self.verticalLayoutWidget_2)
        self.verticalLayout.setContentsMargins(0, 0, 0, 0)
        self.verticalLayout.setObjectName("verticalLayout")
        self.pb_Aprender = QtWidgets.QPushButton(self.verticalLayoutWidget_2)
        self.pb_Aprender.setObjectName("pb_Aprender")
        self.verticalLayout.addWidget(self.pb_Aprender)
        self.progressBar = QtWidgets.QProgressBar(self.verticalLayoutWidget_2)
        self.progressBar.setProperty("value", 0)
        self.progressBar.setTextVisible(True)
        self.progressBar.setObjectName("progressBar")
        self.verticalLayout.addWidget(self.progressBar)
        self.pb_Parar = QtWidgets.QPushButton(self.verticalLayoutWidget_2)
        self.pb_Parar.setEnabled(False)
        self.pb_Parar.setObjectName("pb_Parar")
        self.verticalLayout.addWidget(self.pb_Parar)
        spacerItem = QtWidgets.QSpacerItem(20, 20, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.verticalLayout.addItem(spacerItem)
        self.pb_Borrarpuntos = QtWidgets.QPushButton(self.verticalLayoutWidget_2)
        self.pb_Borrarpuntos.setObjectName("pb_Borrarpuntos")
        self.verticalLayout.addWidget(self.pb_Borrarpuntos)
        spacerItem1 = QtWidgets.QSpacerItem(20, 20, QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Expanding)
        self.verticalLayout.addItem(spacerItem1)
        self.pb_Olvidar = QtWidgets.QPushButton(self.verticalLayoutWidget_2)
        font = QtGui.QFont()
        font.setItalic(True)
        self.pb_Olvidar.setFont(font)
        self.pb_Olvidar.setObjectName("pb_Olvidar")
        self.verticalLayout.addWidget(self.pb_Olvidar)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menuBar = QtWidgets.QMenuBar(MainWindow)
        self.menuBar.setGeometry(QtCore.QRect(0, 0, 1210, 22))
        self.menuBar.setObjectName("menuBar")
        self.menu = QtWidgets.QMenu(self.menuBar)
        self.menu.setObjectName("menu")
        MainWindow.setMenuBar(self.menuBar)
        self.actionCargar_puntuaciones = QtWidgets.QAction(MainWindow)
        self.actionCargar_puntuaciones.setObjectName("actionCargar_puntuaciones")
        self.actionGuardar_puntuaciones = QtWidgets.QAction(MainWindow)
        self.actionGuardar_puntuaciones.setObjectName("actionGuardar_puntuaciones")
        self.actionCargar_modelo_entrenado = QtWidgets.QAction(MainWindow)
        self.actionCargar_modelo_entrenado.setObjectName("actionCargar_modelo_entrenado")
        self.actionGuardar_modelo_entrenado = QtWidgets.QAction(MainWindow)
        self.actionGuardar_modelo_entrenado.setObjectName("actionGuardar_modelo_entrenado")
        self.actionExportar = QtWidgets.QAction(MainWindow)
        self.actionExportar.setObjectName("actionExportar")
        self.menu.addAction(self.actionCargar_puntuaciones)
        self.menu.addAction(self.actionGuardar_puntuaciones)
        self.menu.addSeparator()
        self.menu.addAction(self.actionCargar_modelo_entrenado)
        self.menu.addAction(self.actionGuardar_modelo_entrenado)
        self.menu.addSeparator()
        self.menu.addAction(self.actionExportar)
        self.menuBar.addAction(self.menu.menuAction())

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Sistema de Recomendación de Películas"))
        item = self.tableWidget.horizontalHeaderItem(0)
        item.setText(_translate("MainWindow", "Puntuación"))
        item = self.tableWidget.horizontalHeaderItem(1)
        item.setText(_translate("MainWindow", "Película"))
        item = self.tableWidget.horizontalHeaderItem(2)
        item.setText(_translate("MainWindow", "Valoración"))
        self.label_4.setText(_translate("MainWindow", "# epochs"))
        self.le_epochs.setToolTip(
            _translate("MainWindow", "Número de veces que se presentará el conjunto de entrenamiento"))
        self.le_minibatch.setToolTip(_translate("MainWindow", "Número de ejemplos de cada batch"))
        self.label_6.setText(_translate("MainWindow", "refresco"))
        self.le_drawevery.setToolTip(
            _translate("MainWindow", "Indica cada cuantos segundos se actualizan los gráficos"))
        self.label_5.setText(_translate("MainWindow", "batch"))
        self.cb_semillaaleatoria.setToolTip(
            _translate("MainWindow", "La generación de aleatorios comienza con semilla fija o variable"))
        self.cb_semillaaleatoria.setText(_translate("MainWindow", "Semilla aleatoria"))
        self.label.setText(_translate("MainWindow", "K"))
        self.le_K.setToolTip(_translate("MainWindow", "Dimensiones del espacio de proyección (embedding)"))
        self.label_2.setText(_translate("MainWindow", "learn. rate"))
        self.le_learningrate.setToolTip(_translate("MainWindow", "Factor de aprendizaje"))
        self.label_3.setText(_translate("MainWindow", "nu"))
        self.le_nu.setToolTip(_translate("MainWindow", "Factor de regularización"))
        self.pb_Aprender.setToolTip(_translate("MainWindow",
                                               "Aprende un modelo a partir de los datos de entrenamiento y de los gustos del usuario, si los ha indicado"))
        self.pb_Aprender.setText(_translate("MainWindow", "Aprender"))
        self.progressBar.setToolTip(_translate("MainWindow", "Progreso del proceso de aprendizaje"))
        self.pb_Parar.setToolTip(_translate("MainWindow", "Detiene el entrenamiento"))
        self.pb_Parar.setText(_translate("MainWindow", "Parar"))
        self.pb_Borrarpuntos.setToolTip(_translate("MainWindow", "Borra las puntuaciones cargadas en memoria"))
        self.pb_Borrarpuntos.setText(_translate("MainWindow", "Borrar puntuación"))
        self.pb_Olvidar.setToolTip(_translate("MainWindow", "Elimina el modelo aprendido"))
        self.pb_Olvidar.setText(_translate("MainWindow", "Olvidar"))
        self.menu.setTitle(_translate("MainWindow", "Ficheros"))
        self.actionCargar_puntuaciones.setText(_translate("MainWindow", "Cargar puntuaciones"))
        self.actionGuardar_puntuaciones.setText(_translate("MainWindow", "Guardar puntuaciones"))
        self.actionCargar_modelo_entrenado.setText(_translate("MainWindow", "Cargar modelo entrenado"))
        self.actionGuardar_modelo_entrenado.setText(_translate("MainWindow", "Guardar modelo entrenado"))
        self.actionExportar.setText(_translate("MainWindow", "Exportar"))
