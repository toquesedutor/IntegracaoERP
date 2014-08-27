// #########################################################################################
// Projeto: Loja ToqueSedutor
// Modulo : Faturamento
// Fonte  : TSWSMG01.PRW
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 13/11/12 | JONATAS C ALMEIDA | Lista metodos para consumo do WebServices Magento
// ---------+-------------------+-----------------------------------------------------------
#DEFINE COMPLETA		1
#DEFINE COMPLEMENTAR	2
#DEFINE INCLUI			3
#DEFINE ALTERA			4

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSWSMG01
Lista metodos para consumo do WebServices Magento.

@author    JONATAS ALMEIDA
@version   1.0
@since     30/09/2013

//--< FUNCIONALIDADE PARA CLIENTES >--------------------------------------------------------
//_aCliente := U_TSCLIINF(_nCod)								//-> Obtem informacoes de um cliente em especifico
//_aListCli	:= U_TSLSTCLI()									//-> Obtem lista de clientes da loja
//Processa({|| U_TSGRVCLI(_aListCli)}, "Aguarde...","Efetuando a gravação dos clientes...",.F.)	//-> Grava lista de clientes nao existentes no Protheus

//--< FUNCIONALIDADE PARA PRODUTOS >--------------------------------------------------------
//_aProd := U_TSPRODUT('00420','toquesedutor_visao','sku')	//-> Retorna produto especifico
//_aListPrd := U_TSLSTPRD()									//-> Retorna toda lista de produtos
//Processa({|| U_TSGRVPRD(_aListPrd)},"Aguarde...","Efetuando a gravação de produtos...",.F.)

//--< FUNCIONALIDADE PARA VENDAS >----------------------------------------------------------
//_aListPed := U_TSLSTPED()									//-> Retorna toda lista de pedidos
//Processa({|| U_TSGRVPED(_aListPed)},"Aguarde...","Efetuando a gravação dos pedidos de venda...",.F.)
/*/
//------------------------------------------------------------------------------------------
User Function TSWSMG01()
Static _oWsTs
Static _sessionID

Private _aProd		:= {}
Private _aOldLPrd	:= {}
Private _aListPrd	:= {}
//Private _aListCli	:= {}
Private _aCliente	:= {}

//_oWsTs		:= WSMagentoService():New()
//_sessionID	:= U_TSCONNEC()								//-> Abre conexao com Magento
//_aListCli		:= U_TSLSTCLI()								//-> Obtem lista de clientes da loja
//_oWsTs:endSession(_sessionID)								//-> Encerra conexao com Magento
Public _nTipoAtu
 
if(upper(allTrim(FunName())) == 'TSWSMG01')
	_nTipoAtu := TipoAtu()
	Conout('***TSWSMG01***')
else
	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'
	_nTipoAtu := COMPLEMENTAR
	Conout('***SCHEDULE***')
endIf

if(_nTipoAtu == COMPLETA .OR. _nTipoAtu == COMPLEMENTAR)
	Processa({|| _oWsTs := WSMagentoService():New()}, "Aguarde...","Efetuando conexão com e-commerce",.F.)
	Processa({|| _sessionID	:= U_TSCONNEC()}, "Aguarde...","Processo de autenticação",.F.)						//-> Abre conexao com Magento
	
	U_TSIMPPRO()
	U_TSIMPCLI()
	U_TSIMPPED()
	
	Processa({|| _oWsTs:endSession(_sessionID)}, "Aguarde...","Encerrando conexão com e-commerce"		,.F.)	//-> Encerra conexao com Magento
	
	if(upper(allTrim(FunName())) == 'TSWSMG01')
		msgInfo('Importação de dados efetuada com sucesso!','Sucesso')
	endIf
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TIPOATU
Da opcao de escolha para o usuario definir qual o tipo de atualizacao desejado

@author    JONATAS ALMEIDA
@version   1.0
@since     07/01/2014
/*/
//------------------------------------------------------------------------------------------
Static Function TipoAtu()
Local aRet		:= {}
Local aCombo	:= {" ","Completa","Complementar"}
Local aParamBox	:= {}
Local _nTipoAtu	:= 0

aadd(aParamBox,{2,"Informe o tipo de atualização",1,aCombo,50,.F.,.T.})

if(ParamBox(aParamBox,"Importação de dados - TOQUESEDUTOR",@aRet))
	for i:=1 To Len(aRet)
		If(upper(alltrim(aRet[i])) == "COMPLETA")
			_nTipoAtu	:= 1
		elseIf(upper(alltrim(aRet[i])) == "COMPLEMENTAR")
			_nTipoAtu	:= 2
		else
			alert('É necessário informar um tipo de atualização (Completa ou Complementar)')
			TipoAtu()
		endIf
	next
endIf
Return _nTipoAtu

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSIMPPRO
Efetua importacao dos produtos do e-commerce para o ERP.

@author    JONATAS ALMEIDA
@version   1.0
@since     30/09/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSIMPPRO()
Static _oWsTs
Static _sessionID

Private _aListPrd := {}

//Processa({|| _oWsTs := WSMagentoService():New()}, "Aguarde...","Efetuando conexão com e-commerce",.F.)
//Processa({|| _sessionID	:= U_TSCONNEC()}, "Aguarde...","Processo de autenticação",.F.)						//-> Abre conexao com Magento

//_aProd := U_TSPRODUT('00420','toquesedutor_visao','sku')													//-> Retorna produto especifico
_aListPrd := U_TSLSTPRD()																					//-> Retorna toda lista de produtos
//_cUPrdCad := strZero(val(_aListPrd[len(_aListPrd)]:CPRODUCT_ID),15)										//-> Ultimo produto cadastrado no e-commerce

