NAME          = studio
CXX          := em++
DEPEND        = common petri parse parse_cog parse_dot parse_ucs parse_verilog \
								arithmetic parse_expression interpret_arithmetic \
								chp parse_chp interpret_chp \
								flow interpret_flow

# Base include paths for dependencies
LIBRARY_DIRS = $(addprefix -I../../lib/,$(DEPEND)) $(addsuffix /include,$(addprefix -I../../lib/,$(DEPEND)))
BASE_INCLUDES = -I../../lib -I. $(LIBRARY_DIRS)
COVERAGE ?= 0

ifeq ($(COVERAGE),0)
CXXFLAGS = -std=c++20 -Os -Wall
LDFLAGS  =
else
CXXFLAGS = -std=c++20 -g -O0 -Wall --coverage -fprofile-arcs -ftest-coverage
LDFLAGS  = --coverage -fprofile-arcs -ftest-coverage 
endif

SRCDIR        = src
# Include paths for all dependencies and their subdirectories
INCLUDE_PATHS = $(BASE_INCLUDES) \
               $(addprefix -I../../lib/,$(DEPEND)) \
							 $(addsuffix /build-wasm,$(addprefix -I../../lib/,$(DEPEND))) \
               #$(shell python3-config --includes)

# Library paths and files
LIBRARY_PATHS = $(addsuffix /build-wasm,$(addprefix -L../../lib/,$(DEPEND))) -L.
LIBRARIES = $(addprefix -l,$(DEPEND)) -ldl
LIBFILES = $(foreach dep,$(DEPEND),../../lib/$(dep)/build-wasm/lib$(dep).a)

SOURCES	     := $(shell mkdir -p $(SRCDIR); find $(SRCDIR) -name '*.cpp')
OBJECTS	     := $(SOURCES:%.cpp=build-wasm/%.o)
DEPS         := $(shell mkdir -p build-wasm/$(SRCDIR); find build-wasm/$(SRCDIR) -name '*.d')

ifndef VERSION
override VERSION = "develop"
endif

ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


ifeq ($(OS),Windows_NT)
	CXXFLAGS += -D WIN32
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		CXXFLAGS += -D AMD64
	else
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			CXXFLAGS += -D AMD64
		endif
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			CXXFLAGS += -D IA32
		endif
	endif
	#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	#LIBRARY_PATHS += -L../../lib/gdstk/build/lib64
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		CXXFLAGS += -D LINUX
		#LIBRARIES += -l:libclipper.a -l:libqhullstatic_r.a
	endif
	ifeq ($(UNAME_S),Darwin)
		CXXFLAGS += -D OSX
		#INCLUDE_PATHS += -I$(shell brew --prefix qhull)/include
		#LIBRARY_PATHS += -L$(shell brew --prefix qhull)/lib
		#LIBRARIES += -lclipper -lqhullstatic_r
		#LDFLAGS	      += -Wl,-rpath,/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.12/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.10/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3.09/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python@3/Frameworks/Python.framework/Versions/Current/lib \
-Wl,-rpath,/opt/homebrew/opt/python/Frameworks/Python.framework/Versions/Current/lib
	endif
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS += -D AMD64
	endif
	ifneq ($(filter %86,$(UNAME_P)),)
		CXXFLAGS += -D IA32
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CXXFLAGS += -D ARM
	endif
endif


TARGET  = studio.js
LDFLAGS = -s WASM=1 \
          -s MODULARIZE=1 \
          -s EXPORT_ES6=1 \
          -s USE_ES6_IMPORT_META=1 \
          -s EXPORT_NAME='createLoomModule' \
          -s ENVIRONMENT=web \
          -s EXPORTED_FUNCTIONS='["_processLoomCode","_init","_malloc","_free"]' \
          -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap","UTF8ToString"]' \
          -s ALLOW_TABLE_GROWTH=1 \
          -s INVOKE_RUN=0 \
          -s TOTAL_MEMORY=536870912 \
          -s INITIAL_MEMORY=167772160 \
          -s STACK_SIZE=5242880 \
          -s ALLOW_MEMORY_GROWTH=1

all: $(TARGET)

$(TARGET): $(OBJECTS) $(LIBFILES)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LIBRARY_PATHS) $(LIBRARIES)

build-wasm/$(SRCDIR)/%.o: $(SRCDIR)/%.cpp 
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) $(INCLUDE_PATHS) -MM -MF $(patsubst %.o,%.d,$@) -MT $@ -c $<
	$(CXX) $(CXXFLAGS) $(INCLUDE_PATHS) -o $@ -c $<
	#@$(CXX) $(filter-out -D%,$(CXXFLAGS)) $(INCLUDE_PATHS) -MM -MF $(patsubst %.o,%.d,$@) -MT $@ -c $<
	#$(CXX) $(filter-out -D%,$(CXXFLAGS)) $(INCLUDE_PATHS) -o $@ -c $<

include $(DEPS)

clean:
	rm -rf build-wasm $(TARGET) $(TARGET:%.js=%.wasm)

run: all
	python3 -m http.server

