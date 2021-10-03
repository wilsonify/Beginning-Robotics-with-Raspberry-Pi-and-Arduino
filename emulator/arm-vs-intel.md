ARM processor vs. Intel processor
===========

There are many differences between Intel and ARM, 
but the main difference is the instruction set. 

Intel is a CISC (Complex Instruction Set Computing) processor that has a larger and more feature-rich instruction set and allows many complex instructions to access memory.
It therefore has more operations, addressing modes, but less registers than ARM. 
CISC processors are mainly used in normal PC’s, Workstations, and servers.

ARM is a RISC (Reduced instruction set Computing) processor and therefore has a simplified instruction set 
(100 instructions or less) and more general purpose registers than CISC.

Unlike Intel, ARM uses instructions that operate only on registers and uses a Load/Store memory model for memory access,
which means that only Load/Store instructions can access memory. 

This means that incrementing a 32-bit value at a particular memory address on ARM would require three types of instructions 
(load, increment and store) to first load the value at a particular address into a register, 
increment it within the register,
and store it back to the memory from the register.

The reduced instruction set has its advantages and disadvantages. 
One of the advantages is that instructions can be executed more quickly, 
potentially allowing for greater speed (RISC systems shorten execution time by reducing the clock cycles per instruction). 
The downside is that fewer instructions means a greater emphasis on the efficient writing of software with the limited instructions that are available.
Also important to note is that ARM has two modes, ARM mode and Thumb mode.
Thumb instructions can be either 2 or 4 bytes (more on that in Part 3: ARM Instruction set).

## More differences between ARM and x86 are:

* In ARM, most instructions can be used for conditional execution.
* The Intel x86 and x86-64 series of processors use the little-endian format.
* The ARM architecture was little-endian before version 3.
* Since then ARM processors became BI-endian and feature a setting which allows for switchable endianness.

There are not only differences between Intel and ARM,
but also between different ARM version themselves.
This tutorial series is intended to keep it as generic as possible so that you get a general understanding about how ARM works.
Once you understand the fundamentals, 
it’s easy to learn the nuances for your chosen target ARM version. 
The examples in this tutorial were created on an 32-bit ARMv6 (Raspberry Pi 1), 
therefore the explanations are related to this exact version.

The naming of the different ARM versions might also be confusing:

| ARM family 	| ARM architecture |
|---------------|------------------|
|ARM7 | 	ARM v4
|ARM9 |	ARM v5
|ARM11 |	ARM v6
|Cortex-A | 	ARM v7-A
|Cortex-R |	ARM v7-R
|Cortex-M |	ARM v7-M

## Writing Assembly

Before we can start diving into ARM exploit development we first need to understand the basics of Assembly language programming,
which requires some background knowledge before you can start to appreciate it.
But why do we even need ARM Assembly? 
Isn’t it enough to write our exploits in a “normal” programming / scripting language?

It is not, if we want to be able to do Reverse Engineering and understand the program flow of ARM binaries,
build our own ARM shellcode, craft ARM ROP chains, and debug ARM applications.

You don’t need to know every detail of the Assembly language to be able to do Reverse Engineering and exploit development,
yet some of it is required for understanding the bigger picture. 
The fundamentals will be covered in this tutorial series.
If you want to learn more you can visit the links listed at the end of this chapter.

So what exactly is Assembly language? 
Assembly language is just a thin syntax layer on top of the machine code which is composed of instructions,
that are encoded in binary representations (machine code),
which is what our computer understands. 
So why don’t we just write machine code instead? 
Well, that would be a pain in the ass. 
For this reason, we will write assembly, ARM assembly,
which is much easier for humans to understand. 

Our computer can’t run assembly code itself, 
because it needs machine code. 
The tool we will use to assemble the assembly code into machine code is a GNU Assembler
from the GNU Binutils project named as which works with source files having the *.s extension.

Once you wrote your assembly file with the extension *.s, you need to assemble it with as and link it with ld:
```
$ as program.s -o program.o
$ ld program.o -o program
```