//SB1->(dbSetOrder(1))
//if(SB1->(dbseek(xFilial('SB1')+_cUPrdCad)))
//	Processa({|| _oWsTs:endSession(_sessionID)}, "Aguarde...","Encerrando conexão com e-commerce",.F.)		//-> Encerra conexao com Magento
//	msgInfo('Nenhum novo produto a ser cadastrado','Sucesso')
//else
Processa({|| U_TSGRVPRD(_aListPrd)},"Aguarde...","Efetuando a gravação de produtos...",.F.)			//-> Grava lista de produtos
//	Processa({|| _oWsTs:endSession(_sessionID)}, "Aguarde...","Encerrando conexão com e-commerce",.F.)		//-> Encerra conexao com Magento
//	msgInfo('Gravação dos produtos efetuada com sucesso!','Sucesso')
//endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSIMPCLI
Efetua importacao dos Clientes do e-commerce para o ERP.

@author    JONATAS ALMEIDA
@version   1.0
@since     30/09/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSIMPCLI()
//Static _oWsTs
//Static _sessionID

Private _aListCli := {}

//Processa({|| _oWsTs := WSMagentoService():New()}, "Aguarde...","Efetuando conexão com e-commerce",.F.)	//-> Cria uma nova instancia WebServices com Magento
//Processa({|| _sessionID	:= U_TSCONNEC()}, "Aguarde...","Processo de autenticação",.F.)						//-> Abre conexao com Magento (autenticacao)

//_aCliente := U_TSCLIINF(766)					 															//-> Obtem informacoes de um cliente em especifico
Processa({|| _aListCli := U_TSLSTCLI()}, "Aguarde...","Obtendo lista de clientes",.F.)						//-> Obtem lista de clientes da loja
Processa({|| U_TSGRVCLI(_aListCli)}, "Aguarde...","Efetuando a gravação dos clientes",.F.)					//-> Grava lista de clientes nao existentes no Protheus
//Processa({|| _oWsTs:endSession(_sessionID)}, "Aguarde...","Encerrando conexão com e-commerce",.F.)			//-> Encerra conexao com Magento
//MsgInfo('Importação de lista de clientes finalizada!','Sucesso')
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSIMPPED
Efetua importacao dos Pedidos de Venda do e-commerce para o ERP.

@author    JONATAS ALMEIDA
@version   1.0
@since     30/09/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSIMPPED()
//Static _oWsTs
//Static _sessionID

Private _aListPed := {}

//Processa({|| _oWsTs := WSMagentoService():New()}, "Aguarde...","Efetuando conexão com e-commerce"	,.F.)	//-> Cria uma nova instancia WebServices com Magento
//Processa({|| _sessionID	:= U_TSCONNEC()}, "Aguarde...","Processo de autenticação"				,.F.)	//-> Abre conexao com Magento (autenticacao)

Processa({|| _aListPed := U_TSLSTPED()},"Aguarde...","Obtendo lista de pedidos de venda..."		,.F.)	//-> Retorna toda lista de pedidos
Processa({|| U_TSGRVPED(_aListPed)},"Aguarde...","Efetuando a gravação dos pedidos de venda..."	,.F.)	//-> Grava lista de pedidos de venda
//Processa({|| _oWsTs:endSession(_sessionID)}, "Aguarde...","Encerrando conexão com e-commerce"		,.F.)	//-> Encerra conexao com Magento

//msgInfo('Importação de pedidos efetuada com Sucesso!','Sucesso')
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSCONNEC
Abre conexao com Magento e retorna a session ID.

@author    JONATAS ALMEIDA
@version   1.0
@since     30/09/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSCONNEC()
Private _cUserName := GETMV('MV_TSWSUSR')
Private _cPassWord := GETMV('MV_TSWSPWD')

//--< START THE API SESSION, RETURN THE SESSION ID, AND AUTHORIZE THE API USER >------------
_oWsTs:login(_cUserName,_cPassWord)
Return _oWsTs:cLoginReturn

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGRVCLI
Grava lista de clientes da loja no Protheus.

@author    JONATAS ALMEIDA
@version   1.0
@since     10/05/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSGRVCLI(_aListCli)
Local aVetor		:= {}
Private lMsErroAuto	:= .F.

SA1->(dbOrderNickName('SA1REF'))

ProcRegua(RecCount())

