# ===== Toolchain =====
CROSS    ?= riscv-none-elf-
CC       := $(CROSS)gcc
LD       := $(CROSS)gcc
OBJDUMP  := $(CROSS)objdump
OBJCOPY  := $(CROSS)objcopy

# ===== Flags =====
# ARCH     := -march=rv32i_zicsr -mabi=ilp32
ARCH     := -march=rv32i -mabi=ilp32
OPT      ?= -Os
CFLAGS   := $(ARCH) $(OPT) -ffreestanding -Wall -Wextra

LDFLAGS_ASM  := $(ARCH) -nostdlib -static
LDFLAGS_C := $(ARCH) -nostdlib -nostartfiles -static
LINKER   := linker.ld

# ===== Sources =====
RUNTIME_SRCS := start.S

APP_HW1_SRCS  := hw1_main.s
APP_Q2A_SRCS  := quiz2a_main.S
APP_Q3C_SRCS  := quiz3c_main.c

# ===== Build / Tools =====
BUILD    := build
RV32EMU ?= $(HOME)/rv32emu/build/rv32emu
TIMEOUT ?= gtimeout 10s

# ===== Object lists =====
OBJ_HW1 := $(patsubst %.S,$(BUILD)/%.o,$(filter %.S,$(RUNTIME_SRCS) $(APP_HW1_SRCS))) \
           $(patsubst %.s,$(BUILD)/%.o,$(filter %.s,$(RUNTIME_SRCS) $(APP_HW1_SRCS))) \
           $(patsubst %.c,$(BUILD)/%.o,$(filter %.c,$(RUNTIME_SRCS) $(APP_HW1_SRCS)))

OBJ_Q2A := $(patsubst %.S,$(BUILD)/%.o,$(filter %.S,$(RUNTIME_SRCS) $(APP_Q2A_SRCS))) \
           $(patsubst %.s,$(BUILD)/%.o,$(filter %.s,$(RUNTIME_SRCS) $(APP_Q2A_SRCS))) \
           $(patsubst %.c,$(BUILD)/%.o,$(filter %.c,$(RUNTIME_SRCS) $(APP_Q2A_SRCS)))

OBJ_Q3C := $(patsubst %.S,$(BUILD)/%.o,$(filter %.S,$(RUNTIME_SRCS) $(APP_Q3C_SRCS))) \
           $(patsubst %.s,$(BUILD)/%.o,$(filter %.s,$(RUNTIME_SRCS) $(APP_Q3C_SRCS))) \
           $(patsubst %.c,$(BUILD)/%.o,$(filter %.c,$(RUNTIME_SRCS) $(APP_Q3C_SRCS)))

# ===== Outputs =====
ELF_HW1 := $(BUILD)/hw1.elf
ELF_Q2A := $(BUILD)/quiz2a.elf
ELF_Q3C := $(BUILD)/quiz3c.elf

DUMP_HW1 := $(BUILD)/hw1.dump
DUMP_Q2A := $(BUILD)/quiz2a.dump
DUMP_Q3C := $(BUILD)/quiz3c.dump

BIN_HW1 := $(BUILD)/hw1.bin
BIN_Q2A := $(BUILD)/quiz2a.bin
BIN_Q3C := $(BUILD)/quiz3c.bin

# ===== Phony =====
.PHONY: all clean run-hw1 run-quiz2a run-quiz3c dump-hw1 dump-quiz2a dump-quiz3c bin-hw1 bin-quiz2a bin-quiz3c

all: $(ELF_Q3C)

# ===== Link =====
$(ELF_HW1): $(OBJ_HW1) $(LINKER) | $(BUILD)
	$(LD) $(LDFLAGS_ASM) -Wl,-T,$(LINKER) -o $@ $(OBJ_HW1)

$(ELF_Q2A): $(OBJ_Q2A) $(LINKER) | $(BUILD)
	$(LD) $(LDFLAGS_ASM) -Wl,-T,$(LINKER) -o $@ $(OBJ_Q2A)

$(ELF_Q3C): $(OBJ_Q3C) $(LINKER) | $(BUILD)
	$(LD) $(LDFLAGS_C) -Wl,-T,$(LINKER) -o $@ $(OBJ_Q3C) -lc -lm -lgcc

# ===== Compile =====
$(BUILD)/%.o: %.S | $(BUILD)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.s | $(BUILD)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.c | $(BUILD)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	@mkdir -p $(BUILD)

# ===== Run =====
run-hw1: $(ELF_HW1)
	$(TIMEOUT) $(RV32EMU) $<
run-quiz2a: $(ELF_Q2A)
	$(TIMEOUT) $(RV32EMU) $<
run-quiz3c: $(ELF_Q3C)
	$(TIMEOUT) $(RV32EMU) $<

# ===== Dump =====
dump-hw1: $(ELF_HW1)
	$(OBJDUMP) -d $< > $(DUMP_HW1)
dump-quiz2a: $(ELF_Q2A)
	$(OBJDUMP) -d $< > $(DUMP_Q2A)
dump-quiz3c: $(ELF_Q3C)
	$(OBJDUMP) -d $< > $(DUMP_Q3C)

# ===== Binary =====
bin-hw1: $(ELF_HW1)
	$(OBJCOPY) -O binary $< $(BIN_HW1)
bin-quiz2a: $(ELF_Q2A)
	$(OBJCOPY) -O binary $< $(BIN_Q2A)
bin-quiz3c: $(ELF_Q3C)
	$(OBJCOPY) -O binary $< $(BIN_Q3C)

# ===== Clean =====
clean:
	rm -rf $(BUILD)
