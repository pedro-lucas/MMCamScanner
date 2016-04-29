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


#import <Foundation/Foundation.h>

@class Validador_CPF_CNPJ;

@interface Validador_CPF_CNPJ : NSObject

/*
*  Método utilizado para validar um CPF
*
*  @param cpf -> CPF a ser válidado
*
*  @return NSDictionary - @{codigo:codigo_do_erro,mensagem:mensagem_do_erro}
*                         Key: codigo -> código de erro
*                         key: mensagem -> mensagem de erro
*
*  Códigos de erro:
*  1:Não possui 11 digitos
*  2:CPF não permitido: Sequencia de números
*  3:CPF inválido
*/
-(NSDictionary *)validarCPF:(NSString *)cpf;

/*
 *  Método utilizado para validar um CNPJ
 *
 *  @param CNPJ -> CPF a ser válidado
 *
 *  @return NSDictionary - @{codigo:codigo_do_erro,mensagem:mensagem_do_erro}
 *                         Key: codigo -> código de erro
 *                         key: mensagem -> mensagem de erro
 *
 *  Códigos de erro:
 *  1:Não possui 14 digitos
 *  2:CNPJ não permitido: Sequencia de números
 *  3:CNPJ inválido
 */
-(NSDictionary *)validarCNPJ:(NSString *)cnpj;

@end