for nx := 1 to len(_aListCli)
	IncProc('Processando importação do Cliente N.: ' + allTrim(str(_aListCli[nx]:NCUSTOMER_ID)))
	
	iif(SA1->(!dbSeek(xFilial('SA1')+allTrim(str(_aListCli[nx]:NCUSTOMER_ID)))),_nOpc := INCLUI,_nOpc := ALTERA)
	
	if(_nOpc == ALTERA .and. _nTipoAtu == COMPLEMENTAR)
		loop
	endIf
	
	//--< OBTEM OS DADOS DE ENDERECO DO CLIENTE >-------------------------------------------
	_oWsTs:customerAddressList(_sessionID,_aListCli[nx]:NCUSTOMER_ID)
	
	if(_oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM[1]:NCUSTOMER_ADDRESS_ID == NIL)
		aVetor := {	{"A1_COD"       ,strZero(_aListCli[nx]:NCUSTOMER_ID,6)							,Nil},; // Codigo
					{"A1_LOJA"      ,"01"															,Nil},; // Loja
					{"A1_NOME"      ,upper(allTrim(_aListCli[nx]:CFIRSTNAME)) + " " +;
										upper(allTrim(_aListCli[nx]:CLASTNAME))						,Nil},; // Nome
					{"A1_NREDUZ"    ,upper(allTrim(_aListCli[nx]:CFIRSTNAME))						,Nil},; // Nome reduz.
					{"A1_TIPO"      ,'F'															,Nil},; // Tipo
					{"A1_END"		,'SEM ENDERECO CADASTRADO'										,Nil},; // Endereco
					{"A1_MUN"		,'SEM CIDADE'													,Nil},; // Cidade
					{"A1_EST"		,'AC'		 													,Nil},; // Estado
					{"A1_CEP"		,'99999999'														,Nil},; // CEP
					{"A1_TSREFLJ"	,_aListCli[nx]:NCUSTOMER_ID										,Nil},; // Codigo Loja
					{"A1_EMAIL"		,lower(allTrim(_aListCli[nx]:CEMAIL))							,Nil},; // email
					{"A1_DTNASC"	,iif(_aListCli[nx]:CDOB <> NIL,StoD(replace(subStr(_aListCli[nx]:CDOB,1,10),"-","")),StoD("  /  /  "))			,Nil},;	// Data de Nascimento
					{"A1_TSDTCAD"	,StoD(replace(subStr(_aListCli[nx]:CCREATED_AT,1,10),"-",""))	,Nil}}	// Data de Cadastro
		
		_nTotEnd	:= 0
	else
		_cCep := U_TSTRATACEP(allTrim(_oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM[1]:CPOSTCODE))
		
		aVetor := {	{"A1_COD"       ,strZero(_aListCli[nx]:NCUSTOMER_ID,6)							,Nil},; // Codigo
					{"A1_LOJA"      ,"01"															,Nil},; // Loja
					{"A1_NOME"      ,upper(allTrim(_aListCli[nx]:CFIRSTNAME)) + " " +;
										upper(allTrim(_aListCli[nx]:CLASTNAME))						,Nil},; // Nome
					{"A1_NREDUZ"    ,upper(allTrim(_aListCli[nx]:CFIRSTNAME))						,Nil},; // Nome reduz.
					{"A1_TIPO"      ,'F'															,Nil},; // Tipo
					{"A1_END"		,upper(allTrim(_oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM[1]:CSTREET)),Nil},; // Endereco
					{"A1_MUN"		,upper(allTrim(_oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM[1]:CCITY)),Nil},; // Cidade
					{"A1_EST"		,U_TSIDESTADO(allTrim(upper(_oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM[1]:CCITY))),Nil},; // Estado
					{"A1_CEP"		,iif(len(allTrim(_cCep)) > 0,_cCep,'99999999')					,Nil},; // CEP
					{"A1_TSREFLJ"	,_aListCli[nx]:NCUSTOMER_ID										,Nil},; // Codigo Loja
					{"A1_EMAIL"		,lower(allTrim(_aListCli[nx]:CEMAIL))							,Nil},; // email
					{"A1_DTNASC"	,iif(_aListCli[nx]:CDOB <> NIL,StoD(replace(subStr(_aListCli[nx]:CDOB,1,10),"-","")),StoD("  /  /  ")),Nil},;	// Data de Nascimento
					{"A1_TSDTCAD"	,StoD(replace(subStr(_aListCli[nx]:CCREATED_AT,1,10),"-",""))	,Nil}}	// Data de Cadastro
		
		_aEnderecos	:= _oWsTs:oWScustomerAddressListresult:OWSCUSTOMERADDRESSENTITYITEM
		_nTotEnd	:= len(_aEnderecos)
	endIf
	
	msExecAuto({|x,y| Mata030(x,y)},aVetor,_nOpc) //3- Inclusão, 4- Alteração, 5- Exclusão
	
	if(lMsErroAuto)
		mostraErro()
	endif
	
	//--< TRATAMENTO DE CEP >----------------------------------------------------
	if(_nTotEnd > 1 .and. !lMsErroAuto)
		TSGRVEND()
	endIf
next nx
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGRVEND
Grava endereço dos clientes

@author    JONATAS ALMEIDA
@version   1.0
@since     19/12/2013
/*/
//------------------------------------------------------------------------------------------
Static Function TSGRVEND()
if(_nOpc == INCLUI)
	//--< CRIA AMARRACAO DAS ENTIDADES DO CONTATO X CLIENTE >-----------------------
	_cContato := GetSXENum('SU5','U5_CODCONT')
	
	RecLock('AC8',.T.)
	AC8->AC8_FILIAL := xFilial('AC8')
	AC8->AC8_ENTIDA := 'SA1'
	AC8->AC8_CODENT	:= allTrim(strZero(_aListCli[nx]:NCUSTOMER_ID,6)) + '01'
	AC8->AC8_CODCON	:= _cContato
	AC8->(MsUnLock())
	
	//--< CRIA UM NOVO CONTATO >----------------------------------------------------
	SU5->(dbSetOrder(1)) //-> SU5_FILIAL + SU5_CODCONT
	RecLock('SU5',.T.)
	SU5->U5_FILIAL	:= xFilial('SU5')
	SU5->U5_CODCONT	:= _cContato
	SU5->U5_CONTAT	:= SA1->A1_NOME
	SU5->U5_EMAIL	:= SA1->A1_EMAIL
	SU5->U5_END		:= SA1->A1_END
	SU5->U5_EST		:= SA1->A1_EST
	SU5->U5_BAIRRO	:= SA1->A1_BAIRRO
	SU5->U5_CEP		:= SA1->A1_CEP
	SU5->(MsUnLock())
	
	SU5->(ConfirmSX8())
	
	AGA->(dbSetOrder(1))
	for nz := 2 to _nTotEnd
		//--< GRAVA ENDERECOS ADICIONAIS >-------------------------------------
		_cCodEnd := GetSXENum('AGA','AGA_CODIGO')
		
		RecLock('AGA',.T.)
		AGA->AGA_CODIGO	:= _cCodEnd
		AGA->AGA_ENTIDA	:= 'SU5'
		AGA->AGA_CODENT	:= _cContato
		AGA->AGA_TIPO	:= '1'
		AGA->AGA_END	:= upper(allTrim(_aEnderecos[nz]:CSTREET))
		AGA->AGA_MUNDES	:= upper(allTrim(_aEnderecos[nz]:CCITY))
		AGA->AGA_CEP	:= U_TSTRATACEP(allTrim(_aEnderecos[nz]:CPOSTCODE))
		AGA->AGA_TSECOB	:= iif(_aEnderecos[nz]:LIS_DEFAULT_BILLING,'S','N')
		AGA->AGA_TSEENT	:= iif(_aEnderecos[nz]:LIS_DEFAULT_SHIPPING,'S','N')
		AGA->(MsUnLock())
		
		AGA->(ConfirmSX8())
	next nz
elseIf(_nOpc == ALTERA)
	//--< ATUALIZA CONTATO >---------------------------------------------------
	SU5->(dbSetOrder(1)) //-> SU5_FILIAL + SU5_CODCONT
	if(SU5->(dbseek(xFilial('SU5')+Posicione('AC8',2,xFilial('AC8') + 'SA1' + '  ' + SA1->A1_COD + SA1->A1_LOJA,'AC8_CODCON'))))
		RecLock('SU5',.F.)
		SU5->U5_CONTAT	:= SA1->A1_NOME
		SU5->U5_EMAIL	:= SA1->A1_EMAIL
		SU5->U5_END		:= SA1->A1_END
		SU5->U5_EST		:= SA1->A1_EST
		SU5->U5_BAIRRO	:= SA1->A1_BAIRRO
		SU5->U5_CEP		:= SA1->A1_CEP
		SU5->(MsUnLock())
	endIf
	
	//--< AUTALIZA ENDERECOS ADICIONAIS >-------------------------------------
	AGA->(dbSetOrder(1))
	if(AGA->(dbseek(xFilial('AGA') + 'SU5' + SU5->U5_CODCONT + '1' /*Comercial,Residencial*/)))
		for nz := 2 to _nTotEnd
			RecLock('AGA',.F.)
			AGA->AGA_END	:= upper(allTrim(_aEnderecos[nz]:CSTREET))
			AGA->AGA_MUNDES	:= upper(allTrim(_aEnderecos[nz]:CCITY))
			AGA->AGA_CEP	:= U_TSTRATACEP(allTrim(_aEnderecos[nz]:CPOSTCODE))
			AGA->AGA_TSECOB	:= iif(_aEnderecos[nz]:LIS_DEFAULT_BILLING,'S','N')
			AGA->AGA_TSEENT	:= iif(_aEnderecos[nz]:LIS_DEFAULT_SHIPPING,'S','N')
			AGA->(MsUnLock())
		next nz
	endIf
endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSCLIINF
Obtem informacoes de um cliente em especifico

@author    JONATAS ALMEIDA
@version   1.0
@since     10/05/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSCLIINF(_nCodCli)
Local _aCli := {}
Local lRet := .F.

lRet := _oWsTs:customerCustomerInfo(_sessionID,_nCodCli)

if(lRet)
	_aCli := _oWsTs:OWSCUSTOMERCUSTOMERINFOCUSTOMERINFO
else
	alert('Não foi possível obter a lista e clientes!')
endIf
Return _aCli

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSPRODUT
Obtem lista de clientes da loja 

@author    JONATAS ALMEIDA
@version   1.0
@since     10/05/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSLSTCLI()
Local _aCli := {}
Local lRet := .F.

lRet := _oWsTs:customerCustomerList(_sessionID)

if(lRet)
	_aCli := _oWsTs:OWSCUSTOMERCUSTOMERLISTSTOREVIEW:OWSCUSTOMERCUSTOMERENTITY
else
	alert('Não foi possível obter a lista e clientes!')
endIf
Return _aCli

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSPRODUT
Retorna um produto especifico do e-commerce

@author    JONATAS ALMEIDA
@version   1.0
@since     13/11/2012
/*/
//------------------------------------------------------------------------------------------
User Function TSPRODUT(_cSKUProd,_cVisLoja,_cIdType)
Local lRet := .F.
Private _aInfoProd := {}

lRet := _oWsTs:catalogProductInfo(_sessionID,_cSKUProd,_cVisLoja,,_cIdType)

if(lRet)
	_aInfoProd := _oWsTs:oWScatalogProductInfoinfo
else
	alert('Não foi possível obter os dados do produto: ' + _cSKUProd + '.')
endIf
Return _aInfoProd

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSLSTPRD
Retorna toda lista de produtos cadastrados no Magento

@author    JONATAS ALMEIDA
@version   1.0
@since     14/11/2012
/*/
//------------------------------------------------------------------------------------------
User Function TSLSTPRD()
Local lRet			:= .F.
Private _aListProd	:= {}

lRet := _oWsTs:catalogProductList(_sessionID,,'toquesedutor_visao')

if(lRet)
	_aListProd := _oWsTs:OWSCATALOGPRODUCTLISTSTOREVIEW:OWSCATALOGPRODUCTENTITY
else
	alert('Não foi possível obter a lista de produtos.')
endIf
Return _aListProd

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGRVPRD
Grava os produtos da loja ainda nao cadastrados no Protheus

@author    JONATAS ALMEIDA
@version   1.0
@since     08/05/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSGRVPRD(_aListPrd)
Local _aNewLstPrd := {}
Local _nCount := 1
Local _lFound

SB1->(dbOrderNickName('SB1SKU'))

for nx:=1 to len(_aListPrd)
	IncProc('Processando importação do Produto N.: ' + allTrim(_aListPrd[nx]:CSKU))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica tipo de gravacao                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	iif(SB1->(dbSeek(xFilial('SB1')+allTrim(_aListPrd[nx]:CSKU))),_lFound:=.T.,_lFound:=.F.)
	
	if(_lFound .and. _nTipoAtu == COMPLEMENTAR)
		aadd(_aNewLstPrd,{})
		loop
	else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem a lista completa de produtos da loja para cadastro no Protheus ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(_aNewLstPrd,U_TSPRODUT(_aListPrd[nx]:CSKU,'toquesedutor_visao','sku'))
	endIf
	
	aVetor:=	{	{"B1_COD"		,strZero(val(_aNewLstPrd[nx]:CPRODUCT_ID),15)		,NIL},;
					{"B1_DESC"		,upper(allTrim(_aNewLstPrd[nx]:CNAME))				,NIL},;
					{"B1_TIPO"		,"ME"												,Nil},;
					{"B1_UM"		,"UN"												,Nil},;
					{"B1_LOCPAD"	,superGetMV('MV_TSLOCPA',.F.,'01')					,Nil},;
					{"B1_PICM"		,0													,Nil},;
					{"B1_IPI"		,0													,Nil},;
					{"B1_CONTRAT"	,"N"												,Nil},;
					{"B1_LOCALIZ"	,"N"												,Nil},;
					{"B1_TSBRVDS"	,allTrim(_aNewLstPrd[nx]:CSHORT_DESCRIPTION)		,Nil},;
					{"B1_TSSKU"		,allTrim(_aNewLstPrd[nx]:CSKU)						,Nil},;
					{"B1_PRV1"		,iif(_aNewLstPrd[nx]:CSPECIAL_PRICE <> NIL,val(_aNewLstPrd[nx]:CSPECIAL_PRICE),val(_aNewLstPrd[nx]:CPRICE)),Nil},;
					{"B1_TSPRECO"	,iif(_aNewLstPrd[nx]:CPRICE <> NIL,val(_aNewLstPrd[nx]:CPRICE),0),Nil},;
					{"B1_PESO"		,iif(_aNewLstPrd[nx]:CWEIGHT <> NIL,val(_aNewLstPrd[nx]:CWEIGHT),0),Nil},;
					{"B1_MSBLQL"	,'2'												,Nil},;
					{"B1_DATREF"	,StoD(replace(subStr(_aNewLstPrd[nx]:CCREATED_AT,1,10),"-","")),Nil},;
					{"B1_TSURLPA"	,allTrim(_aNewLstPrd[nx]:CURL_PATH)					,Nil}}

	//				{"B1_MSBLQL"	,if(allTrim(_aNewLstPrd[nx]:CSTATUS) == '1','2','1'),Nil},;
	//				{"B1_UPRC"		,iif(_aNewLstPrd[nx]:COST <> NIL,val(_aNewLstPrd[nx]:COST),0),Nil},;
	lMsErroAuto := MSExecAuto({|x,y| Mata010(x,y)},aVetor,iif(_lFound,ALTERA,INCLUI))
	
	if!(lMsErroAuto)
		mostraErro()
	endIf
