# Student Information ---------------------------------------------------------
#   ID          NAME                    EMAIL
#   20206018    Khaled Shawki           k.shawki@stud.fci-cu.edu.eg
#   20196106    Nada Mahgoub            20196106@stud.fci-cu.edu.eg
#   20196112    Hazim Nassar            20196112@stud.fci-cu.edu.eg
#   20196037    Amr Halaby              20196037@stud.fci-cu.edu.eg

# Course Information ----------------------------------------------------------
#   Computer Architecture - Software Engineering Program
#   Assignment 02 - Deadline: 30 Dec 2022;

# Problem Statemnet: ---------------------------------------------------------- 
#   - Write a 32-bits intel-syntax assembly program that can be 
#     compiled in the same way the 32-bits lab samples are compiled.
#   - The program should take the following inputs from the user:
#       - An integer n.
#       - n floating point numbers (Use the "double" type).
#   - The program should output 
#     (1+1/1)+(2+1/4)+(3+1/9)+(4+1/16)+...+(n+1/(n^2)).

# Example: --------------------------------------------------------------------
#   - The user inputs: 3
#   - The program outputs: sum=7.361

# How To Compile --------------------------------------------------------------
#   gcc -O3 -o float.exe float.s
#   After running the program
#   enter a positive integer and press Enter

.intel_syntax noprefix  # use the intel syntax, do not prefix registers with %
.section .data          # memory variables

input: .asciz "%d"                    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum is: %f\n"     # string terminated by 0 that will be used for printf parameter

n: .int 0             # the variable n which we will get from user using scanf
s: .double 0.0        # the variable s = 1/1 + 1/2 + 1/3 + ... + 1/n that will be calculated by the program 
one: .double 1.0
r: .double 1.0        # the variable r with type double and initalize 1.0
t: .double 1.0        # the variable t with type double and initalize 1.0

.section .text       # instructions
.globl _main         # make _main accessible from external

# Main Program Start Here ----------------------------------------------------- 
_main:               # the label indicating the start of the program
  push OFFSET n      # push to stack the second parameter to scanf (the address of the integer variable n)
  push OFFSET input  # push to stack the first parameter to scanf
  call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
  add esp, 8         # pop the above two parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)
  
  mov ecx, n         # ecx <- n (the number of iterations)

iteration:
  # the following instruction to add the total sum
  fld     qword ptr t         # push t to the floating point stack
  fadd    qword ptr sum
  fstp    qword ptr sum
  mov     edx, dword [t]
  mov     dword [r], edx
  
  # the following instructions increase s by 1/r --------------------------------------------------
  fld qword ptr t              # push t to the floating point stack
  fld st(0)                    # get position 
  fmul                         # multiplaction term => t*t
  fstp qword ptr r             # pop the floating point stack top (1), divide it over r /

  fld qword ptr one            # push 1 to the floating point stack
  fdiv qword ptr r             # pop the floating point stack top (1), divide it over r and push the result (1/r)

  fadd qword ptr s             # pop the floating point stack top (1/r), add it to s, and push the result (s+(1/r))
  fstp qword ptr s             # pop the floating point stack top (s+(1/r)) into the memory variable s

  # the following 3 instructions increase term by 1 -------------------------------------------------
  fld qword ptr t              # push 1 to the floating point stack
  fadd qword ptr one           # pop the floating point stack top (1), add it to r and push the result (r+1)
  fstp qword ptr t             # pop the floating point stack top (r+1) into the memory variable r

  loop iteration               # ecx -=1 , then goto iteration only if ecx is not zero
  
  push [s+4]         # push to stack the high 32-bits of the second parameter to printf (the double at label s)
  push s             # push to stack the low 32-bits of the second parameter to printf (the double at label s)
  push OFFSET output # push to stack the first parameter to printf
  call _printf       # call printf
  add esp, 12        # pop the two parameters

  ret                # end the main function
# ----------------------------------------------------------------
