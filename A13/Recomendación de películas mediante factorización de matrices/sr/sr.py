import pandas as pd
import numpy as np

pd.set_option('display.max_columns', None)

movies = pd.read_csv('../dataset/movies.csv')
ratings = pd.read_csv('../dataset/ratings.csv')

regular_expression = r'\((.*?)\)'
movies['year'] = movies.title.str.lower().str.extract(regular_expression)
movies['title'] = movies.title.str.replace(regular_expression, '', regex=True)
movies['title'] = movies['title'].apply(lambda x: x.strip())
movies = movies.drop('genres', 1)
print(movies.head())

ratings = ratings.drop('timestamp', 1)
print(ratings.head())

# new_df = pd.DataFrame()
# new_df['title'] = movies.title.sample(n=100)
# new_df['rating'] = np.random.randint(1, 5, new_df.shape[0])
# new_df.to_csv("../dataset/user_ratings.csv", index=False)
# print(samples_dict)