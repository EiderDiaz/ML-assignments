from sklearn.preprocessing import KBinsDiscretizer
import os
import re
import pandas as pd

'''
DISCRETIZED FILES
Output filenames: (original) filename + algorithm + config
algorithm:
    EWD - Equal Width
    EFQ - Equal Frequency
    KBN - KBins
config:
    1 - 3 bins
    2 - 5 bins
    3 - 10 bins
'''
def discretize_db(directory, filename):
    print(directory)
    print(filename)
    path = 'databases/' + directory + '/'
    df = pd.read_csv(path + filename)

    # Algoriths and parameters
    algorithms = ['EWD', 'EFQ', 'KBN']
    configs = ['1', '2' ,'3']
    bins = [3, 5, 10]
    strategies = ['uniform', 'quantile', 'kmeans']

    x = df.iloc[:,:-1]
    y = df.iloc[:, -1]

    # Factorize string columns
    for col in x:
        if x[col].dtype == 'object':
            x[col] = pd.factorize(x[col])[0]

    # Discretize using EWD
    for i in range(len(algorithms)):
        algorithm = algorithms[i] # ['EWD', 'EFQ', 'KBN']
        strategy = strategies[i] # ['uniform', 'quantile', 'kmeans']
        for j in range(len(configs)):
            n_bins = bins[j] # [3, 5, 10]
            config = configs[j] # ['1', '2' ,'3']
            output_file = filename + algorithm + config + '.csv'
            print(filename + ' ' + algorithm + ' ' + config)
            # Discretize features
            discretizer = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy=strategy)
            x_disc = discretizer.fit_transform(x)
            df_disc = pd.DataFrame(x_disc)
            df_disc['y'] = y
            df_disc.to_csv(path + output_file)
            print(output_file)
    
    print('All files discretized with 3 algorithms')




'''
Three discretization algorithms, each with 3 different parameter configurations
'''
# Parameter config 1
n_bins = 10
ewd_1 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='uniform')
efq_1 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='quantile')
kbn_1 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='kmeans')
# Parameter config 2
n_bins = 5
ewd_2 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='uniform')
efq_2 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='quantile')
kbn_2 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='kmeans')
# Parameter config 3
n_bins = 3
ewd_3 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='uniform')
efq_3 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='quantile')
kbn_3 = KBinsDiscretizer(n_bins=n_bins, encode='ordinal', strategy='kmeans')
# X_binned = enc.fit_transform(X)

'''
Constants for matching with file names
'''
DEFAULT_TEST = 'tst.dat.csv$'
DEFAULT_TRAIN = 'tra.dat.csv$'
path = 'databases'

databases = os.listdir(path)
print(databases)
for directory in databases:
    database_dir = os.listdir( path+"/"+directory)
    database_dir.sort()
    for database in database_dir:
        if re.search(DEFAULT_TRAIN, database):
            print(database)
            discretize_db(directory, database)

            # break
        else:
            pass
    # break
    print("---------------")