next nx
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSLSTPED
Retorna toda lista dos numeros dos pedidos efetuados na loja

@author    JONATAS ALMEIDA
@version   1.0
@since     10/05/2013
/*/
//------------------------------------------------------------------------------------------

User Function TSLSTPED()
Local lRet := .F.
Local lRet2 := .F.
Private _aListPed := {}

lRet := _oWsTs:salesOrderList(_sessionID,'')

if(lRet)
	_aPed := _oWsTs:OWSSALESORDERLISTRESULT:OWSSALESORDERLISTENTITY
	
	for nx:=1 to len(_aPed)
		lRet2 := _oWsTs:salesOrderInfo(_sessionID,_aPed[nx]:CINCREMENT_ID)
		
		if(lRet2)
			aadd(_aListPed,_oWsTs:OWSSALESORDERINFORESULT)
		endIf
	next nx
else
	alert('Não foi possível obter a lista de pedidos de venda da loja.')
endIf
Return _aListPed

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGRVPED
Retorna toda lista de pedidos de venda efetuados atraves do Magento

@author    JONATAS ALMEIDA
@version   1.0
@since     14/11/2012
/*/
//------------------------------------------------------------------------------------------
User Function TSGRVPED(_aListPed)
Local aParam460	:= Array(30)
Local _cStatus	:= ''
Local _cNumPed	:= ''

SC5->(dbOrderNickName('SC5PEDLOJA'))

ProcRegua(RecCount())

