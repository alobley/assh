all: assemble run

assemble:
	@echo "Compiling..."
	nasm -f elf64 -o build/shell.o src/shell.asm
	ld -o bin/shell build/shell.o -m elf_x86_64 -static -nostdlib -e _start

run:
	@echo "Running..."
	./bin/shell