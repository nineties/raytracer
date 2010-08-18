target: scene1.png scene2.png

.rb.png:
	time ruby $< > tmp.ppm
	convert tmp.ppm $@
	rm tmp.ppm

.SUFFIXES: .png .rb
