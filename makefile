SRC = get_schedule.nim
NIM_CACHE = ./cache
TARGET = ./target

run_release: release
	clear
	$(TARGET)/get_schedule

run_debug: debug
	$(TARGET)/get_schedule_debug

clean:
	rm -rf $(NIM_CACHE)/* $(TARGET)/*


debug: $(SRC)
	nim c -d:ssl\
		-o:$(TARGET)/get_schedule_debug\
		--nimcache:$(NIM_CACHE)\
		$(SRC)


release: $(SRC)
	nim c -d:ssl\
		-d:release\
    	-o:$(TARGET)/get_schedule\
		--nimcache:$(NIM_CACHE)\
    	$(SRC)
