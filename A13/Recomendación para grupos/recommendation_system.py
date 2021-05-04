from math import sqrt

import pandas as pd
from tabulate import tabulate

pd.set_option('display.max_columns', None)


def print_df(dataframe, nrows):
    """
    Print dataframe rows specified by nrows as table
    """
    if isinstance(nrows, int):
        lines_to_print = dataframe.head(nrows)
    else:
        lines_to_print = dataframe  # print all lines of dataframe

    print(tabulate(lines_to_print, headers='keys', tablefmt='psql'))
    print(lines_to_print.to_latex(index=False))  # convert table to latex format

# Create movies and ratings dataframes
movies_df = pd.read_csv('dataset/movies.csv')
ratings_df = pd.read_csv('dataset/ratings.csv')
print('[initial movies dataframe]')
print_df(movies_df, 10)

# Take the year out of the title column and save it in a new column
regular_expression = r'\((.*?)\)'
movies_df['year'] = movies_df.title.str.lower().str.extract(regular_expression)
movies_df['title'] = movies_df.title.str.replace(regular_expression, '', regex=True)
movies_df['title'] = movies_df['title'].apply(lambda x: x.strip())
# Remove genres column and save movies_df
movies_df = movies_df.drop('genres', 1)
print('[final movies dataframe]')
print_df(movies_df, 10)

# Remove timestamp column and save ratings_df
ratings_df = ratings_df.drop('timestamp', 1)
print('[final ratings dataframe]')
print_df(ratings_df, 10)

# Create user dataframe
user_df = pd.read_csv('dataset/new_user.csv')
# print_df(user_df)

# Add movieId to user dataframe
titles = movies_df[movies_df['title'].isin(user_df['title'].tolist())]
user_df = pd.merge(titles, user_df)
user_df = user_df.drop('year', 1)  # Remove year column
print('[new user dataframe]')
print_df(user_df, 10)

# Users who have seen the same movies
movies = ratings_df[ratings_df['movieId'].isin(user_df['movieId'].tolist())]
users = movies.groupby(['userId'])    # Grouping users by userId

# User 525
print('[user 525]')
print_df(users.get_group(525), 'all')

# Users who have more movies in common have more priority
common_users = sorted(users, key=lambda x: len(x[1]), reverse=True)

# Neighborhood selection
neighborhood = common_users[0:100]  # Choosing 100 users to do the iterations

# Pearson
pearsonCorrelationDict = {}
for id, group in neighborhood:
    # The current user and the new user are ordered in the same way
    user = group.sort_values(by='movieId')
    movies = user_df.sort_values(by='movieId')

    # Number of ratings for user
    nRatings = len(user)

    # Common ratings of the current user with the new user
    temp_df = movies[movies['movieId'].isin(user['movieId'].tolist())]
    tempRatingList = temp_df['rating'].tolist()

    # Ratings of the current user
    tempUserList = user['rating'].tolist()

    # Calculate the Pearson Correlation between the current user and new user
    Uxx = sum([i ** 2 for i in tempRatingList]) - pow(sum(tempRatingList), 2) / float(nRatings)
    Uyy = sum([i ** 2 for i in tempUserList]) - pow(sum(tempUserList), 2) / float(nRatings)
    Uxy = sum(i * j for i, j in zip(tempRatingList, tempUserList)) - sum(tempRatingList) * sum(tempUserList) / float(nRatings)

    # If the denominator is nonzero, then we divide, otherwise the correlation is 0
    if Uxx != 0 and Uyy != 0:
        pearsonCorrelationDict[id] = Uxy / sqrt(Uxx * Uyy)
    else:
        pearsonCorrelationDict[id] = 0

print(pearsonCorrelationDict.items())

# Create pearson dataframe
pearson_df = pd.DataFrame.from_dict(pearsonCorrelationDict, orient='index')
pearson_df.columns = ['similarityIndex']
pearson_df['userId'] = pearson_df.index
pearson_df.index = range(len(pearson_df))
print_df(pearson_df, 10)

# Get the top 50 most similar users
topUsers = pearson_df.sort_values(by='similarityIndex', ascending=False)[0:50]
# print_df(topUsers)

# Merge ratings and top users dataframe
topUsersRating = topUsers.merge(ratings_df, left_on='userId', right_on='userId', how='inner')
# The similarity of user ratings is multiplied
topUsersRating['weightedRating'] = topUsersRating['similarityIndex'] * topUsersRating['rating']
#print_df(topUsersRating)
# A sum is applied to the top users after grouping them by userId
tempTopUsersRating = topUsersRating.groupby('movieId').sum()[['similarityIndex', 'weightedRating']]
tempTopUsersRating.columns = ['sum_similarityIndex', 'sum_weightedRating']
#print_df(topUsersRating)

# Recommend movies to new user
recommendation_df = pd.DataFrame()
# Calculate the weighted average
recommendation_df['weighted average recommendation score'] = tempTopUsersRating['sum_weightedRating'] / \
                                                             tempTopUsersRating['sum_similarityIndex']
recommendation_df['movieId'] = tempTopUsersRating.index

# The first 20 movies the algorithm recommends
recommendation_df = recommendation_df.sort_values(by='weighted average recommendation score', ascending=False)
recommendation_df = movies_df.loc[movies_df['movieId'].isin(recommendation_df.head(10)['movieId'].tolist())]
#print_df(recommendation_df)

# Save recommendations to CSV file
recommendation_df[['title', 'year']].to_csv('recommendation.csv', index=False)

