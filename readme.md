# ASSh - A Simple Linux Shell Built in x86-64 Assembly

ASSh (Assembly Shell) is an ultra-lightweight Linux shell written entirely in x86-64 assembly. This project is a personal challenge to create a functional, efficient, and library-free shell tailored instruction-by-instruction. The shell is minimalistic yet powerful, making it an ideal project for assembly enthusiasts and those curious about low-level programming.

## Features
- Minimal dependencies (pure assembly, no external libraries)
- Lightweight and efficient
- Highly customizable at the instruction level

## Version
**Current Version:** `v0.5.0`  
This initial version was created in one day and serves as a proof of concept. While functional, it is still in active development and lacks some advanced features.

## System Requirements
- An AMD64-compatible CPU
- AMD64 Linux (untested on old kernels, but assumed working)

## TODO
- Implement proper handling of `PATH` environment variables (string slicing in assembly is tricky!)
- Add support for shell scripting
- Improve error handling and edge case handling
- Documentation for assembly code

## Build Instructions
**Prerequisites:**  
Ensure you have the following tools installed:  
- NASM (Netwide Assembler)
- GNU Linker (`ld`)
- `make`

**Build Steps:**  
1. Clone this repository:
```git clone https://github.com/alobley/assh.git```
```cd assh```

2. Build the project:
```make```

## Contributing

Contributions are welcome! If you'd like to contribute:

- Fork the repository and submit a pull request.
- For direct contributions to the main branch, email me at rn5866n8@gmail.com to discuss your proposal.

When contributing, please:

- Follow the existing coding style and conventions.
- Include meaningful commit messages.
- Provide explanations or comments for any complex assembly instructions.

## License

This project is licensed under the MIT License. See the LICENSE file in the root directory for more details.
