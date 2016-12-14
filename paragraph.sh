mkdir word2vec; cd word2vec
cp ../../iclr15/scripts/word2vec.c .
gcc word2vec.c -o word2vec -lm -pthread -O3 -march=native -funroll-loops

cat ../data/full-train-pos.txt ../data/full-train-neg.txt ../data/test-pos.txt ../data/test-neg.txt ../data/train-unsup.txt > alldata.txt
awk 'BEGIN{a=0;}{print "_*" a " " $0; a++;}' < alldata.txt > alldata-id.txt
shuf alldata-id.txt > alldata-id-shuf.txt

time ./word2vec -train alldata-id-shuf.txt -output vectors.txt -cbow 0 -size 100 -window 10 -negative 5 -hs 1 -sample 1e-3 -threads 40 -binary 0 -iter 20 -min-count 1 -sentence-vectors 1
grep '_\*' vectors.txt | sed -e 's/_\*//' | sort -n > sentence_vectors.txt

head sentence_vectors.txt -n 25000 | awk 'BEGIN{a=0;}{if (a<12500) printf "1"; else printf "-1"; for (b=1; b<NF; b++) printf "," $(b+1); print ""; a++;}' > train.txt
head sentence_vectors.txt -n 50000 | tail -n 25000 | awk 'BEGIN{a=0;}{if (a<12500) printf "1"; else printf "-1"; for (b=1; b<NF; b++) printf "," $(b+1); print ""; a++;}' > test.txt

# The files will be used in deep_learning.R