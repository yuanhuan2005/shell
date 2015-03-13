#!/bin/bash

while true 
do
	clear;date;echo "";wc -l *.jtl; echo "";echo "movie log:";tail -n 15 logs/movie* ; echo "";echo "PBO TEST log:"; tail -n 12 logs/pbo_test_* ;sleep 5
	clear;date;echo "";wc -l *.jtl; echo "";echo "cartoon log:";tail -n 15 logs/car* ; echo "";echo "PBO TEST log:"; tail -n 12 logs/pbo_test_* ;sleep 5
	clear;date;echo "";wc -l *.jtl; echo "";echo "tv log:";tail -n 15 logs/tv* ; echo "";echo "PBO TEST log:"; tail -n 12 logs/pbo_test_* ;sleep 5
	clear;date;echo "";wc -l *.jtl; echo "";echo "variety log:";tail -n 15 logs/var* ; echo "";echo "PBO TEST log:"; tail -n 12 logs/pbo_test_* ;sleep 5
done
