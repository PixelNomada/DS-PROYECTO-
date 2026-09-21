.SUFFIXES:

ifeq ($(strip $(DEVKITARM)),)
$(error "DEVKITARM no esta definido")
endif

include $(DEVKITARM)/ds_rules

TARGET := DSi-IA
BUILD := build

SOURCES := .
INCLUDES := .

GAME_TITLE := DSi IA
GAME_SUBTITLE1 := Asistente escolar
GAME_SUBTITLE2 := Nintendo DS

CPPFILES := main.cpp

export TARGET
export OUTPUT := $(TARGET)
export BUILD
export SOURCES
export INCLUDES
export CPPFILES

# Para C++ el enlazador debe ser g++, no ld directamente.
export LD := $(CXX)

export OFILES := $(CPPFILES:.cpp=.o)

.PHONY: all clean

all: $(BUILD)

$(BUILD):
	@mkdir -p $(BUILD)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

clean:
	@rm -rf $(BUILD) $(TARGET).elf $(TARGET).nds $(TARGET).ds.gba

else

DEPENDS := $(OFILES:.o=.d)

$(OUTPUT).nds: $(OUTPUT).elf

$(OUTPUT).elf: $(OFILES)

%.o: ../%.cpp
	@echo Compilando $<
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

-include $(DEPENDS)

endif
