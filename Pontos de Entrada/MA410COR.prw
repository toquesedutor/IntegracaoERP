#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410COR  � Autor � JONATAS C. ALMEIDA � Data �  11/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao � P.E.: Alteracao de cores atraves do status do pedido de    ���
���          � venda                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � TOQUESEDUTOR                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA410COR()
//���������������������������������������������������������������������Ŀ
//� Exemplo de acores retirado do site da TOTVS...                      �
//�����������������������������������������������������������������������
//aCores := { {"Empty(C5_LIBEROK).And.Empty(C5_NOTA)" ,"ENABLE"    },;  //Pedido em Aberto            
//{"!Empty(C5_NOTA).Or.C5_LIBEROK=='E'"   ,"DISABLE"   },;  //Pedido Encerrado            
//{"!Empty(C5_LIBEROK).And.Empty(C5_NOTA)","BR_AMARELO"} }  //Pedido Liberado

aCores := {	{"(C5_TSSTATU == 'C')","BR_VERMELHO","Cancelado"			},;
			{"(C5_TSSTATU == 'A')","BR_LARANJA","Aguardando Pagamento"	},;
			{"(C5_TSSTATU == 'L')","BR_VERDE","Liberado para Entrega"	},;
			{"(C5_TSSTATU == 'O')","BR_AZUL","Completo"					}}
Return aCores

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA410LEG  � Autor � JONATAS C. ALMEIDA � Data �  11/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao � P.E.: Descricao da legenda do pedido de venda              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TOQUESEDUTOR                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MA410LEG()
//���������������������������������������������������������������������Ŀ
//� Exemplo de acores retirado do site da TOTVS...                      �
//�����������������������������������������������������������������������
//aLegenda := { {'ENABLE'    ,�Pedido em aberto�},;              
//{'DISABLE'   ,"Pedido encerrado"},;
//{'BR_AMARELO',�Pedido Liberado� } }

aLegenda := {	{'BR_VERMELHO'	,'Pedidos Cancelados'				},;
				{'BR_LARANJA'	,'Pedidos Aguardando Pagamento'		},;
				{'BR_VERDE'		,'Pedidos Liberados para Entrega'	},;
				{'BR_AZUL'		,'Pedidos Completos'				}}
Return aLegenda 