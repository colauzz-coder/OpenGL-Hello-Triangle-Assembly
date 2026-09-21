BITS 64
%include "glfw.inc"
%include "glew.inc"
%include "opengl.inc"
%include "opengl.asm"
section .text
    global _start
_start:
    call glfwInit
    test eax, eax
    jz .GlfwError
    jmp .GlfwSuccess
    .GlfwError:
        mov rax, 1
        mov rdi, 1
        mov rsi, GlfwErrorLog
        mov rdx, GLfwErrorLength
        syscall
        jmp .exit
    .GlfwSuccess:
        mov rax, 1
        mov rdi, 1
        mov rsi, GlfwSuccessLog
        mov rdx, GlfwSuccessLength
        syscall



    mov edi, 800
    mov esi, 600
    mov edx, WindowName
    xor rcx, rcx
    xor r8, r8
    call glfwCreateWindow
    mov [Window], rax ;Stores Our Window
    test rax, rax
    jz .WindowError
    jmp .WindowSuccess
    .WindowError:
        mov rax, 1
        mov rdi, 1
        mov rsi, WindowErrorLog
        mov rdx, WindowErrorLength
        syscall
        jmp .exit
    .WindowSuccess:
        mov rax, 1
        mov rdi, 1
        mov rsi, WindowSuccessLog
        mov rdx, WindowSuccessLength
        syscall
    mov rdi, [Window]
    call glfwMakeContextCurrent



    call glewInit
    test eax, eax
    jnz .GlewError ;Glew Returns Null(0) If Success / Returns 1 If Not Success
    jmp .GlewSuccess

    .GlewError:
        mov rax, 1
        mov rdi, 1
        mov rsi, GlewErrorLog
        mov rdx, GlewErrorLength
        syscall
        jmp .exit
    .GlewSuccess:
        mov rax, 1
        mov rdi, 1
        mov rsi, GlewSuccessLog
        mov rdx, GlewSuccessLength
        syscall

    mov rdi, 1
    lea rsi, VAO
    call glGenVertexArrays

    mov rdi, VAO
    call glBindVertexArray

    mov rdi, 1
    lea rsi, VBO
    call glGenBuffers

    mov rdi, GL_ARRAY_BUFFER
    mov rsi, VBO
    call glBindBuffer

    mov rdi, GL_ARRAY_BUFFER
    mov rsi, AttributesSize
    lea rdx, [rel Attributes]
    mov rcx, GL_STATIC_DRAW
    call glBufferData

    mov rdi, 0
    mov rsi, 3
    mov rdx, GL_FLOAT
    mov rcx, GL_FALSE
    mov r8d, Stride
    mov r9d, 0
    call glVertexAttribPointer

    mov rdi, 0
    call glEnableVertexAttribArray

    mov rax, 2 ;Sys_Open, Opens The File
    lea rdi, [rel VertexShaderFile]
    mov rsi, 0 ;Read Only
    mov rdx, 0 ;We Are Not Creating The File, So The Creation Mode Is 0
    syscall

    mov rax, 0 ;Sys_Read, Reads What Is Inside The File
    lea rdi, [rel VertexShaderFileID] ;Vertex Shader Source File Descriptor
    lea rsi, [rel VertexShaderSource] ;Where The Buffer Will Stay
    mov rdx, 4096 ;Max Amount Of Bytes That The Kernel Can Read(4KB)
    syscall

    lea rbx, [rel VertexShaderSource] ;Buffer Base Address
    mov byte [rbx + rax], 0 ;Writes The Byte 0 At The End

    mov rax, 3 ;Sys_Close, Closes File
    mov rdi, [rel VertexShaderFileID]
    syscall
    .Render:
        mov rdi, [Window]
        call glfwWindowShouldClose
        test eax, eax
        jnz .exit ;If It's 1 It Means That The Window Was Closed

        mov edi, GL_COLOR_BUFFER_BIT
        call glClear

        movss xmm0, [rel Red]
        movss xmm1, [rel Green]
        movss xmm2, [rel Blue]
        movss xmm3, [rel Alpha]
        call glClearColor

        mov rdi, GL_TRIANGLES
        mov rsi, 0
        mov rdx, 3
        call glDrawArrays

        mov rdi, [Window]
        call glfwSwapBuffers

        call glfwPollEvents
        jmp .Render
    .exit:
        call glfwTerminate
        mov rax, 60
        xor rdi, rdi
        syscall
section .bss
    VertexShaderSource resb 4096
    VertexShaderFileID resq 1

    FragmentShaderBuffer resb 4096
    FragmentShaderFile resb "FragmentShader.glsl", 0
    VertexShaderFileID resq 1
section .data
    FloatSize equ 4
    Stride equ 3 * FloatSize

    Window dq 0

    VAO dd 0
    VBO dd 0

    align 16
    Attributes:
        dd 0.0, 0.5, 0.0
        dd -0.5, -0.5, 0.0
        dd 0.5, -0.5, 0.0
    AttributesSize equ $ - Attributes

section .rodata
    VertexShaderFile resb "VertexShader.glsl", 0

    Red dd 0.5
    Green dd 0.0
    Blue dd 1.0
    Alpha dd 1.0

    WindowName db "Window", 0

    WindowErrorLog db " [ error ] window couldn't be created ", 10
    WindowErrorLength equ $ - WindowErrorLog

    WindowSuccessLog db " [ success ] window created successfully ", 10
    WindowSuccessLength equ $ - WindowSuccessLog

    GlfwErrorLog db " [ error ] glfw couldn't be initialized ", 10
    GLfwErrorLength equ $ - GlfwErrorLog

    GlfwSuccessLog db " [ success ] glfw initialized successfully ", 10
    GlfwSuccessLength equ $ - GlfwSuccessLog

    GlewErrorLog db " [ error ] glew couldn't be initialized ", 10
    GlewErrorLength equ $ - GlewErrorLog

    GlewSuccessLog db " [ success ] glew initialized successfully", 10
    GlewSuccessLength equ $ - GlewSuccessLog
