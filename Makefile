TARGET=com.github.ryonakano.headerlabel-test

all:
	valac -o $(TARGET) --pkg gtk4 --pkg granite-7 ./HeaderLabelTest.vala

clean:
	rm -f $(TARGET)