for nx:=1 to len(_aListPed)
	IncProc('Processando importação do Pedido de Venda N.: ' +  allTrim(_aListPed[nx]:CINCREMENT_ID))
	
	if(SC5->(dbSeek(xFilial("SC5")+allTrim(_aListPed[nx]:CINCREMENT_ID))))		//-> Numero do Pedido
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Identifica status do pedido de venda                         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if(allTrim(_aListPed[nx]:CSTATUS) == 'canceled')
			_cStatus := "C"										//-> CANCELADO
		elseif(allTrim(_aListPed[nx]:CSTATUS) == 'pending' .or. lower(allTrim(_aListPed[nx]:CSTATUS)) == 'holded')
			_cStatus := "A"										//-> AGUARDANDO PAGAMENTO
		elseif(allTrim(_aListPed[nx]:CSTATUS) == 'processing')
			_cStatus := "L"										//-> LIBERADO PARA ENTREGA
		elseif(allTrim(_aListPed[nx]:CSTATUS) == 'complete')
			_cStatus := "O"										//-> COMPLETO
		else
			_cStatus := "X"										//-> DESCONHECIDO
		endIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Atualiza pedido de venda                                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if(_cStatus <> SC5->C5_TSSTATU)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| * Fatura Pedido de venda                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if(_cStatus $ 'O|L')
				RecLock('SC5',.F.)
				SC5->C5_TSSTATU	:= _cStatus
				
				if(_cStatus == 'O')
					SC5->C5_LIBEROK := 'S'
					//SC5->C5_TSRASTR := 
				endIf
				
				SC5->(msUnLock())
				
				TSFATURA()
			elseIf(_cStatus == 'C')
				RecLock('SC5',.F.)
				SC5->C5_TSSTATU	:= _cStatus
				SC5->C5_BLQ		:= '1'
				SC5->(msUnLock())
			else
				RecLock('SC5',.F.)
				SC5->C5_TSSTATU	:= _cStatus
				SC5->(msUnLock())
			endIf
		endIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Ignora os pedidos de venda ja existentes                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		loop
	endIf
	
	aCabec 		:= {}
	aItens		:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Tratamento para clientes nao existentes                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(dbOrderNickName('SA1REF'))

	if(SA1->(!dbSeek(xFilial('SA1')+allTrim(_aListPed[nx]:CCUSTOMER_ID))))
		_cCliente := '000035'	//-> JOHN ALMEIDA
		_cLojaCli := '01'
	else
		_cCliente := SA1->A1_COD
		_cLojaCli := SA1->A1_LOJA
	endIf
	
	_cNumPed := GetSxeNum("SC5","C5_NUM")
	RollBackSX8()
	
	aadd(aCabec,{"C5_NUM"		,_cNumPed				 		,Nil})
	aadd(aCabec,{"C5_TSREFLJ"	,_aListPed[nx]:CINCREMENT_ID	,Nil})
	aadd(aCabec,{"C5_TIPO"		,"N"							,Nil})
	aadd(aCabec,{"C5_CLIENTE"	,_cCliente						,Nil})
	aadd(aCabec,{"C5_LOJACLI"	,_cLojaCli						,Nil})
	aadd(aCabec,{"C5_TIPOCLI"	,"F"							,Nil})
	aadd(aCabec,{"C5_FRETE"		,val(_aListPed[nx]:CBASE_SHIPPING_AMOUNT),Nil})
	aadd(aCabec,{"C5_TSFENVI"	,"1"							,Nil})
	aadd(aCabec,{"C5_TSNMCLI"	,Posicione('SA1',1,xFilial('SA1')+_cCliente+_cLojaCli,'A1_NOME'),Nil})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Identifica condicao de pagamento                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if(allTrim(_aListPed[nx]:OWSPAYMENT:CMETHOD) == 'pagamentodigital_geral')
		aadd(aCabec,{"C5_CONDPAG"	,"001"						,Nil})		//-> PAGAMENTO DIGITAL
	elseIf(allTrim(_aListPed[nx]:OWSPAYMENT:CMETHOD) == 'pagseguro_hpp')
		aadd(aCabec,{"C5_CONDPAG"	,"002"						,Nil})		//-> PAGSEGURO - UOL
	else
		aadd(aCabec,{"C5_CONDPAG"	,"003"						,Nil})		//-> A VISTA
	endIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Identifica status do pedido de venda                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if(allTrim(_aListPed[nx]:CSTATUS) == 'canceled')
		aadd(aCabec,{"C5_TSSTATU"	,"C"						,Nil})		//-> CANCELADO
		aadd(aCabec,{"C5_BLQ"		,"1"						,Nil})		//-> BLOQUEADO
	elseif(allTrim(_aListPed[nx]:CSTATUS) == 'pending' .or. lower(allTrim(_aListPed[nx]:CSTATUS)) == 'holded')
		aadd(aCabec,{"C5_TSSTATU"	,"A"						,Nil})		//-> AGUARDANDO PAGAMENTO
	elseif(allTrim(_aListPed[nx]:CSTATUS) == 'processing')
		aadd(aCabec,{"C5_TSSTATU"	,"L"						,Nil})		//-> LIBERADO PARA ENTREGA
	elseif(allTrim(_aListPed[nx]:CSTATUS) == 'complete')
		aadd(aCabec,{"C5_TSSTATU"	,"O"						,Nil})		//-> COMPLETO
		aadd(aCabec,{"C5_LIBEROK"	,"S"						,Nil})		//-> PEDIDO LIEBRADO PARA FATURAMENTO
	else
		aadd(aCabec,{"C5_TSSTATU"	,"X"						,Nil})		//-> DESCONHECIDO
	endIf
	
	aadd(aCabec,{"C5_EMISSAO"		,StoD(replace(subStr(_aListPed[nx]:CCREATED_AT,1,10),'-','')),Nil}) //-> DATA DE VENDA
	aadd(aCabec,{"C5_TSHRVEN"		,subStr(allTrim(_aListPed[nx]:CCREATED_AT),12),Nil}) //-> HORARIO DE VENDA
	aadd(aCabec,{"C5_TSIPVEN"		,allTrim(_aListPed[nx]:CREMOTE_IP),Nil}) //-> IP DA VENDA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Identifica os itens do pedido de venda                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	for ny:=1 to len(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY)
		aLinha := {}
		
		aadd(aLinha,{"C6_ITEM"		,strZero(ny,2)																		,Nil})
		aadd(aLinha,{"C6_PRODUTO"	,strZero(val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CPRODUCT_ID),15)	,Nil})
		aadd(aLinha,{"C6_QTDVEN"	,val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CQTY_ORDERED)				,Nil})
		aadd(aLinha,{"C6_PRCVEN"	,val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CPRICE)					,Nil})
		aadd(aLinha,{"C6_VALOR"		,val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CQTY_ORDERED) *;
											val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CPRICE)				,Nil})
		aadd(aLinha,{"C6_QTDLIB"	,val(_aListPed[nx]:OWSITEMS:OWSSALESORDERITEMENTITY[ny]:CQTY_ORDERED)				,Nil})
		aadd(aLinha,{"C6_TES"		,SuperGetMV("MV_TSTESPD",.F.,"501")													,Nil})
		
		aadd(aItens,aLinha)
	next ny
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Executa gravacao do pedido de venda no Protheus              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	begin transaction
	lMsErroAuto := .F.
	msExecAuto({|x,y,z|mata410(x,y,z)},aCabec,aItens,3)
	
	if(lMsErroAuto)
		mostraErro()
		disarmTransaction()
	endIf
	end transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| * Fatura Pedido de venda                                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if(SC5->C5_TSSTATU == 'O')
		TSFATURA()
	endIf
next nx
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSFATURA
Rotina responsavel por:
* Libera pedido de venda - Gera SC9
* Gera Nota Fiscal - SF2 e SD2
* Gera Contas a Receber - SE1
* Gera Contas a Pagar - SE2

