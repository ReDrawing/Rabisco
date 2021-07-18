Este arquivo de texto demonstra o passo a passo para executar o projeto ReDrawing.
- Clonar este repositório, Rabisco
- Clonar o repositório redrawing que contem os arquivos de modelos utilizados em python, https://github.com/ReDrawing/redrawing, branch devel.

- Pelo terminal, abra o diretório redrawing com os modelos.
- Baixe todos os pacotes necessário com o pip.
- Navegue até a pasta src.
- Execute o arquivo de testes apropriado, EX.: python .\test_blazepose.py.
	- Para o teste somente do modelo de esqueleto, execute o arquivo test_blazepose.py
	- Para o teste do sistema completo com os gestos, execute o arquivo test_hand_body.py

- Dentro do diretório do Rabisco abrir o arquivos Redrawing.pde.
	- A variável enableMouseControl habilita a interação com o mouse.
	- Apertar o botão de play no canto superior esquerdo.

- O sistema abrirá um nova janela em branco.
- Nesta janela no canto superior esquerdo são apresentadas a face atual e o modo de traço atual.
- O sistema começa com o modo de desenho livre, onde a posição da mão direita controla o traço.
- Quando ambas as mão forem levantadas, o sistema entra no modo de edição, onde são identificados os gestos para controlar os parâmetros do sistema, rotação do cubo e tipo do traço.
- No modo de edição, um comando é identificado quando um mesmo gesto é feito por 5 segundos com a mão direita. Após o comando ser identificado o sistema retorna ao modo de desenho.
