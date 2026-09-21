.SUFFIXES:

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment.")
endif

include $(DEVKITARM)/ds_rules

TARGET := DSi-IA
BUILD := build

SOURCES := .
INCLUDES := .

ARCH := -march=armv5te -mtune=arm946e-s

CFLAGS := -g -Wall -O2 -ffunction-sections -fdata-sections $(ARCH)
CXXFLAGS := $(CFLAGS) -fno-rtti -fno-exceptions
ASFLAGS := -g $(ARCH)

LDFLAGS := -specs=ds_arm9.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS := -lnds9
LIBDIRS := $(LIBNDS)

ifneq ($(BUILD),$(notdir $(CURDIR)))

export OUTPUT := $(CURDIR)/$(TARGET)

export VPATH := $(CURDIR)

export DEPSDIR := $(CURDIR)/$(BUILD)

CFILES := $(notdir $(wildcard *.c))
CPPFILES := $(notdir $(wildcard *.cpp))
SFILES := $(notdir $(wildcard *.s))

ifeq ($(strip $(CPPFILES)),)
export LD := $(CC)
else
export LD := $(CXX)
endif

export OFILES := $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

export INCLUDE := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                  $(foreach dir,$(LIBDIRS),-I$(dir)/include) \
                  -I$(CURDIR)/$(BUILD)

export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

.PHONY: all clean

all: $(BUILD)

$(BUILD):
	@mkdir -p $@
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	@echo clean
	@rm -rf $(BUILD) $(TARGET).elf $(TARGET).nds $(TARGET).ds.gba

else

DEPENDS := $(OFILES:.o=.d)

$(OUTPUT).nds: $(OUTPUT).elf

$(OUTPUT).elf: $(OFILES)

%.o: %.cpp
	@echo Compilando $<
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

%.o: %.c
	@echo Compilando $<
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

%.o: %.s
	@echo Ensamblando $<
	$(CC) $(ASFLAGS) -c $< -o $@

-include $(DEPENDS)

endif
