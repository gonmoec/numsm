CXX=g++
CXXFLAGS=-std=c++14 -I./src/cutf -I./src/eigen -O3
OMPFLAGS=-fopenmp
NVCC=nvcc
NVCCFLAGS=$(CXXFLAGS)  --compiler-bindir=$(CXX) -Xcompiler=$(OMPFLAGS) -lcublas -gencode arch=compute_60,code=sm_60 -gencode arch=compute_70,code=sm_70
SRCDIR=src
SRCS=$(shell find src -maxdepth 1 -name '*.cu' -o -name '*.cpp')
OBJDIR=objs
OBJS=$(subst $(SRCDIR),$(OBJDIR), $(SRCS))
OBJS:=$(subst .cpp,.o,$(OBJS))
OBJS:=$(subst .cu,.o,$(OBJS))
HEADERS=$(shell find $(SRCDIR) -name '*.cuh' -o -name '*.hpp' -o -name '*.h')
TARGET=numsm
$(TARGET): $(OBJS)
		$(NVCC) $(NVCCFLAGS) $+ -o $@
$(SRCDIR)/%.cpp: $(SRCDIR)/%.cu $(HEADERS)
		$(NVCC) $(NVCCFLAGS) --cuda $< -o $@
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
		[ -d $(OBJDIR) ] || mkdir $(OBJDIR)
			$(CXX) $(CXXFLAGS) $(OMPFLAGS) $< -c -o $@
clean:
		rm -rf $(OBJS)
			rm -rf $(TARGET)
