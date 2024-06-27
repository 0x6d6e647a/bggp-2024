AS = nasm
ASFLAGS += -f bin

%: %.asm
	${AS} ${ASFLAGS} -o $@ $^
	chmod +x $@

elf32: elf32.asm

elf32-64: elf32-64.asm

elf64: elf64.asm

.PHONY: all clean

all: elf32 elf32-64 elf64

clean:
	rm elf32 elf32-64 elf64

.DEFAULT_GOAL := all
