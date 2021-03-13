import json
import math
import os
import random
from datetime import timedelta
from time import time

import numpy as np
import pandas as pd
import tensorflow as tf
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot
from sklearn.base import BaseEstimator


def seq_batch_decorator(func):
    def func_with_counter(*args, **kwargs):
        the_batch = func(*args, **kwargs)
        func_with_counter.last_example_included = the_batch.iloc[-1].name
        return the_batch

    func_with_counter.last_example_included = -1
    return func_with_counter


@seq_batch_decorator
def generate_next_sequential_batch(d, bsize, reset_last=False):
    num_rows = d.shape[0]
    assert bsize <= num_rows

    # num_batches_per_epoch = math.ceil(num_rows/bsize)
    # num_batch = (generate_next_batch.counter-1) % num_batches_per_epoch
    # initial = num_batch * bsize
    if reset_last:
        generate_next_sequential_batch.last_example_included = -1

    initial = generate_next_sequential_batch.last_example_included + 1
    if initial >= num_rows:
        initial = 0

    final = initial + bsize

    if final <= num_rows:
        batch = d[initial:final]
    else:
        # the dataframe has been exhausted, let's fill with the initial elements
        final = final - num_rows
        batch1 = d[initial:num_rows]
        batch2 = d[0:final]
        batch = pd.concat([batch1, batch2])

    return batch


def generate_next_random_batch(d, bsize):
    num_rows = d.shape[0]
    assert bsize <= num_rows
    # idx = [ random.randrange(0,num_rows) for _ in range(bsize) ]
    idx = random.choices(range(num_rows), k=bsize)
    return d.iloc[idx]


