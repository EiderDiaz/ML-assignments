import os
import re

runs_dir = os.curdir + '/runs/'
output_filename = os.curdir + 'results.csv'

def getTopPatters(patterns, num = 4):
    top = sorted(patterns, key=lambda x: x[1], reverse=True)
    return top[:num]

def main(all_files = True, single_file = '', threshold = 0.3):
    if all_files:
        files = os.listdir(runs_dir)
    else:
        files = [single_file]

    for filename in files:
        filename_full = runs_dir + filename

        f = open(filename_full, 'r')
        lines = f.read().splitlines()

        patterns = set()

        for line in lines:
            scores = re.search('[[].*[]]', line)
            if scores:
                sr = scores.group()
                sr1 = float(sr[1:5])
                sr2 = float(sr[6:10])
                difference = sr1 - sr2
                if difference > threshold:
                    pattern = line[:-11]
                    patterns.add((pattern, difference))
        
        top_patterns = getTopPatters(patterns)
        for p in top_patterns:
            info_string = '{},{},{}\n'.format(filename, p[0], p[1])

            output_csv = open(output_filename, "a")
            output_csv.write(info_string)
            output_csv.close()


main()
