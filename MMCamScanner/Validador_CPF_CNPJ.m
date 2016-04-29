//The MIT License (MIT)
//
//Copyright (c) 2014 Guilherme Machado
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "Validador_CPF_CNPJ.h"

@implementation Validador_CPF_CNPJ : NSObject

#define codigo @"codigo"
#define mensagem @"mensagem"
#define validado @"validado"

-(NSDictionary *)validarCPF:(NSString *)cpf {

    NSDictionary *erro;
    
    int retornoVerificarComuns = [self verificarComunsCPF:cpf];
    
    switch (retornoVerificarComuns) {
        
        case 0:
        {
            BOOL retornoValidarDigitos = [self validarDigitosCPF:cpf];
            
            if (retornoValidarDigitos == NO) {
                erro = @{codigo: @3,mensagem: @"CPF inválido."};
            }
            
        }
        break;
            
        case 1:
            erro = @{codigo: @1,mensagem: @"CPF não possui 11 digitos."};
        break;
        
        case 2:
            erro = @{codigo: @2,mensagem: @"CPF não permitido."};
        break;
            
        default:
        break;
    }
    return erro;
}

-(int)verificarComunsCPF:(NSString *)cpf {
/*
0 - Validado
1 - Não possui 11 digitos
2 - CPF não permitido: Sequencia de números
*/
    if ([cpf length] != 11 || [cpf isEqualToString:@""]) {
        return 1;
    } else if (   [cpf isEqualToString:@"00000000000"]
               || [cpf isEqualToString:@"11111111111"]
               || [cpf isEqualToString:@"22222222222"]
               || [cpf isEqualToString:@"33333333333"]
               || [cpf isEqualToString:@"44444444444"]
               || [cpf isEqualToString:@"55555555555"]
               || [cpf isEqualToString:@"66666666666"]
               || [cpf isEqualToString:@"77777777777"]
               || [cpf isEqualToString:@"88888888888"]
               || [cpf isEqualToString:@"99999999999"]){
        return 2;
    }
    else{
        return 0;
    }
}

-(BOOL)validarDigitosCPF:(NSString *)cpf {
    
    NSInteger soma = 0;
    NSInteger peso;
    NSInteger digito_verificador_10 = [[cpf substringWithRange:NSMakeRange(9, 1)] integerValue];
    NSInteger digito_verificador_11 = [[cpf substringWithRange:NSMakeRange(10, 1)] integerValue];
    NSInteger digito_verificador_10_correto;
    NSInteger digito_verificador_11_correto;

    //Verificação 10 Digito
    peso=10;
    for (int i=0; i<9; i++) {
        soma = soma + ( [[cpf substringWithRange:NSMakeRange(i, 1)] integerValue] * peso );
        peso = peso-1;
    }
    
    if (soma % 11 < 2) {
        digito_verificador_10_correto = 0;
    }else{
        digito_verificador_10_correto = 11 - (soma % 11);
    }

    //Verifição 11 Digito
    soma=0;
    peso=11;
    for (int i=0; i<10; i++) {
        soma = soma + ( [[cpf substringWithRange:NSMakeRange(i, 1)] integerValue] * peso );
        peso = peso-1;
    }
    
    if (soma % 11 < 2) {
        digito_verificador_11_correto = 0;
    }else{
        digito_verificador_11_correto = 11 - (soma % 11);
    }

    //Retorno
    if (digito_verificador_10_correto == digito_verificador_10 && digito_verificador_11_correto == digito_verificador_11) {
        return YES;
    }
    else{
        return NO;
    }
    
}

-(NSDictionary *)validarCNPJ:(NSString *)cnpj {

    NSDictionary *erro;
    
    int retornoVerificarComuns = [self verificarComunsCNPJ:cnpj];
    
    switch (retornoVerificarComuns) {
            
        case 0:
        {
            BOOL retornoValidarDigitos = [self validarDigitosCNPJ:cnpj];
            
            if (retornoValidarDigitos == NO) {
                erro = @{codigo: @3,mensagem: @"CNPJ inválido."};
            }
            
        }
            break;
            
        case 1:
            erro = @{codigo: @1,mensagem: @"CNPJ não possui 14 digitos."};
            break;
            
        case 2:
            erro = @{codigo: @2,mensagem: @"CNPJ não permitido."};
            break;
            
        default:
            break;
    }
    return erro;
}

-(BOOL)validarDigitosCNPJ:(NSString *)cnpj {
    
    NSInteger soma = 0;
    NSInteger peso;
    NSInteger digito_verificador_13 = [[cnpj substringWithRange:NSMakeRange(12, 1)] integerValue];
    NSInteger digito_verificador_14 = [[cnpj substringWithRange:NSMakeRange(13, 1)] integerValue];
    NSInteger digito_verificador_13_correto;
    NSInteger digito_verificador_14_correto;
    
    //Verificação 13 Digito
    peso=2;
    for (int i=11; i>=0; i--) {
        
        soma = soma + ( [[cnpj substringWithRange:NSMakeRange(i, 1)] integerValue] * peso);
        
        peso = peso+1;
        
        if (peso == 10) {
            peso = 2;
        }
    }
    
    if (soma % 11 == 0 || soma % 11 == 1) {
        digito_verificador_13_correto = 0;
    }
    else{
        digito_verificador_13_correto = 11 - soma % 11;
    }
    
    //Verificação 14 Digito
    soma=0;
    peso=2;
    for (int i=12; i>=0; i--) {
        
        soma = soma + ( [[cnpj substringWithRange:NSMakeRange(i, 1)] integerValue] * peso);
        
        peso = peso+1;
        
        if (peso == 10) {
            peso = 2;
        }
    }

    if (soma % 11 == 0 || soma % 11 == 1) {
        digito_verificador_14_correto = 0;
    }
    else{
        digito_verificador_14_correto = 11 - soma % 11;
    }
    
    //Retorno
    if (digito_verificador_13_correto == digito_verificador_13 && digito_verificador_14_correto == digito_verificador_14) {
        return YES;
    }
    else{
        return NO;
    }

}

-(int)verificarComunsCNPJ:(NSString *)cnpj {
/*
0 - Validado
1 - Não possui 14 digitos
2 - CNPJ não permitido: Sequencia de números
*/
    if ([cnpj length] != 14 || [cnpj isEqualToString:@""]) {
        return 1;
    } else if (   [cnpj isEqualToString:@"00000000000000"]
               || [cnpj isEqualToString:@"11111111111111"]
               || [cnpj isEqualToString:@"22222222222222"]
               || [cnpj isEqualToString:@"33333333333333"]
               || [cnpj isEqualToString:@"44444444444444"]
               || [cnpj isEqualToString:@"55555555555555"]
               || [cnpj isEqualToString:@"66666666666666"]
               || [cnpj isEqualToString:@"77777777777777"]
               || [cnpj isEqualToString:@"88888888888888"]
               || [cnpj isEqualToString:@"99999999999999"]){
        return 2;
    }
    else{
        return 0;
    }
}

@end