class Movielens_Learner(QObject, BaseEstimator):
    # Señal que se emite cada vez que sacamos información durante el entrenamiento
    computed_avg_loss = pyqtSignal(int, float, float, float)
    computed_embeddings = pyqtSignal(np.ndarray, np.ndarray)
    grafo_construido = pyqtSignal()
    grafo_eliminado = pyqtSignal()
    entrenamiento_finalizado = pyqtSignal()
    mensaje = pyqtSignal(str)
    progreso = pyqtSignal(int)

    def __init__(self, num_users, num_movies, K=100, learning_rate=0.01, nu=0.000001,
                 num_epochs=2, batch_size=25, batch_gen='random', drawevery=2, random_seed=True,
                 optimizer='Adam', save_path='movielens_model'):
        super().__init__()
        self.random_seed = random_seed
        self.learning_rate = learning_rate
        self.nu = nu
        self.num_epochs = num_epochs
        self.batch_size = batch_size
        self.batch_gen = batch_gen
        self.num_users = num_users
        # self.exam_size will be rewritten if an embedding file is loaded
        self.num_movies = num_movies
        self.K = K
        self.optimizer = optimizer
        self.save_path = save_path

        self.parar_entrenamiento = False  # flag que se usa para interrumpir un entrenamiento
        # Lista que contiene los steps y errores medios
        self.global_step = self.average_loss = 0
        self.drawevery = drawevery  # cada 'drawevery' iteraciones se dibuja

        # La creación del grafo se deja para la primera vez que se intente entrenar el sistema
        self.graph = None
        self.sess = None

        # # creación del grafo
        # self._init_graph()
        #
        # # creamos la sesión TF
        # self.sess = tf.Session(graph=self.graph)
        # self.reset_model()  # recien construido se inicializan las variables TF

    @pyqtSlot(name='_init_graph')
    def _init_graph(self):
        """
        Inicializar un grafo TF que contiene:
        datos de entrada, variables, modelo, función de pérdida, optimizador
        """
        self.grafo_construido.emit()
        self.graph = tf.Graph()

        with self.graph.as_default(), tf.device('/cpu:0'):
            # Semilla de generador de aleatorios
            if self.random_seed:
                SEED = int(time())
            else:
                SEED = 2032

            tf.set_random_seed(SEED)
            random.seed(SEED)

            # datos de entrada
            self.user = tf.placeholder(tf.int32, shape=None, name='Usuario')
            self.best_movie = tf.placeholder(tf.int32, shape=None, name='Pelicula_1')
            self.worst_movie = tf.placeholder(tf.int32, shape=None, name='Pelicula_2')
            self.tf_learning_rate = tf.Variable(self.learning_rate, trainable=False)
            self.tf_nu = tf.Variable(self.nu, trainable=False)

            # parametros W y V
            self.W = tf.Variable(tf.truncated_normal((self.K, self.num_users),
                                                     stddev=1.0 / np.sqrt(self.K)), name='Usuarios_Embedding_W')
            self.V = tf.Variable(tf.truncated_normal((self.K, self.num_movies),
                                                     stddev=1.0 / np.sqrt(self.K)), name='Peliculas_Embedding_V')

            user_embedding = tf.gather(self.W, self.user, axis=1, name='usuario_emb')
            best_movie_embedding = tf.gather(self.V, self.best_movie, axis=1, name='pelicula_1_emb')
            worst_movie_embedding = tf.gather(self.V, self.worst_movie, axis=1, name='pelicula_2_emb')

            self.__user_score = self.F_embeddings(user_embedding,
                                                  best_movie_embedding)  # useful for prediction purposes

            f_best = self.F_embeddings(user_embedding, best_movie_embedding)
            f_worst = self.F_embeddings(user_embedding, worst_movie_embedding)

            # self.valores = (f_best, f_worst)

            preference_loss_with_margin = tf.maximum(0.0, 1.0 - f_best + f_worst)

            reg = tf.nn.l2_loss(self.W) + tf.nn.l2_loss(self.V)

            # self.loss = tf.reduce_mean(preference_loss_with_margin) + self.nu * reg
            self.loss = tf.reduce_mean(preference_loss_with_margin) + self.tf_nu * reg

            if self.optimizer == 'Adam':
                self.opt = tf.train.AdamOptimizer(learning_rate=self.tf_learning_rate).minimize(loss=self.loss)
            elif self.optimizer == 'Adagrad':
                self.opt = tf.train.AdagradOptimizer(learning_rate=self.tf_learning_rate).minimize(loss=self.loss)
            else:  # SGD
                self.opt = tf.train.GradientDescentOptimizer(learning_rate=self.tf_learning_rate).minimize(
                    loss=self.loss)

            self._init_op = tf.global_variables_initializer()
            self._saver = tf.train.Saver()

            # Creamos la sesión TF
            self.sess = tf.Session(graph=self.graph)
            # y reseteamos el modelo (empezamos desde el principio)
            self.reset_model()

    def F(self, user, movie):
        # Función de valoración/compatibilidad entre un usuario y una película
        f_aux_1 = tf.matmul(user, self.W, transpose_a=False, transpose_b=True)
        f_aux = tf.matmul(f_aux_1, self.V)
        result = tf.diag_part(tf.matmul(f_aux, movie, transpose_b=True))
        return result

    @staticmethod
    def F_embeddings(user_embedding, movie_embedding):
        # Función de valoración/compatibilidad entre un usuario y una película
        # Los ususarios vienen dados por su representación en el espacio de dimensión K, al igual
        # que las películas, así que sólo nos queda hacer el producto escalar de ambos.
        # Como trabajaremos con batches de ejemplos, en realidad cada parámetro es un batch
        # de usuarios y de películas, por eso nos quedamos con la diagonal del producto
        # matricial
        result = tf.diag_part(tf.matmul(user_embedding, movie_embedding, transpose_a=True))
        return result

    def reset_graph(self):
        self.graph = None
        self.grafo_eliminado.emit()

    def reset_model(self):
        if self.sess is not None:
            self.sess.run(self._init_op)
            self.global_step = self.average_loss = 0
            self.mensaje.emit('Modelo reiniciado!\n')

    def stop_fit(self):
        self.parar_entrenamiento = True

    @pyqtSlot(pd.DataFrame, pd.DataFrame, name='fit')
    def fit(self, data, test_data):
        if self.graph is None:
            self._init_graph()

        # data is a pandas DataFrame
        num_examples = data.shape[0]
        # print('Training with %d examples' % num_examples)

        session = self.sess
        # asignar learning rate y nu para que sus valores sean efectivos en el grafo TensorFlow
        session.run([self.tf_learning_rate.assign(self.learning_rate),
                     self.tf_nu.assign(self.nu)])

        if self.batch_gen == 'random':
            generate_next_batch = generate_next_random_batch
        else:
            generate_next_batch = generate_next_sequential_batch
            generate_next_batch.last_example_included = -1

        self.mensaje.emit('\n**** COMIENZA EL ENTRENAMIENTO ****\n')

        t1 = time()
        # average_loss = 0
        steps_between_updates = 0
        self.parar_entrenamiento = False
        steps_per_epoch = int(math.ceil(num_examples / self.batch_size))
        for epoch in range(self.num_epochs):
            for step in range(steps_per_epoch):
                batch_data = generate_next_batch(data, self.batch_size)
                feed_dict = {self.user: batch_data.user,
                             self.best_movie: batch_data.best_movie,
                             self.worst_movie: batch_data.worst_movie}

                op, l = session.run([self.opt, self.loss], feed_dict=feed_dict)
                self.average_loss += l

                # INFORMACIÓN DURANTE EL ENTRENAMIENTO
                # self.drawevery = steps_per_epoch // 5
                self.global_step += 1
                steps_between_updates += 1

                t2 = time()
                ultima_iteracion = self.parar_entrenamiento or \
                                   (epoch == self.num_epochs - 1 and step == steps_per_epoch - 1)
                if (t2 - t1) >= self.drawevery or ultima_iteracion:
                    # Al ejecutar la última iteración dejamos actualizados los gráficos y los embeddings
                    self.average_loss /= steps_between_updates  # self.drawevery
                    # The average loss is an estimate of the loss over the last 'drawevery' batches.
                    msg = 'Epoch %3d, step %d ->\tError medio (entrenamiento): %f\n' % \
                          (epoch + 1, self.global_step, self.average_loss)

                    # Ahora miramos qué tal vamos en el conjunto de test (esto se hace porque esta es una aplicación
                    # didáctica, no podríamos hacerlo en condiciones reales, ya que no se puede utilizar
                    #  NUNCA el conjunto de test para entrenar
                    batch_data = test_data
                    feed_dict = {self.user: batch_data.user,
                                 self.best_movie: batch_data.best_movie,
                                 self.worst_movie: batch_data.worst_movie}

                    l_test = session.run(self.loss, feed_dict=feed_dict)
                    msg += '\t\tError en test:\t%f\n' % l_test

                    # Ahora hacemos las predicciones de pares de preferencias
                    # para el último usuario, que es el usuario interactivo. En este objeto
                    # ya contamos con el usuario interactivo, así que aquí su índice es self.num_users-1, mientras
                    # que en la clase de la aplicación su índice es num_users (allí num_users vale 1 menos que aquí)
                    # TODO: Dos contadores para número de usuarios con valores distintos es confuso, hay que cambiarlo
                    data_interactive_user = data[data.user == self.num_users - 1]
                    if len(data_interactive_user) > 0:  # pero sólo si ha dado algunas puntuaciones
                        feed_dict = {self.user: data_interactive_user.user,
                                     self.best_movie: data_interactive_user.best_movie,
                                     self.worst_movie: data_interactive_user.worst_movie}

                        l_iu = session.run(self.loss, feed_dict=feed_dict)
                        msg += '\t\tError en gustos del usuario: %f\n' % l_iu
                    else:
                        l_iu = np.nan

                    # emitimos señal con los datos que se pasan como parámetros y además, emite
                    # el usuario interactivo (última columna de W) y las películas (matriz V)
                    self._emite_datos(self.global_step, self.average_loss, l_test, l_iu)
                    self.average_loss = 0

                    t2 = time()
                    average_time = (t2 - t1) / steps_between_updates  # self.drawevery
                    estimated_time = average_time * ((steps_per_epoch - step - 1) +
                                                     steps_per_epoch * (self.num_epochs - epoch - 1))
                    t1 = time()
                    msg += ('(Tiempo restante estimado: %s)\n\n' % timedelta(seconds=round(estimated_time)))

                    steps_between_updates = 0

                    self.mensaje.emit(msg)

                    if self.parar_entrenamiento:
                        # self.parar_entrenamiento = False
                        self.mensaje.emit('\n *** ENTRENAMIENTO INTERRUMPIDO ***\n')
                        # self.autosave()
                        self.entrenamiento_finalizado.emit()
                        return  # salimos del entrenamiento

                porcentaje_completado = 100 * (1 + step + steps_per_epoch * epoch) / (self.num_epochs * steps_per_epoch)
                self.progreso.emit(porcentaje_completado)

        # save in the end...
        # self.autosave()
        self.mensaje.emit('\n--- ENTRENAMIENTO FINALIZADO ---\n')
        self.entrenamiento_finalizado.emit()

    def _emite_datos(self, gs, avl, lt, lu):
        # emitimos los errores para el gráfico de errores
        self.computed_avg_loss.emit(gs, avl, lt, lu)
        # Emitimos los embeddings, para el gráfico de las películas
        W, movies = self.getEmbeddings()
        # W, movies = session.run([self.W, self.V])
        user = W[:, -1]  # la ultima columna es el vector del usuario interactivo
        self.computed_embeddings.emit(user, movies)

    def getEmbeddings(self):
        if self.sess is not None:
            resultado = self.sess.run([self.W, self.V])
        else:
            resultado = (None, None)
        return resultado

    def predict(self, data):
        """
        Predice la valoración de los usuarios para las películas, contenidos ambos en *data*

        :param data: Pandas DataFrame donde la columna *user* contiene el ID de los usuarios y la columna *best*
        contiene los IDs de las películas que se quieren valorar. No se utiliza en este caso la columna *worst*,
        incluso puede no existir en el DataFrame, y la columna *best* puede llamarse *movie*

        :return: Un DataFrame Pandas con un valor (puntuación) para cada par usuario-película. Ojo, este valor no está
        normalizado de ninguna manera
        """
        # data es un DataFrame pandas
        num_examples = data.shape[0]
        # print('Prediction for %d examples' % num_examples)

        test_set = generate_next_sequential_batch(data, num_examples,
                                                  reset_last=True)  # Todos los datos secuencialmente
        # No se usas la columna worst que sí era necesaria en el entrenamiento, así que, si existe, su valor no importa

        if 'movie' in data.columns:
            movie = test_set.movie
        else:
            movie = test_set.best_movie
        feed_dict = {self.user: test_set.user, self.best_movie: movie}

        session = self.sess
        predictions = session.run(self.__user_score, feed_dict=feed_dict)
        df_result = pd.DataFrame(columns=['user', 'movie', 'predicted_score'])
        df_result.user = data.user
        df_result.movie = movie
        df_result.predicted_score = predictions

        return df_result

    def autosave(self):
        return self.save(self.save_path)

    def save(self, path):
        # """
        # Graba el modelo entrenado y sus parámetros.
        # """
        save_path = self._saver.save(self.sess, os.path.join(path, 'model.ckpt'))
        # save parameters of the model
        params = self.get_params()
        json.dump(params, open(os.path.join(path, 'model_params.json'), 'w', encoding='utf8'))

        # print("Modelo guardado en el fichero: %s" % save_path)
        return save_path

    def restore_on_created_object(self, path):
        path_dir = os.path.dirname(path)
        params = json.load(open(os.path.join(path_dir, 'model_params.json'), 'r', encoding='utf8'))
        self.set_params(**params)
        self._restore(path)

    def _restore(self, path):
        if self.graph is None:
            self._init_graph()
        with self.graph.as_default():
            self._saver.restore(self.sess, path)

    @classmethod
    def restore(cls, path):
        # """
        # Para cargar un modelo previamente guardado, en un objeto nuevo
        # """
        # load params of the model
        path_dir = os.path.dirname(path)
        params = json.load(open(os.path.join(path_dir, 'model_params.json'), 'r', encoding='utf8'))
        # init an instance of this class
        estimator = Movielens_Learner(**params)
        estimator._restore(path)

        return estimator


def load_and_recode_pj(filename, new_user_codes=None, new_movie_codes=None):
    pj = pd.read_csv(filename, names=['user', 'best_movie', 'worst_movie'])

    # recodificar usuarios y películas para que los índices comiencen en 0 y sean consecutivos
    # Si ya se suministran los diccionarios de recodificación como parámetros, sólo se aplican, si no, se
    # calculan y luego se aplican.

    if new_user_codes is None:
        set_of_users = set(pj.user)
        new_user_codes = dict(zip(set_of_users, range(len(set_of_users))))
    if new_movie_codes is None:
        set_of_movies = set(pj.best_movie).union(set(pj.worst_movie))
        new_movie_codes = dict(zip(set_of_movies, range(len(set_of_movies))))

    users_recoded = [new_user_codes[i] for i in pj.user]
    pj.user = users_recoded
    best_movies_recoded = [new_movie_codes[i] for i in pj.best_movie]
    pj.best_movie = best_movies_recoded
    worst_movies_recoded = [new_movie_codes[i] for i in pj.worst_movie]
    pj.worst_movie = worst_movies_recoded

    return pj, new_user_codes, new_movie_codes
    # return (pj, len(set_of_users), len(set_of_movies))