@author    JONATAS ALMEIDA
@version   1.0
@since     24/12/2013
/*/
//---------------------------------------------------------------- --------------------------
Static Function TSFATURA()
U_TSGERANF()
U_TSBXACR(SE1->(RECNO()))

//--< GERA TITULO DE TAXA DO PAGSEGURO 4.99% da venda + R$ 0,40 >-----------------------------
if(allTrim(_aListPed[nx]:OWSPAYMENT:CMETHOD) == 'pagseguro_hpp')
	U_TSGERACP(	SE1->E1_NUM,;
				StoD(replace(subStr(_aListPed[nx]:CCREATED_AT,1,10),'-','')),;				//-> DATA DE EMISSAO
				DaySum(StoD(replace(subStr(_aListPed[nx]:CCREATED_AT,1,10),'-','')),14),;	//-> DATA DE VENCIMENTO
				(SE1->E1_VALOR * (superGetMV('TS_PERPSEG',.F.,4.99)/100)) + superGetMV('TS_TAXPSEG',.F.,0.40))
	U_TSBXACP(SE2->(RECNO()))
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGERANF
Rotina responsavel por gera Nota Fiscal de Saida

@author    JONATAS ALMEIDA
@version   1.0
@since     03/10/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSGERANF()
aPvlNfs   := {}
aBloqueio := {{"","","","","","","",""}}

// Variaveis para rotina automatica
aNotas  := {}

// Checa itens liberados
IncProc( "Verificando bloqueios para Pedido " + SC5->C5_NUM)
ma410LbNfs(1,@aPvlNfs,@aBloqueio)

//Verifica se Existe Itens Liberados para gerar a Nota Fiscal
cNotaFeita	:= ""
cSerie		:= "1"
aNotas		:= {}

//Abrindo selecao para serie da nota fiscal
//SX5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),cFilAnt)

If(empty(aBloqueio) .And. !Empty(aPvlNfs))
	nItemNf  := a460NumIt(cSerie)
	
	aadd(aNotas,{})
	
	// Efetua as quebras de acordo com o numero de itens
	for nz := 1 to len(aPvlNfs)
		if(len(aNotas[len(aNotas)]) >= nItemNf)
			aadd(aNotas,{})
		endIf
		aadd(aNotas[len(aNotas)],aClone(aPvlNfs[nz]))
	next nz
	
	for nz := 1 to len(aNotas)
		//Gera a Nota Fiscal
		IncProc("Gerando Nota para Pedido " + SC5->C5_NUM)
		Pergunte("MT460A",.F.)
		cNotaFeita := maPvlNfs(aNotas[nz],cSerie,.F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.)
		
		//Atualizada datas do titulo a receber
		RecLock('SE1',.F.)
		SE1->E1_EMISSAO	:= SC5->C5_EMISSAO
		SE1->E1_VENCTO	:= daySum(SC5->C5_EMISSAO,14)
		SE1->E1_VENCREA	:= daySum(SC5->C5_EMISSAO,14)
		//SE1->E1_NATUREZ	:= '0000000001'
		SE1->(msUnLock())
	next nz
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSTRATACEP
Rotina de tratamento de caracteres especiais para o CEP

@author    JONATAS ALMEIDA
@version   1.0
@since     03/10/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSTRATACEP(_cCep)
Local _cNewCep := ''
if(len(allTrim(_cCep)) > 0)
	for ny := 1 to len(_cCep)
		if!(subStr(_cCep,ny,1) $ '1|2|3|4|5|6|7|8|9|0')
			loop
		else
			_cNewCep += subStr(_cCep,ny,1)
		endIf
	next ny
endIf
Return _cNewCep

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSGERACP
Rotina de geração automatica de titulos a pagar - Financeiro

@author    JONATAS ALMEIDA
@version   1.0
@since     03/10/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSGERACP(_cNumTit,_dEmissao,_dVencto,_nValor)
Local aArray := {}
Private lMsErroAuto := .F.

aArray := {	{"E2_PREFIXO"	,"PSE"				,NIL},;	//-> *** PAGSEGURO
			{"E2_NUM"		,_cNumTit			,NIL},;
			{"E2_TIPO"		,"NF"				,NIL},;
			{"E2_NATUREZ"	,superGetMV('TS_NATPSEG',.F.,'0000000002'),NIL},;
			{"E2_FORNECE"	,superGetMV('TS_FORPSEG',.F.,'000002'),NIL},;
			{"E2_LOJA"		,superGetMV('TS_LJFPSEG',.F.,'01'),NIL},;
			{"E2_EMISSAO"	,_dEmissao			,NIL},;
			{"E2_VENCTO"	,_dVencto			,NIL},;
			{"E2_VENCREA"	,_dVencto			,NIL},;
			{"E2_VALOR"		,_nValor			,NIL}}

msExecAuto({|x,y,z| FINA050(x,y,z)},aArray,,INCLUI)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

if(lMsErroAuto)
	mostraErro()
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSBXACP
Rotina de baixa automatica dos titulos a pagar - Financeiro

@author    JONATAS ALMEIDA
@version   1.0
@since     22/01/2014
/*/
//------------------------------------------------------------------------------------------
User Function TSBXACP(_nRecno)
Local aBaixa := {}
Private lMsErroAuto := .F.

SE2->(dbGoTo(_nRecno))

cHistBaixa := "Baixa automática de pagamento - Tx. PagSeguro"
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com os dados da baixa a pagar do título                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aBaixa,{"E2_FILIAL"		,SE2->E2_FILIAL		,Nil})
AADD(aBaixa,{"E2_PREFIXO"		,SE2->E2_PREFIXO	,Nil})
AADD(aBaixa,{"E2_NUM"			,SE2->E2_NUM		,Nil})
AADD(aBaixa,{"E2_PARCELA"		,SE2->E2_PARCELA	,Nil})
AADD(aBaixa,{"E2_TIPO"			,SE2->E2_TIPO		,Nil})
AADD(aBaixa,{"E2_FORNECE"		,SE2->E2_FORNECE	,Nil})
AADD(aBaixa,{"E2_LOJA"			,SE2->E2_LOJA		,Nil})
AADD(aBaixa,{"AUTMOTBX"			,"PAGSEGUR"			,Nil})
AADD(aBaixa,{"AUTBANCO"			,"341"				,Nil})
AADD(aBaixa,{"AUTAGENCIA"		,"5199 "			,Nil})
AADD(aBaixa,{"AUTCONTA"			,"13830     "		,Nil})
AADD(aBaixa,{"AUTDTBAIXA"		,dDataBase			,Nil})
AADD(aBaixa,{"AUTDTCREDITO"		,dDataBase			,Nil})
AADD(aBaixa,{"AUTHIST"			,cHistBaixa			,Nil})
AADD(aBaixa,{"AUTVLRPG"			,SE2->E2_SALDO		,Nil})
		
//ACESSAPERG("FIN080", .F.)
		
//--< 3 == Baixa de titulo		 >-----------------------------
//--< 5 == Cancelamento de Baixa >-----------------------------
//--< 6 == Exclusao de Baixa	 >-----------------------------
msExecAuto({|x,y| FINA080(x,y)}, aBaixa, INCLUI)
		
if(lMsErroAuto)
	mostraErro()
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSBXACR
Rotina de baixa automatica dos titulos a receber - Financeiro

