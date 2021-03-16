import pandas as pd


def variableX(df, x):
    df_x = df.sort_values(by=[x], ascending=True)
    df_x.to_excel("{}.xlsx".format(x))
    print("{} - 10 películas situadas al principio: \n{}".format(x, df_x.head(10).to_string()))
    print("{} - 10 películas situadas al final: \n{}".format(x, df_x.tail(10).to_string()))


def valoracion():
    pass


def best_variableX():
    pass


if __name__ == '__main__':
    df = pd.read_excel('movies-users.xlsx', index_col=0)
    variableX(df, 'X4')
    variableX(df, 'X1')
    variableX(df, 'X2')
    variableX(df, 'X3')
    variableX(df, 'X5')
    variableX(df, 'X6')
