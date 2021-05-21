SRC = get_schedule.nim
NIM_CACHE = ./cache
TARGET = ./target
# CERTIFICATE_VALIDATION ?= on

run_release:
ifeq ($(wildcard $(TARGET)/get_schedule),"")
	release
endif
	$(TARGET)/get_schedule

run_debug: debug
ifeq ($(wildcard $(TARGET)/get_schedule_debug),"")
	release
endif
	$(TARGET)/get_schedule_debug

clean_target:
	rm -rf $(TARGET)/*

clean_cache:
	rm -rf $(NIM_CACHE)/*

clean_all: clean_target clean_cache

debug: $(SRC)
ifeq ($(CERTIFICATE_VALIDATION), "on")
	nim c\
		-d:ssl\
		-o:$(TARGET)/get_schedule_debug\
		--nimcache:$(NIM_CACHE)/debug\
		$(SRC)
else
	nim c\
		-d:ssl\
		-d:nimDisableCertificateValidation\
		-o:$(TARGET)/get_schedule\
		--nimcache:$(NIM_CACHE)/release\
		$(SRC)
endif
	


release: $(SRC)
ifeq ($(CERTIFICATE_VALIDATION), "on")
	nim c\
		-d:ssl\
		-d:release\
		-o:$(TARGET)/get_schedule\
		--nimcache:$(NIM_CACHE)/release\
		$(SRC)
else
	nim c\
		-d:ssl\
		-d:release\
		-d:nimDisableCertificateValidation\
		-o:$(TARGET)/get_schedule\
		--nimcache:$(NIM_CACHE)/release\
		$(SRC)
endif