@author    JONATAS ALMEIDA
@version   1.0
@since     22/01/2014
/*/
//------------------------------------------------------------------------------------------
User Function TSBXACR(_nRecno)
Local aBaixa := {}
Private lMsErroAuto := .F.

SE1->(dbGoTo(_nRecno))

aBaixa := {	{"E1_PREFIXO"	,SE1->E1_PREFIXO		,Nil},;
			{"E1_NUM"		,SE1->E1_NUM			,Nil},;
			{"E1_TIPO"		,SE1->E1_TIPO			,Nil},;
			{"AUTMOTBX"		,"NOR"					,Nil},;
			{"AUTBANCO"		,"341"					,Nil},;
			{"AUTAGENCIA"	,"5199 "				,Nil},;
			{"AUTCONTA"		,"13830     "			,Nil},;
			{"AUTDTBAIXA"	,dDataBase				,Nil},;
			{"AUTDTCREDITO"	,dDataBase				,Nil},;
			{"AUTHIST"		,"Baixa Aut. Pagto."	,Nil},;
			{"AUTJUROS"		,0						,Nil},;
			{"AUTVALREC"	,SE1->E1_VALOR			,Nil}}

//--< 3 == Baixa de titulo		 >-----------------------------
//--< 5 == Cancelamento de Baixa >-----------------------------
//--< 6 == Exclusao de Baixa	 >-----------------------------
msExecAuto({|x,y| Fina070(x,y)},aBaixa,INCLUI)  

if(lMsErroAuto)
	mostraErro()
	Return .F.
endIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSIDESTADO
Rotina para identificar o UF do cliente na hora da importacao

@author    JONATAS ALMEIDA
@version   1.0
@since     16/12/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSIDESTADO(_cMun)
Local cRet := ''

CC2->(dbSetOrder(2))
if(CC2->(dbSeek(xFilial('CC2')+_cMun)))
	cRet := CC2->CC2_EST
else
	cRet := 'AC'
endIf

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSQTDEST
Obtem a quantidade de cada produto cadastrado no e-commerce

@author    JONATAS ALMEIDA
@version   1.0
@since     16/12/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSQTDEST()
Local _lRet
Local _aInvent
Local _aLstPrd
Local _aLstIdPrd := {}

Static _oWsTs
Static _sessionID

_oWsTs		:= WSMagentoService():New()
_sessionID	:= U_TSCONNEC()								//-> Abre conexao com Magento

_aLstPrd := U_TSLSTPRD()

for nx:=1 to len(_aLstPrd)
	aadd(_aLstIdPrd,_aLstPrd[nx]:CPRODUCT_ID)
next nx

_oWsTs:OWSCATALOGINVENTORYSTOCKITEMLISTPRODUCTS:CSTRING := _aLstIdPrd

_lRet	:= _oWsTs:catalogInventoryStockItemList(_sessionID,_oWsTs:OWSCATALOGINVENTORYSTOCKITEMLISTPRODUCTS)

if(_lRet)
	_aInvent := _oWsTs:OWSCATALOGINVENTORYSTOCKITEMLISTRESULT:OWSCATALOGINVENTORYSTOCKITEMENTITY
endIf

SB1->(dbOrderNickName('SB1SKU'))

_acabec := {'SKU','DESCRICAO','PRECO','PESO','TEM NO ESTOQUE?','QUANTIDADE'}
_aItens := {}

for nx:=1 to len(_aInvent)
	if(SB1->(dbSeek(xFilial('SB1')+_aInvent[nx]:CSKU)))
		aadd(_aItens,{SB1->B1_TSSKU, SB1->B1_DESC, SB1->B1_PRV1, SB1->B1_PESO, iif(_aInvent[nx]:CIS_IN_STOCK == '1','SIM','NAO'), _aInvent[nx]:CQTY})
	endIf
next nx

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",{||DlgToExcel({{"ARRAY","POSICAO DE PRODUTOS EM ESTOQUE - ECOMMERCE - TOQUESEDUTOR",_acabec,_aItens}})})

_oWsTs:endSession(_sessionID)
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TSENTREGA
Obtem os dados da postagem de entrega para o cliente final

@author    JONATAS ALMEIDA
@version   1.0
@since     16/12/2013
/*/
//------------------------------------------------------------------------------------------
User Function TSENTREGA(_cIDShipping)
Local _cCodRast
Local _aEntrega
//Local _lRet

Static _oWsTs
Static _sessionID

_oWsTs		:= WSMagentoService():New()
_sessionID	:= U_TSCONNEC()								//-> Abre conexao com Magento

_lRet := _oWsTs:salesOrderShipmentInfo(_sessionID,_cIDShipping)

if(_lRet)
	_aEntrega	:= _oWsTs:OWSSALESORDERSHIPMENTINFORESULT:OWSTRACKS:OWSSALESORDERSHIPMENTTRACKENTITY
	//_aItens		:= _oWsTs:OWSSALESORDERSHIPMENTINFORESULT:OWSITEMS:OWSSALESORDERSHIPMENTITEMENTITY
	//_aComents	:= _oWsTs:OWSSALESORDERSHIPMENTINFORESULT:OWSCOMMENTS:OWSSALESORDERSHIPMENTCOMMENTENTITY
endIf

//-> VARRE OS DADOS DE ENTREGA
if(_aEntrega[1]:CCARRIER_CODE <> NIL)
	for nx := 1 to len(_aEntrega)
		//_aEntrega[nx]:CCARRIER_CODE
		//_aEntrega[nx]:CCREATED_AT
		_cCodRast := _aEntrega[nx]:CNUMBER
		//_aEntrega[nx]:CTITLE
		//_aEntrega[nx]:CTRACK_ID
		//_aEntrega[nx]:CUPDATED_AT
	next nx
endIf

/*
//-> VARRE OS ITENS CONTIDOS NA ENTREGA
if(len(_aItens) > 0)
	for nx := 1 to len(_aItens)
	next nx
endIf

//-> VARRE OS COMENTARIOS DA ENTREGA
if(len(_aComents) > 0)
	for nx := 1 to len(_aComents)
	next nx
endIf
*/

_oWsTs:endSession(_sessionID)
Return _cCodRast

User Function TESTE()
//RPCSetType(3)			//Nao consome licensas
//RPCSetEnv('99','01')	//Abre empresa/filial/modulo/arquivos		

Conout('TESTE')
	
//RPCClearEnv()
Return