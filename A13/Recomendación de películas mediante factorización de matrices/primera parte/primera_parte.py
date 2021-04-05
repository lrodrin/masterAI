import numpy as np
import pandas as pd


def orderedByX(dataframe, x):
    df_x = dataframe.sort_values(by=[x], ascending=True)
    df_x = df_x.loc[:, ['_ID', 'Título', x]]
    print("{} - 10 películas situadas al principio: \n{}".format(x, df_x.head(10).to_string()))
    print("{} - 10 películas situadas al final: \n{}".format(x, df_x.tail(10).to_string()))

    df_x.to_excel("{}.xlsx".format(x), index=False)


def valoracion410(dataframe):
    df_x = dataframe.sort_values(by=['X4'], ascending=True)

    X = dataframe[['X1', 'X2', 'X3', 'X4', 'X5', 'X6']]
    print(X)
    print(X.shape)
    df.plot(style=['X1', 'X2'])

    # To recommend movies for me, I need to provide ratings for some moves
    df_x['Valoraciones 410'] = np.random.randint(1, 10, df_x.shape[0])
    print(df_x['Valoraciones 410'])

    a = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]])

    b = np.array([10, 20, 30])

    print("A =", a)

    print("b =", b)

    print("Ab =", np.matmul(a, b))

    # df_x.to_excel("primera_parte.xlsx", index=False)


def best_variableX():
    pass


if __name__ == '__main__':
    df = pd.read_excel('../movies-users.xlsx')

    # orderedByX(df, 'X4')
    # orderedByX(df, 'X1')
    # orderedByX(df, 'X2')
    # orderedByX(df, 'X3')
    # orderedByX(df, 'X5')
    # orderedByX(df, 'X6')

    valoracion410(df)
