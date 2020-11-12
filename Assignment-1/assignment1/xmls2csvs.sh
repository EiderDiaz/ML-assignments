echo 'fingerprint,minutia,x,y,angle' > diff.csv
progress=1
for f in $(ls diff/)
do
    echo $progress
    temp=$(grep 'Experiment version' diff/"$f" | \
    sed -E 's/^[^\"]*(\"[^[:blank:]]*).*/\1/; s/\"//g')
    grep 'MissingMinutia ' diff/"$f" | \
    sed 's/<MissingMinutia x=\"//g; s/ y=\"//g; s/ angle=\"//g; s/\"\/>//g; s/[[:blank:]]//g' | \
    tr '\"' ',' > temp
    n=$(cat temp | wc -l)
    paste -d',' <(yes "$f" | sed 's/\.mntscore\.xml//g' | head -n "$n") <(echo "$temp" | tr ' ' '\n') <(cat temp) >> diff.csv
    progress=$((progress + 1))
done

echo 'fingerprint,X,Y,Angle,Type' > SD27_Latent.csv
progress=1
for f in $(ls SD27_Latent_xml)
do
    echo $progress
    grep 'Minutia ' SD27_Latent_xml/"$f" | \
    sed 's/<Minutia X=\"//g; s/ Y=\"//g; s/ Angle=\"//g; s/ Type=\"//g; s/\" \/>//g; s/[[:blank:]]//g' | \
    tr '\"' ',' > temp
    n=$(cat temp | wc -l)
    paste -d',' <(yes "$f" | sed 's/\.xml//g' | head -n "$n") <(cat temp) >> SD27_Latent.csv
    progress=$((progress + 1))
done

rm temp