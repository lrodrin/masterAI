import pandas as pd
import numpy as np

# Generate random 100 ratings for a user
movies_df = pd.read_csv('../dataset/movies.csv')
new_df = pd.DataFrame()
new_df['title'] = movies_df.title.sample(n=100)
new_df['rating'] = np.random.randint(1, 5, new_df.shape[0])
new_df.to_csv("../dataset/user_ratings.csv", index=False)
print(new_df)
