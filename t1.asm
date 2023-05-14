; define a posição inicial da interface gráfica
posicao_x db 10
posicao_y db 10

; define as strings de entrada e os resultados
string_num1 db "Número 1: 0000", 0
string_num2 db "Número 2: 0000", 0
string_operacao db "Escolha a operação: ", 0
string_resultado db "Resultado: 0000", 0

; define as variáveis para os números de entrada e o resultado
num1 dw 0
num2 dw 0
resultado dw 0

; define as sub-rotinas para as operações
soma:
    ; adiciona os dois números e armazena o resultado
    mov ax, [num1]
    add ax, [num2]
    mov [resultado], ax
    ret

subtracao:
    ; subtrai o segundo número do primeiro número e armazena o resultado
    mov ax, [num1]
    sub ax, [num2]
    mov [resultado], ax
    ret

multiplicacao:
    ; multiplica os dois números e armazena o resultado
    mov ax, [num1]
    mul [num2]
    mov [resultado], ax
    ret

divisao:
    ; verifica se o segundo número é zero (erro de divisão por zero)
    cmp [num2], 0
    je erro_divisao
    ; divide o primeiro número pelo segundo número e armazena o resultado
    mov ax, [num1]
    cwd
    idiv word [num2]
    mov [resultado], ax
    ret
erro_divisao:
    ; exibe uma mensagem de erro de divisão por zero e retorna
    mov ah, 9 ; seleciona a função de saída de string
    mov dx, offset string_erro_divisao ; seleciona a mensagem de erro
    int 21h ; chama a interrupção de saída
    ret

