find . -name "captura_*.mp4" -exec mediainfo {} \; | grep Dur

rm mylist.txt
for f in ./*.mp4; do echo "file '$f'" >> mylist.txt; done
ffmpeg -f concat -safe 0 -i mylist.txt -c copy -y concat.mp4

find . -name "*.mp4" -exec mediainfo {} \; | grep "Bit rate" 