; cria a interface gráfica
cria_interface:
    ; limpa a tela
    mov ah, 0 ; seleciona a função de vídeo
    mov al, 3 ; seleciona o modo de texto de 80x25
    int 10h ; chama a interrupção de vídeo
    ; exibe as strings de entrada
    mov ah, 9 ; seleciona a função de saída de string
    mov dx, offset string_num1 ; seleciona a string de número 1
    mov ah, 9
    int 21h ; chama a interrupção de saída
    mov dx, offset string_num2 ; seleciona a string de número 2
    mov ah, 9
    int 21h ; chama a interrupção de saída
    ; adiciona os campos de entrada para o número 1
    mov ah, 10 ; seleciona a função de entrada
    mov cx, 4 ; define o tamanho do campo de entrada para 4 dígitos
    mov bx, 0 ; define a cor de fundo do campo

    mov dl, '_' ; define o caractere de preenchimento do campo de entrada
    mov ah, 1 ; seleciona a função de entrada de tecla
    mov si, offset num1 ; seleciona a variável do número 1
    mov di, offset string_num1 + 10 ; posiciona o cursor no início do campo de entrada
    call move_cursor ; chama a sub-rotina para posicionar o cursor
    input_num: ; início do loop de entrada de número 1
    int 21h ; chama a interrupção de entrada de tecla
    cmp al, 13 ; verifica se a tecla pressionada foi ENTER
    je input_operacao ; se sim, avança para a entrada da operação
    cmp al, '0' ; verifica se a tecla pressionada é um dígito de 0 a 9
    jb input_num ; se não, volta para o início do loop
    cmp al, '9'
    ja input_num
    sub al, '0' ; converte o caractere ASCII em um número de 0 a 9
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov bx, 10 ; define o divisor para a conversão do número ASCII em decimal
    mul bx ; multiplica o número atual por 10
    add ax, si ; adiciona o dígito atual ao número total
    mov si, ax ; atualiza a variável do número 1
    mov ah, 9 ; seleciona a função de saída de string
    mov dx, di ; posiciona o cursor no local da entrada
    mov al, [si] ; carrega o caractere ASCII correspondente ao número atual
    int 21h ; exibe o caractere na tela
    inc di ; move o cursor para a direita
    jmp input_num ; volta para o início do loop

    input_operacao: ; início da entrada de operação
    ; exibe a string de operação e adiciona os campos de seleção
    mov dx, offset string_operacao ; seleciona a string de operação
    mov ah, 9
    int 21h ; chama a interrupção de saída
    mov ah, 10 ; seleciona a função de entrada
    mov cx, 1 ; define o tamanho do campo de seleção para 1 caractere
    mov bx, 0 ; define a cor de fundo do campo de seleção
    mov dl, ' ' ; define o caractere de preenchimento do campo de seleção
    mov ah, 1 ; seleciona a função de entrada de tecla
    mov di, offset string_operacao + 18 ; posiciona o cursor no início do campo de seleção
    call move_cursor ; chama a sub-rotina para posicionar o cursor
    input_op: ; início do loop de entrada de operação
    int 21h ; chama a interrupção de entrada de tecla
    cmp al, '+' ; verifica se a tecla pressionada foi '+'
    je soma_op ; se sim, avança para a operação de soma
    cmp al, '-' ; verifica se a tecla pressionada foi '-'
    je subtracao_op ; se sim, avança para a operação de subtração
    cmp al, '*' ; verifica se a tecla pressionada foi '*'
    je multiplicacao_op ; se sim, avança para a operação de multiplicação

    cmp al, '/' ; verifica se a tecla pressionada foi '/'
    je divisao_op ; se sim, avança para a operação de divisão
    cmp al, 13 ; verifica se a tecla pressionada foi ENTER
    jne input_op ; se não, volta para o início do loop
    jmp input_op ; volta para o início do loop

    soma_op: ; início da operação de soma
    mov bl, '+' ; define o caractere da operação de soma
    jmp operacao_realizada ; avança para a realização da operação

    subtracao_op: ; início da operação de subtração
    mov bl, '-' ; define o caractere da operação de subtração
    jmp operacao_realizada ; avança para a realização da operação

    multiplicacao_op: ; início da operação de multiplicação
    mov bl, '*' ; define o caractere da operação de multiplicação
    jmp operacao_realizada ; avança para a realização da operação

    divisao_op: ; início da operação de divisão
    mov bl, '/' ; define o caractere da operação de divisão
    jmp operacao_realizada ; avança para a realização da operação

    operacao_realizada: ; início da realização da operação
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov si, offset num1 ; seleciona o número 1
    mov di, offset num2 ; seleciona o número 2
    mov bx, 10 ; define o divisor para a conversão do número ASCII em decimal
    mov cx, 4 ; define o número máximo de dígitos para os números de entrada
    mov dl, '_' ; define o caractere de preenchimento do campo de entrada
    mov ah, 1 ; seleciona a função de entrada de tecla
    call move_cursor ; chama a sub-rotina para posicionar o cursor
    input_num2: ; início do loop de entrada de número 2
    int 21h ; chama a interrupção de entrada de tecla
    cmp al, 13 ; verifica se a tecla pressionada foi ENTER
    je realizar_operacao ; se sim, avança para a realização da operação
    cmp al, '0' ; verifica se a tecla pressionada é um dígito de 0 a 9
    jb input_num2 ; se não, volta para o início do loop
    cmp al, '9'
    ja input_num2
    sub al, '0' ; converte o caractere ASCII em um número de 0 a 9
    mov ah, 0 ; seleciona a função de manipulação de bits
    mul bx ; multiplica o número atual por 10
    add ax, di ; adiciona o dígito atual ao número total
    mov di, ax ; atualiza a variável do número 2
    mov ah, 9 ; seleciona a função de saída de string
    mov dx, si ; posiciona o cursor no local da entrada
    mov al, [di] ; carrega o caractere ASCII correspondente ao número atual
    int 21h ; exibe o caractere na tela
    inc si ; move o cursor para a direita
    jmp input_num2 ; volta para o início do loop

    realizar_operacao: ; início da realização da operação
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov ax, [num1] ; carrega o número 1 na variável ax
    mov bx, [num2] ; carrega o número 2 na variável bx
    cmp bl, '+' ; verifica se a operação é de soma
    je realizar_soma ; se sim, avança para a operação de soma
    cmp bl, '-' ; verifica se a operação é de subtração
    je realizar_subtracao ; se sim, avança para a operação de subtração
    cmp bl, '*' ; verifica se a operação é de multiplicação
    je realizar_multiplicacao ; se sim, avança para a operação de multiplicação
    cmp bl, '/' ; verifica se a operação é de divisão
    je realizar_divisao ; se sim, avança para a operação de divisão
    jmp input_op ; se não, volta para a entrada de operação

    realizar_soma: ; início da operação de soma
    add ax, bx ; adiciona o número 2 ao número 1
    mov cx, ax ; salva o resultado na variável cx
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov bx, 10 ; define o divisor para a conversão do número decimal em ASCII
    mov si, offset resultado ; seleciona a variável do resultado
    mov al, '-' ; define o caractere para o sinal do resultado
    cmp ax, 0 ; verifica se o resultado é negativo
    jns resultado_positivo ; se não, avança para a exibição do resultado
    neg ax ; inverte o sinal do resultado
    mov al, '-' ; redefine o caractere para o sinal do resultado
    jmp resultado_positivo ; avança para a exibição do resultado

    realizar_subtracao: ; início da operação de subtração
    sub ax, bx ; subtrai o número 2 do número 1
    mov cx, ax ; salva o resultado na variável cx
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov bx, 10 ; define o divisor para a conversão do número decimal em ASCII
    mov si, offset resultado ; seleciona a variável do resultado
    mov al, '-' ; define o caractere para o sinal do resultado
    cmp ax, 0 ; verifica se o resultado é negativo
    jns resultado_positivo ; se não, avança para a exibição do resultado
    neg ax ; inverte o sinal do resultado
    mov al, '-' ; redefine o caractere para o sinal do resultado
    jmp resultado_positivo ; avança para a exibição do resultado

    realizar_multiplicacao: ; início da operação de multiplicação
    mul bx ; multiplica o número 1 pelo número 2
    mov cx, ax ; salva o resultado na variável cx
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov bx, 10 ; define o divisor para a conversão do número decimal em ASCII
    mov si, offset resultado ; seleciona a variável do resultado
    mov al, '-' ; define o caractere para o sinal do resultado
    cmp ax, 0 ; verifica se o resultado é negativo
    jns resultado_positivo ; se não, avança para a exibição do resultado
    neg ax ; inverte o sinal do resultado
    mov al, '-' ; redefine

    realizar_divisao: ; início da operação de divisão
    xor dx, dx ; zera o registro dx
    idiv bx ; divide o número 1 pelo número 2
    mov cx, ax ; salva o resultado na variável cx
    mov ah, 0 ; seleciona a função de manipulação de bits
    mov bx, 10 ; define o divisor para a conversão do número decimal em ASCII
    mov si, offset resultado ; seleciona a variável do resultado
    mov al, '-' ; define o caractere para o sinal do resultado
    cmp ax, 0 ; verifica se o resultado é negativo
    jns resultado_positivo ; se não, avança para a exibição do resultado
    neg ax ; inverte o sinal do resultado
    mov al, '-' ; redefine o caractere para o sinal do resultado
    jmp resultado_positivo ; avança para a exibição do resultado

    resultado_positivo: ; início da exibição do resultado positivo
    mov dx, 0 ; zera o registro dx
    mov si, offset resultado ; seleciona a variável do resultado
    mov bx, 10 ; define o divisor para a conversão do número decimal em ASCII
    div bx ; divide o resultado por 10
    add dl, 48 ; converte o resto da divisão em caractere ASCII
    push dx ; empilha o caractere ASCII na pilha
    cmp ax, 0 ; verifica se o resultado é zero
    jne resultado_positivo ; se não, avança para a próxima iteração
    mov si, offset resultado ; seleciona a variável do resultado
    exib_resultado: ; início da exibição do resultado
    pop dx ; desempilha o caractere ASCII da pilha
    mov [si], dl ; armazena o caractere ASCII na variável do resultado
    inc si ; avança para a próxima posição na variável do resultado
    cmp si, offset resultado+5 ; verifica se chegou ao fim da variável do resultado
    jne exib_resultado ; se não, avança para a próxima iteração
    mov [si], '$' ; adiciona o caractere nulo no final da variável do resultado

    fim: ; fim do programa
    mov ah, 4ch ; função para sair do programa
    int 21h ; interrupção para sair do programa
    end start ; fim do programa
