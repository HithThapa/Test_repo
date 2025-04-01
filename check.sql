
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ############################################################ BASE RETAIL: NIELSEN MARKET DATA RETAIL - NMDR #########################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ===================================================================================================================================================================================================
-- ÍNDICE ============================================================================================================================================================================================
-- ===================================================================================================================================================================================================
  
-- DECLARACAO DE VARIAVEIS ...................................................... 0035  
-- BASE TEMPORÁRIA DE PRODUTOS .................................................. 0095
-- BASE TEMPORÁRIA DE DEPARA ÁREA ............................................... 1097
-- BASE TEMPORÁRIA DE VENDAS LEVEL 9 ............................................ 1117
-- BASE TEMPORÁRIA DE BASE DATAS POSSIVEIS ...................................... 1786
-- BASE TEMPORÁRIA DE TOTAIS .................................................... 1843
-- BASE TEMPORÁRIA DE AREAS E MARKETS ........................................... 1912
-- BASE TEMPORÁRIA DE INDICADORES ............................................... 2368
-- BASE TEMPORÁRIA DE CAMPOS ADICIONAIS ......................................... 2451
-- BASE TEMPORÁRIA DE SALES TODOS OS LEVELS ..................................... 2567
-- UPDATE DISTRIBUICAO .......................................................... 4184
-- BASE FINAL RETAIL ............................................................ 5113
-- TABELA NIELSEN MARKET DATA RETAIL ............................................ 5527
-- TABELA NIELSEN MARKET DATA RETAIL CONTRIBUTION ............................... 6498
-- DROP TABELAS TEMPORARIAS ..................................................... 6604

-- ====================================================================================================================================================================================================
-- ÚLTIMA ALTERAÇÃO FEITA NO SCRIPT: CRIAR UM GATILHO PARA EXECUTAR CONFORME CRITÉRIOS =====================================================================================================================
-- ===========================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- DECLARAÇÃO DE VARIÁVEL ========================================================================================================================================================
-- ====================================================================================================================================================================================================

BEGIN
  DECLARE MaxDate DATE; DECLARE Check_Dates string;
  
-- PEGA A MAIOR DATA ENTRE TODAS AS BASES ORIGEM
------------------------------------------------  
  SET MaxDate = (SELECT MAX(data)

  FROM (
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales`
    UNION ALL
    SELECT start_date AS data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales`
  ));

-- VERIFICAR SE AS DATAS SÃO IGUAIS
-----------------------------------
 SET Check_Dates = (SELECT CASE WHEN  
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_sales`) AND
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_sales`) AND
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_sales`) =
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales`) AND
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales`) AND 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales`) AND 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales`) AND 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales`) =
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales`) AND 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales`) = 
                      (SELECT MAX(start_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales`)                  
 THEN 'SIM' ELSE 'NÃO' END) ;
--------------------------------------------------------------------------------------------------------------------------------------------------------
--  SE AS DATAS FOREM IGUAIS E A MAIOR DATA SEJA DIFERENTE DA DATA QUE JÁ EXISTE NA BASE, RODE TODO O SCRIPT
--  SE UMA DESSAS AFIRMAÇÕES FOREM FALSA PARE O SCRIPT
-- *SE ALGUMA BASE NÃO ESTIVER ATUALIZADA E PEDIREM PARA RODAR O SCRIPT, BASTA COMENTAR O IF LOGO ABAIXO*----------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
 IF (Check_Dates = 'SIM' and MaxDate <> (SELECT MAX(MaxDate) FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`)) THEN
  
-- ====================================================================================================================================================================================================
-- FIM DECLARAÇÃO DE VARIÁVEL ========================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE DE PRODUTOS ========================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_product_temp` 

OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

    WITH product AS (
      SELECT
      id AS prod_id,
      raw_prod,
      'toothpaste' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      cASt(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      life_stage,
      pack_size,
      raw_PESO_VOLUMEN as size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_product`
      WHERE raw_prod is not null AND level_name is not null and manufacturer <> 'PL'
	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'toothpaste' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      cASt(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      life_stage,
      pack_size,
      raw_PESO_VOLUMEN as size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
	  
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'manual tb' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      life_stage AS life_stage,
      pack_size,
      raw_CONTEUDO_EM_UNIDADES AS size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy ,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'manual tb' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      life_stage AS life_stage,
      pack_size,
      raw_CONTEUDO_EM_UNIDADES AS size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy ,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
    
UNION ALL
	 
      SELECT
      id AS prod_id,
      raw_prod,
      'mouthwash' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      size as package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      pack_size AS size,
      raw_PROMOCAO as promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  
UNION ALL
	 
      SELECT
      id AS prod_id,
      raw_prod,
      'mouthwash' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      size as package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size, 
      pack_size AS size,
      raw_PROMOCAO as promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
	  
UNION ALL
 
      SELECT
      id AS prod_id,
      raw_prod,
      'bar soap' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,
      product_form,
      package_form,
      life_stage,
      raw_APRESENTACAO_H3 AS pack_size,
      size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'bar soap' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,
      product_form,
      package_form,
      life_stage,
      raw_APRESENTACAO_H3 AS pack_size,
      size,
      promo_indicator, 
	  country , 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_product`
      WHERE raw_prod is not null AND level_name is not null and brand is null and manufacturer = 'PL'
	   
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total liquid soap' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and manufacturer <> 'PL' and hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'
    	
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total liquid soap' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL' and hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'
	
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL' AND
      hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	  
		
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL' AND 
      hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel adult' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
	  
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel adult' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'
	  
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel baby' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
	  
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'shower gel baby' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'lhs' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
	  
UNION ALL

	  SELECT
      id AS prod_id,
      raw_prod,
      'lhs' AS product,
      level_name,
      level_number,
      manufacturer AS manufacturer,
      long_desc,
      brand AS brand,
      subbrand AS subbrand,
      raw_VERSAO_AROMA_H4 AS variant,
      raw_FORMATOS_COLGATE_H4 AS subcategory,
      CAST(NULL AS string) AS consumer_usage,
      product_form,
      package_form,
      raw_IDADE_DE_USO_H4 AS life_stage,
      pack_size as pack_size,
      raw_INTERVALO_DE_PESO_H4 AS size,
      raw_EMBALAGEM_PROMOCIONAL_H4 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
      AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'	
    
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'shampoo' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      raw_TIPO_DE_TRATAMENTO as product_form,
      raw_OPCAO as package_form,
      raw_IDADE_DE_USO as life_stage,
      raw_APRESENTACAO_REGULAR as pack_size,
      size,
      promo_indicator, country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  
UNION ALL
      
	  SELECT
      id AS prod_id,
      raw_prod,
      'shampoo' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      raw_TIPO_DE_TRATAMENTO as product_form,
      raw_OPCAO as package_form,
      life_stage,
      pack_size,
      size,
      promo_indicator, country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
    
UNION ALL
	
      SELECT
      id AS prod_id,
      raw_prod,
      'hair conditioner'  AS product,
      level_name,
      level_number,
      raw_FABRICANTE_H2 AS manufacturer,
      long_desc,
      raw_MARCA_H2 AS brand,
      raw_SUB_MARCA_H2 AS subbrand,
      raw_VERSAO_H2 AS variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      raw_TIPO_H2 as product_form,
      raw_EMBALAGEM_H2 as package_form,
      life_stage AS life_stage,
      pack_size AS pack_size,
      raw_INTERVALO_DE_PESO_H2 AS size,
      raw_PROMOCAO_H2 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product`
      WHERE raw_prod is not null AND level_name is not null AND hierarchy_name = 'CONDICIONADOR - TOTAL H2' 
    
UNION ALL
	
	SELECT * FROM (
      SELECT
      id AS prod_id,
      raw_prod,
      'post shampoo' AS product,
      level_name,
      level_number,
	  CASE
      WHEN hierarchy_name = 'CONDICIONADOR - TOTAL H2'      THEN raw_FABRICANTE_H2
      WHEN hierarchy_name = 'CREME PARA PENTEAR - TOTAL H3' THEN raw_FABRICANTE_H3
      WHEN hierarchy_name = 'CR TRATAMENTO - TOTAL H4'      THEN raw_FABRICANTE_H4
      WHEN hierarchy_name = 'FINALIZADORES H5'              THEN raw_FABRICANTE_H5
      WHEN hierarchy_name = 'PROTECAO H6'                   THEN raw_FABRICANTE_H6
      END
      AS manufacturer,
      long_desc,
      raw_MARCA_H2 AS brand,
      raw_SUB_MARCA_H2 AS subbrand,
      raw_VERSAO_H2 AS variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      raw_TIPO_H2 as product_form,
      raw_EMBALAGEM_H2 as package_form,
      life_stage AS life_stage,
      pack_size AS pack_size,
      raw_INTERVALO_DE_PESO_H2 AS size,
      raw_PROMOCAO_H2 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product`
      WHERE raw_prod is not null AND level_name is not null 
	  AND hierarchy_name in ('CONDICIONADOR - TOTAL H2', 'CREME PARA PENTEAR - TOTAL H3', 
      'CR TRATAMENTO - TOTAL H4', 'FINALIZADORES H5', 'PROTECAO H6')
	  )A
      WHERE manufacturer <> 'PL'
	
	  UNION ALL
	
	  SELECT * FROM (
      SELECT
      id AS prod_id,
      raw_prod,
      'post shampoo' AS product,
      level_name,
      level_number,
	  CASE
      WHEN hierarchy_name = 'CONDICIONADOR - TOTAL H2'      THEN raw_FABRICANTE_H2
      WHEN hierarchy_name = 'CREME PARA PENTEAR - TOTAL H3' THEN raw_FABRICANTE_H3
      WHEN hierarchy_name = 'CR TRATAMENTO - TOTAL H4'      THEN raw_FABRICANTE_H4
      WHEN hierarchy_name = 'FINALIZADORES H5'              THEN raw_FABRICANTE_H5
      WHEN hierarchy_name = 'PROTECAO H6'                   THEN raw_FABRICANTE_H6
      END
      AS manufacturer,
      long_desc,
      raw_MARCA_H2 AS brand,
      raw_SUB_MARCA_H2 AS subbrand,
      raw_VERSAO_H2 AS variant,
      subcategory,
      CAST(NULL AS string) AS consumer_usage,
      raw_TIPO_H2 as product_form,
      raw_EMBALAGEM_H2 as package_form,
      life_stage AS life_stage,
      pack_size AS pack_size,
      raw_INTERVALO_DE_PESO_H2 AS size,
      raw_PROMOCAO_H2 AS promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
	  
      FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product`
      WHERE raw_prod is not null AND level_name is not null 
	  AND hierarchy_name in ('CONDICIONADOR - TOTAL H2', 'CREME PARA PENTEAR - TOTAL H3', 
      'CR TRATAMENTO - TOTAL H4', 'FINALIZADORES H5', 'PROTECAO H6')
	  
	  )A
    WHERE manufacturer = 'PL' 		
	
UNION ALL
		  
      SELECT
      id AS prod_id,
      raw_prod,
      'liquid cleaners' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null 	  
    
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'other cleaners' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'other cleaners' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
    
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'specialized' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null AND manufacturer <> 'PL'
	  
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'specialized' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null and subbrand is null and manufacturer = 'PL'
		
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'bdc' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null 
	    
UNION ALL
	  
	  SELECT
      id AS prod_id,
      raw_prod,
      'disinfectant' AS product, 
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand AS subbrand,
      product_form AS variant,
      subcategory,
      consumer_usage,
      '' AS product_form,
      variant AS package_form,
      life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      size AS size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product`
      WHERE raw_prod is not null AND level_name is not null 
		
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total soaps' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,   
      raw_CONSISTENCIA as product_form,
      raw_R_EMBALAGEM as package_form,
      raw_IDADE_DE_USO as life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      raw_INTERVALO_DE_PESO as size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product`
      WHERE raw_prod is not null AND level_name is not null AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND country = 'BR'
	  AND manufacturer <> 'PL'
	  
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total soaps' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,
      raw_CONSISTENCIA as product_form,
      raw_R_EMBALAGEM as package_form,
      raw_IDADE_DE_USO as life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      raw_INTERVALO_DE_PESO as size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product`
      WHERE raw_prod is not null AND level_name is not null AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND country = 'BR'
      AND subbrand is null and manufacturer = 'PL'
	  
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total soaps kids' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,
      raw_CONSISTENCIA as product_form,
      raw_R_EMBALAGEM as package_form,
      raw_IDADE_DE_USO as life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      raw_INTERVALO_DE_PESO as size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product`
	  WHERE raw_prod is not null AND level_name is not null AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND country = 'BR'
	  AND manufacturer <> 'PL' AND raw_IDADE_DE_USO = 'INFANTIL'
	  
UNION ALL
	  
      SELECT
      id AS prod_id,
      raw_prod,
      'total soaps kids' AS product,
      level_name,
      level_number,
      manufacturer,
      long_desc,
      brand,
      subbrand,
      variant,
      subcategory,
      '' AS consumer_usage,
      raw_CONSISTENCIA as product_form,
      raw_R_EMBALAGEM as package_form,
      raw_IDADE_DE_USO as life_stage,
      raw_APRESENTACAO_REGULAR AS pack_size,
      raw_INTERVALO_DE_PESO as size,
      promo_indicator, 
	  country, 
	  normalized_hierarchy,
	  hierarchy_name
      
	  FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product`
	       
      WHERE raw_prod is not null AND level_name is not null AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND country = 'BR'
      AND subbrand is null and manufacturer = 'PL' AND raw_IDADE_DE_USO = 'INFANTIL'   
   )

      SELECT * FROM product;
	
-- ====================================================================================================================================================================================================
-- FIM BASE CONSOLIDADA DE PRODUTOS ===================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE DEPARA AREA ============================================================================================================================================================================
-- ====================================================================================================================================================================================================

	CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_area_temp` 
    OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 DAY)) AS

	SELECT DISTINCT market_area_full_name, 
	                area, 
	                CASE WHEN market = 'TOTAL BRAZIL' THEN 'TOTAL RE' ELSE market END AS market, 
	                microregion 
	FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Retail_RE_Area`
    where ingestion_time <> 'excluir'  

	;
 
-- ====================================================================================================================================================================================================
-- FIM BASE DEPARA AREA ===================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE SALES LEVEL NUMBER 9 ============================================================================================================================================================================
-- ====================================================================================================================================================================================================
	 
CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_sales_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

---toothpaste
        SELECT DISTINCT
        'toothpaste'               AS product, 
		S.start_date,
        S.end_date,
        S.market_desc, 
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume
	
        FROM  `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_product` AS P ON S.id = P.id
	           
        WHERE P.country = 'BR' AND P.subcategory = 'CREME DENTAL' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND P.level_number = 9 AND P.manufacturer <> 'PL'

UNION ALL 
       
---toothpaste - Manufacturer PL
        SELECT DISTINCT
        'toothpaste'               AS product, 
		S.start_date,
        S.end_date,
        S.market_desc, 
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume
	
        FROM  `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_product` AS P ON S.id = P.id
	           
        WHERE P.country = 'BR' AND P.subcategory = 'CREME DENTAL' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND P.level_number = 3 AND P.manufacturer = 'PL'

UNION ALL

-- manual tb
        SELECT DISTINCT
        'manual tb'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		0     AS units_nc,
		0     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_product` AS P ON S.id = P.id

        WHERE P.country = 'BR' AND P.subcategory = 'ESCOVAS P/DENTES' AND P.normalized_hierarchy = 'main' AND P.level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL      

UNION ALL

-- mouthwash
        SELECT DISTINCT
        'mouthwash'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_product` AS P ON S.id = P.id

        WHERE P.country = 'BR' AND P.subcategory = 'ANTISSEPTICOS BUCAIS' AND P.normalized_hierarchy = 'main' AND P.level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL    

UNION ALL

-- total soaps
        SELECT DISTINCT
       'total soaps'               AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product` AS P ON S.id = P.id

        WHERE country = 'BR' AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND normalized_hierarchy = 'main' AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL  

UNION ALL

-- bar soap
        SELECT DISTINCT
       'bar soap'                  AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_product` AS P ON S.id = P.id
  
        WHERE P.country = 'BR' AND P.subcategory = 'SABONETES SOLIDOS' AND P.normalized_hierarchy = 'main' AND P.level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND life_stage in ('ADULTO','INFANTIL')   AND manufacturer <> 'PL'

UNION ALL

-- bar soap
        SELECT DISTINCT
       'bar soap'                  AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_product` AS P ON S.id = P.id
  
        WHERE P.country = 'BR' AND P.subcategory = 'SABONETES SOLIDOS' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND life_stage in ('ADULTO','INFANTIL')  AND P.level_number = 3 AND P.manufacturer = 'PL' 		

UNION ALL

-- shower gel
        SELECT DISTINCT
       'shower gel'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.raw_DISTR__NUMERICA  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id

        WHERE country = 'BR' 
        AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
		AND raw_FORMATOS_COLGATE_H4 = 'BODY WASH'
        AND level_number = 9 
		AND raw_IDADE_DE_USO_H4 IN('ADULTO','INFANTIL')
        AND P.raw_prod   IS NOT NULL 
        AND P.level_name IS NOT NULL 
        AND P.long_desc  IS NOT NULL

UNION ALL 

-- shower gel adult
        SELECT DISTINCT
       'shower gel adult'          AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.raw_DISTR__NUMERICA  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
        WHERE country = 'BR' 
        AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
		AND raw_FORMATOS_COLGATE_H4 = 'BODY WASH'
        AND level_number = 9 
		AND raw_IDADE_DE_USO_H4 IN('ADULTO')
		AND P.raw_prod   IS NOT NULL 
        AND P.level_name IS NOT NULL 
        AND P.long_desc  IS NOT NULL

UNION ALL

-- shower gel baby
        SELECT DISTINCT
       'shower gel baby'           AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.raw_DISTR__NUMERICA  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id

        WHERE country = 'BR' 
        AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
		AND raw_FORMATOS_COLGATE_H4 = 'BODY WASH'
        AND level_number = 9 
		AND raw_IDADE_DE_USO_H4 IN('INFANTIL')  
        AND P.raw_prod   IS NOT NULL 
		AND P.level_name IS NOT NULL
		AND P.long_desc  IS NOT NULL

UNION ALL

-- total liquid soap
        SELECT DISTINCT
       'total liquid soap'         AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.raw_DISTR__NUMERICA  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
	
        WHERE country = 'BR' and hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
		AND level_number = 9 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 

UNION ALL

-- shampoo
        SELECT DISTINCT
       'shampoo'                   AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND subcategory = 'SHAMPOOS - TOTAL' AND hierarchy_name = 'SHAMPOO - TOTAL' 
        AND normalized_hierarchy = 'main' AND level_number = 9 AND P.manufacturer <> 'PL'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 
	  
UNION ALL

-- shampoo - Manufacturer PL
        SELECT DISTINCT
       'shampoo'                   AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND subcategory = 'SHAMPOOS - TOTAL' AND hierarchy_name = 'SHAMPOO - TOTAL' 
        AND normalized_hierarchy = 'main' AND level_number = 3 AND P.manufacturer = 'PL'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 

UNION ALL

--post shampoo
SELECT * FROM

(
        SELECT DISTINCT
       'post shampoo'             AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		CASE
        WHEN hierarchy_name = 'CONDICIONADOR - TOTAL H2'      THEN raw_FABRICANTE_H2
        WHEN hierarchy_name = 'CREME PARA PENTEAR - TOTAL H3' THEN raw_FABRICANTE_H3
        WHEN hierarchy_name = 'CR TRATAMENTO - TOTAL H4'      THEN raw_FABRICANTE_H4
        WHEN hierarchy_name = 'FINALIZADORES H5'              THEN raw_FABRICANTE_H5
        WHEN hierarchy_name = 'PROTECAO H6'                   THEN raw_FABRICANTE_H6
        END
        AS manufacturer,
		
		P.Level_name,
   CAST(S.weighted_dist AS INT64) AS weighted_dist,
   CAST(S.numeric_dist  AS INT64) AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod) AS raw_prod, 
	    S.sales_units                 AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    sales_value                   AS sales_value,
        sales_volume                  AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND hierarchy_name in ('CONDICIONADOR - TOTAL H2', 'CREME PARA PENTEAR - TOTAL H3', 
        'CR TRATAMENTO - TOTAL H4', 'FINALIZADORES H5', 'PROTECAO H6') AND level_number = 9 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
)A
WHERE manufacturer <> 'PL'


UNION ALL

--post shampoo - Manufacturer PL
SELECT * FROM

(
        SELECT DISTINCT
       'post shampoo'             AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		CASE
        WHEN hierarchy_name = 'CONDICIONADOR - TOTAL H2'      THEN raw_FABRICANTE_H2
        WHEN hierarchy_name = 'CREME PARA PENTEAR - TOTAL H3' THEN raw_FABRICANTE_H3
        WHEN hierarchy_name = 'CR TRATAMENTO - TOTAL H4'      THEN raw_FABRICANTE_H4
        WHEN hierarchy_name = 'FINALIZADORES H5'              THEN raw_FABRICANTE_H5
        WHEN hierarchy_name = 'PROTECAO H6'                   THEN raw_FABRICANTE_H6
        END
        AS manufacturer,
		
		P.Level_name,
   CAST(S.weighted_dist AS INT64) AS weighted_dist,
   CAST(S.numeric_dist  AS INT64) AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod) AS raw_prod, 
	    S.sales_units                 AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    sales_value                   AS sales_value,
        sales_volume                  AS sales_volume

        FROM 	 `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND hierarchy_name in ('CONDICIONADOR - TOTAL H2', 'CREME PARA PENTEAR - TOTAL H3', 
        'CR TRATAMENTO - TOTAL H4', 'FINALIZADORES H5', 'PROTECAO H6') AND level_number = 3
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		
)A
WHERE   manufacturer = 'PL'

UNION ALL

--hair conditioner
        SELECT DISTINCT
       'hair conditioner'          AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.raw_FABRICANTE_H2 AS manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume
	
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND hierarchy_name = 'CONDICIONADOR - TOTAL H2' AND level_number = 9 AND P.raw_FABRICANTE_H2 <> 'PL'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		  	  
UNION ALL

--hair conditioner - Manufacturer PL
        SELECT DISTINCT
       'hair conditioner'          AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.raw_FABRICANTE_H2 AS manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod,  
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume
	
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND hierarchy_name = 'CONDICIONADOR - TOTAL H2' AND level_number = 3 AND P.raw_FABRICANTE_H2 = 'PL'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 

UNION ALL

--liquid cleaners
        SELECT DISTINCT
       'liquid cleaners'           AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer,
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
    
        WHERE country = 'BR' AND subcategory = 'TOTAL CATEGORIA' AND hierarchy_name = 'TOTAL CATEGORIA H1' 
        AND normalized_hierarchy = 'main' AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL

UNION ALL

--disinfectant
        SELECT DISTINCT
       'disinfectant'              AS product, 
	 	S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume
	
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND consumer_usage = 'DESINFETANTE' AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'

UNION ALL

--bdc
        SELECT DISTINCT
       'bdc'                       AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND consumer_usage in ('LIMPEZA PERFUMADA', 'LIMPEZA PESADA', 'USO GERAL') AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'

UNION ALL

--specialized
        SELECT DISTINCT
       'specialized'                 AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND consumer_usage in ('BANHEIRO', 'COZINHA', 'LIMPADOR SANITARIO', 'TIRA LIMO', 'LIMPA VIDRO') AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'

UNION ALL

--other cleaners
        SELECT DISTINCT
       'other cleaners'            AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)                 AS raw_prod, 
	    S.sales_units              AS sales_units,
		S.raw_VENDAS_UNID_NAO_CONV__in_000_ *1000 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  
        WHERE country = 'BR' AND hierarchy_name = 'COZINHA + BANHEIRO + LIMPADOR SANITARIO + TIRA LIMO + LIMP' AND level_number = 9
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL

UNION ALL

---LHS
        SELECT DISTINCT
       'lhs'                           AS product, 
        S.start_date,
        S.end_date,
        S.market_desc,
        P.manufacturer, 
        P.Level_name,
   CAST(S.weighted_dist AS INT64)      AS weighted_dist,
   CAST(S.raw_DISTR__NUMERICA  AS INT64)      AS numeric_dist,
        IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
        S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
        SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume 

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id  
        WHERE country = 'BR' 
        AND raw_FORMATOS_COLGATE_H4 = 'LIQUIDS HAND SOAP'
        AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
		AND level_number = 9 

UNION ALL 

-- total soaps kids
        SELECT DISTINCT
       'total soaps kids'       AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		P.manufacturer, 
		P.Level_name,
   CAST(S.weighted_dist AS INT64)  AS weighted_dist,
   CAST(S.numeric_dist  AS INT64)  AS numeric_dist,
		IFNULL(S.raw_prod,P.raw_prod)  AS raw_prod, 
	    S.sales_units                  AS sales_units,
		0 AS units_nc,
		S.raw_VENDAS__in_000_UNID_ *1000     AS units_c,
	    SAFE_DIVIDE(sales_value, 1000) AS sales_value,
        SAFE_DIVIDE(sales_volume,1000) AS sales_volume

        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product` AS P ON S.id = P.id

        WHERE country = 'BR' AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND normalized_hierarchy = 'main' AND level_number = 9
        AND raw_IDADE_DE_USO = 'INFANTIL' AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL  

;
-- ====================================================================================================================================================================================================
-- FIM BASE SALES LEVEL NUMBER 9 ======================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE DATAS POSSIVEIS - ADICIONANDO TODOS RAW_PROD EM TODAS AS DATAS DA BASE PARA OS CÁLCULOS DOS INDICADORES ===============================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_dates_possibles_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

-- First AND LASt Date
WITH dates AS(
	SELECT 
		MIN(start_date) AS MinDate, 
		MAX(start_date) AS MaxDate
	FROM(SELECT DISTINCT start_date FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_sales_temp`)
),
-- All possible dates 
all_dates AS (
	SELECT 	
		day 							AS start_date,
		date_add(day, interval 1 month)	AS end_date,
	FROM unnest(
			GENERATE_DATE_ARRAY((SELECT MinDate FROM dates), (SELECT MaxDate FROM dates), interval 1 month)) AS day
),
-- All DISTINCT ids
all_ids AS (
	SELECT DISTINCT 
		product,
		market_desc, 
		raw_prod
	FROM  `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_sales_temp` 
),
-- All Dates AND all DISTINCT ids
all_dates_ids AS (
	SELECT DISTINCT
		A.start_date,
		A.end_date,
		B.product,
		B.market_desc,
		B.raw_prod
    FROM all_dates A
	CROSS JOIN all_ids B
),

all_view AS(
	SELECT DISTINCT
        end_date, 
        start_date, 
        market_desc,
        product,
		raw_prod
	    FROM all_dates_ids	
)
	SELECT * FROM all_view;
	
-- ====================================================================================================================================================================================================
-- FIM BASE DATAS POSSIVEIS ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE TOTAIS ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_total_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

WITH total_sales_view AS (

    SELECT 	     
    start_date,
    end_date,
    market_desc,
	raw_prod,
	product,		  
    MAX(weighted_dist) 	AS weighted_dist,
	MAX(numeric_dist) 	AS numeric_dist,
	MAX(level_name) 	AS level_name,
	SUM(sales_units) 	AS sales_units,
	SUM(units_nc)       AS units_nc,
	SUM(units_c)        AS units_c,
	SUM(sales_value) 	AS sales_value,
	SUM(sales_volume) 	AS sales_volume	
			 
	FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_sales_temp`    
	
	GROUP BY	
	start_date,
    end_date,
    market_desc,
	raw_prod,
	product
),

total_view AS (

	    SELECT 	     
		A.start_date,
		A.end_date,
		A.market_desc,
		A.raw_prod,
		extract(year  FROM A.start_date) AS year,
		extract(month FROM A.start_date) AS month,
		A.product,
		  
		IFNULL(B.weighted_dist,0) AS weighted_dist,
		IFNULL(B.numeric_dist,0)  AS numeric_dist,
		B.Level_name,
		IFNULL(B.sales_units,0)   AS sales_units,
		IFNULL(B.units_nc,0)      AS units_nc,
	    IFNULL(B.units_c,0)       AS units_c,
		IFNULL(B.sales_value,0)   AS sales_value,
		IFNULL(B.sales_volume,0)  AS sales_volume
			 
	    FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_dates_possibles_temp` A
		LEFT JOIN total_sales_view     B 
		ON  A.raw_prod     = B.raw_prod
		AND A.market_desc  = B.market_desc 
		AND A.start_date   = B.start_date
		AND A.product      = B.product
)

  SELECT * FROM total_view
  ;  
-- ====================================================================================================================================================================================================
-- FIM BASE TOTAIS ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================
	
-- ====================================================================================================================================================================================================
-- BASE AREAS E MARKETS - ADICIONANDO TODAS AS AREAS I A VIII, AREAS CONBINADAS EX: AREA II + AREA III E
-- NOVOS MERCADOS E COMBINADOS DE MERCADOS EX: INA + C&C  ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_areas_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

with  areas_view AS ( 
        SELECT 
		A.start_date,
		A.end_date,
		A.market_desc,
		A.raw_prod,
		A.year,
		A.month,
		A.product, 
		A.weighted_dist,
		A.numeric_dist,
		A.Level_name,
		B.area,
		B.market,
		B.microregion,
		A.sales_units,
		A.units_nc,
    	A.units_c,
		A.sales_value,
		A.sales_volume,

	    FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_total_temp` A
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_area_temp` B ON A.market_desc = B.market_area_full_name 
		WHERE B.area IN('AREA I','AREA II','AREA III','AREA IV','AREA V','AREA VI','AREA VII','TOTAL BRAZIL')
		AND A.market_desc NOT IN ('EHC STATE SP','EHC STATE RJ')
		
),

 area_8_view AS (
              SELECT
		      start_date,
		      end_date,
		     'AREA VIII' 				AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			 'AREA VIII' 				AS area,
		      market,
		     'AREA VIII' 				AS microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume

              FROM areas_view  
	          WHERE market = 'TOTAL RE' and area = 'TOTAL BRAZIL'

     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      market
     
UNION ALL

              SELECT             
		      start_date,
		      end_date,
		      'AREA VIII' 				AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
             'AREA VIII' AS area,
		      market,
		      'AREA VIII' 			  	AS microregion,
		      SUM(sales_units)  *(-1) 	AS sales_units,
			  SUM(units_nc)     *(-1) 	AS units_nc,
    	      SUM(units_c)      *(-1) 	AS units_c,
		      SUM(sales_value)  *(-1) 	AS sales_value,
		      SUM(sales_volume) *(-1) 	AS sales_volume

              FROM areas_view  
	          WHERE market = 'TOTAL RE' and area != 'TOTAL BRAZIL'

     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      market				
),

area_8_final_view AS (
              SELECT
		      start_date,
		      end_date,
		      market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      Level_name,
			  area,
		      market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume

              FROM area_8_view

     GROUP BY start_date,
		      end_date,
		      market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      Level_name,
              area,
		      market,
		      microregion  
),

combined_area_view AS (

              SELECT 
		      start_date,
		      end_date,
		      'AREA II + III' 			AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA II + III' 			AS area,
		      market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE area in ('AREA II', 'AREA III')
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      market,
		      microregion

UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'AREA IV + V'  			AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA IV + V'  			AS area,
		      market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE area in ('AREA IV', 'AREA V')
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      market,
		      microregion
			  
UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'INA + C&C'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  area   			        AS area,
		      'INA + C&C'               AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C')
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      area,
		      microregion	

UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'INA + C&C'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA IV + V'   			AS area,
		      'INA + C&C'               AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C') AND area IN ('AREA IV', 'AREA V')
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion	
			  
			  
UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'INA + C&C'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA II + III'    		AS area,
		      'INA + C&C'               AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C') AND area IN ('AREA II', 'AREA III')
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion

	
	UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'RS'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA RS'    		        AS area,
		      'RS'                      AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C', 'INFC') AND area IN ('AREA VI') AND microregion = 'RS'
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion

	UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'SC'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA SC'    		        AS area,
		      'SC'                      AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C', 'INFC') AND area IN ('AREA VI') AND microregion = 'SC'
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion
 

	UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'PR'  			    AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  'AREA PR'    		        AS area,
		      'PR'                      AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C', 'INFC') AND area IN ('AREA VI') AND microregion = 'PR'
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion
    
		UNION ALL
              		  
			  SELECT 
		      start_date,
		      end_date,
		      'TOTAL RE UF'  			AS market_desc,
		      raw_prod,
		      year,
		      month,
		      product, 
		      MAX(weighted_dist) 		AS weighted_dist,
		      MAX(numeric_dist) 		AS numeric_dist,
		      '' as Level_name,
			  area    		            AS area,
		      'TOTAL RE UF'             AS market,
		      microregion,
		      SUM(sales_units)  		AS sales_units,
			  SUM(units_nc) 			AS units_nc,
    	      SUM(units_c) 				AS units_c,
		      SUM(sales_value)  		AS sales_value,
		      SUM(sales_volume) 		AS sales_volume
	  
              FROM areas_view
              WHERE market in ('INA', 'C&C', 'INFC') AND 
			  AREA IN ('AREA I','AREA II','AREA III','AREA IV','AREA V','AREA VI','AREA VII') 
     GROUP BY start_date,
		      end_date,
		      raw_prod,
		      year,
		      month,
		      product, 
		      microregion,
			  area
    ), 
	
group_view AS(
      SELECT *
      FROM areas_view
      UNION ALL
	  
      SELECT *
      FROM area_8_final_view
      UNION ALL
	  
      SELECT *
      FROM combined_area_view
	  
	  )	   
	   
	  SELECT * FROM   group_view
;
	   
-- ====================================================================================================================================================================================================
-- FIM DA BASE AREAS E MARKETS - ADICIONANDO TODAS AS AREAS I A VIII, AREAS CONBINADAS EX: AREA II + AREA III E
-- NOVOS MERCADOS E COMBINADOS DE MERCADOS EX: INA + C&C  ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE INDICADORES - CALCULO DOS INDICADORES ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================
  
CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_indicators_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

WITH indicators_view AS (
	    SELECT 	         
        start_date,
        end_date,
        market_desc,
		raw_prod,
		year,
        month,
		product,
		weighted_dist,
		numeric_dist,
		sales_units,
		units_nc,
    	units_c,
		sales_value,
		sales_volume,
		Level_name,
	    area,
		market,
		microregion,
		
		-- SOA
        SAFE_DIVIDE(numeric_dist, SUM(numeric_dist)    OVER (PARTITION BY  month, year, market_desc, microregion, market, area, product ORDER BY month))*100   AS soa_value,			
		-- Share of Market	 			 
		SAFE_DIVIDE(sales_value,  SUM(sales_value)    OVER (PARTITION BY  month, year, market_desc, microregion, market, area, product ORDER BY month))*100   AS som_value,		 
		SAFE_DIVIDE(sales_volume, SUM(sales_volume)   OVER (PARTITION BY  month, year, market_desc, microregion, market, area, product ORDER BY month))*100   AS som_volume,
        -- Year to Date      
		SUM(sales_value)    OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month)   AS sales_value_YTD,
		SUM(sales_units)    OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month)   AS sales_units_YTD,
		SUM(units_nc)       OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month)   AS units_nc_YTD,
		SUM(units_c)        OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month)   AS units_c_YTD,
		SUM(sales_volume)   OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month)   AS sales_volume_YTD,
      	-- SOA Year to Date
		SAFE_DIVIDE(
		SUM(numeric_dist)    OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month),
		SUM(numeric_dist)    OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY month))*100    AS soa_value_YTD,

		-- Share of Market Year to Date
		SAFE_DIVIDE(
		SUM(sales_value)    OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month),
		SUM(sales_value)    OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY month))*100    AS som_value_YTD,
			  
		SAFE_DIVIDE(
		SUM(sales_volume)   OVER (PARTITION BY  year, raw_prod, market_desc, microregion, market, area, product ORDER BY month), 
		SUM(sales_volume)   OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY month))*100    AS som_volume_YTD
			
	    FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_areas_temp` 
  ),
    
final_view AS(
	    SELECT *,
		-- Last Year
		LAG(sales_value, 1, 0) OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_value,
		LAG(sales_volume, 1, 0) OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_volume,
	
	---- units
		LAG(sales_units, 1, 0)  OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_units,
		LAG(units_nc, 1, 0)     OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_units_nc,
		LAG(units_c, 1, 0)      OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_units_c,
    ------------------
	
	
		-- Share of Market Last Year
		LAG(som_value, 1, 0) OVER (PARTITION BY market_desc, month,raw_prod, microregion, market, area, product ORDER BY year) AS prev_som_value,
		LAG(som_volume, 1, 0) OVER (PARTITION BY market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_som_volume,
    
		-- Year to Date Last Year     
		LAG(sales_value_YTD, 1, 0) OVER (PARTITION BY market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_value_YTD,
		LAG(sales_volume_YTD, 1, 0) OVER (PARTITION BY market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_volume_YTD,
    ---units YTD
		LAG(sales_units_YTD, 1, 0)  OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_sales_units_YTD,
		LAG(units_nc_YTD, 1, 0)     OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_units_nc_YTD,
		LAG(units_c_YTD, 1, 0)      OVER (PARTITION BY  market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_units_c_YTD,
		
		
		
		-- Share of Market Year to Date Last Year
		LAG(som_value_YTD, 1, 0) OVER (PARTITION BY market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_som_value_YTD,
		LAG(som_volume_YTD, 1, 0) OVER (PARTITION BY market_desc, month, raw_prod, microregion, market, area, product ORDER BY year) AS prev_som_volume_YTD,

	    FROM indicators_view
)
  SELECT * FROM final_view
;
  
-- ====================================================================================================================================================================================================
-- FIM BASE INDICADORES - CALCULO DOS INDICADORES ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- BASE CAMPOS ADICIONAIS - INCLUINDO CAMPOS DA BASE DE PRODUTOS ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

	  
WITH adicionais_view as (
        SELECT DISTINCT
        start_date,
        end_date,
        market_desc,
		A.raw_prod,
		year,
        month,
		A.product AS product,
		sales_units,
		units_nc,
    	units_c,
		sales_value,
		sales_volume,
		A.Level_name,
	    area,
		market,
		microregion,		
		-- Share of Market	 			 
		som_value,		 
		som_volume,
        -- Year to Date      
		sales_value_YTD,
		sales_units_YTD,
		units_nc_YTD,
    	units_c_YTD,
		sales_volume_YTD,
      	-- Share of Market Year to Date
        som_value_YTD,
        som_volume_YTD,
		prev_sales_value,
		prev_sales_volume,
		-- Share of Market Last Year
		prev_som_value,
		prev_som_volume,
        prev_sales_units,
        prev_units_nc,
        prev_units_c,		
		-- Year to Date Last Year     
		prev_sales_value_YTD,
		prev_sales_volume_YTD,  
		prev_sales_units_YTD,
        prev_units_nc_YTD,
        prev_units_c_YTD,
		-- Share of Market Year to Date Last Year
		prev_som_value_YTD,
		prev_som_volume_YTD,
		(sales_value + prev_sales_value + prev_sales_value_YTD + sales_value_YTD) AS VALIDADOR,
		-- SOA
		soa_value, 
		soa_value_YTD,
		
		--Informações adicionais--
		--------------------------
        IFNULL(C.Manufacturer_BQ,B.manufacturer) AS manufacturer,
        long_desc,
        CASE WHEN B.brand IS NULL THEN Manufacturer_BQ 
		ELSE B.brand END AS brand,
        B.subbrand,
        variant,
        B.subcategory,
        consumer_usage,
        product_form,
        package_form,
        life_stage,
        pack_size,
        size,
        promo_indicator, 
	    country , 
	    normalized_hierarchy,
	    hierarchy_name,
		weighted_dist  AS weighted_dist9,
		numeric_dist   AS numeric_dist9,
		
		--campos Adicionais--
		---------------------
		0 AS  weighted_dist8, 
		0 AS  numeric_dist8,
		0 AS  weighted_dist7, 
		0 AS  numeric_dist7,
		0 AS  weighted_dist6, 
		0 AS  numeric_dist6,
	    0 AS  weighted_dist5, 
		0 AS  numeric_dist5,
		0 AS  weighted_dist4, 
		0 AS  numeric_dist4,
	    0 AS  weighted_dist3, 
		0 AS  numeric_dist3,
	    0 AS  weighted_dist2, 
		0 AS  numeric_dist2,
	    0 AS  weighted_dist1,
		0 AS  numeric_dist1,
		
		--Informações Segmentos--
		mkt_segment, 
		cp_pricetier

        FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_indicators_temp` A
        LEFT JOIN `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_product_temp`  B
        ON A.raw_prod = B.raw_prod AND A.product = B.product
		LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON B.manufacturer = C.manufacturer_nielsen
		LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Retail_Product` D 
		ON (CASE WHEN D.prodid LIKE '%:%' THEN (split(D.prodid, ':'))[safe_ordinal(2)] ELSE D.prodid END) = A.raw_prod	
		
)

SELECT * FROM adicionais_view
;

-- ====================================================================================================================================================================================================
-- FIM BASE CAMPOS ADICIONAIS - INCLUINDO CAMPOS DA BASE DE PRODUTOS ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE SALES TODOS OS LEVELS - CRIADA PARA CALCULO DA DISTRIBUICAO EM TODOS OS LEVELS ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` 
OPTIONS(expiratiON_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)) AS

---toothpaste

        SELECT 
		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
		FROM 
    (
        SELECT DISTINCT
        'toothpaste'                    AS product, 
		S.start_date,
        S.end_date,
        S.market_desc, 
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number, 
		P.brand, 
		P.life_stage, 
		P.subcategory, 
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_PESO_VOLUMEN as size, 
		product_form as product_form,
		package_form as package_form, 
		normalized_hierarchy,
	    hierarchy_name
    
        FROM  `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTH2_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen       
        WHERE P.country = 'BR' AND P.subcategory = 'CREME DENTAL' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name

UNION ALL        

-- manual tb

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
        'manual tb'                     AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number, 
		P.brand, 
		P.life_stage, 
		P.subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.size, 
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMTB5_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE P.country = 'BR' AND P.subcategory = 'ESCOVAS P/DENTES' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL      
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- mouthwash

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
        'mouthwash'                     AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand , 
		P.life_stage, 
		P.subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.raw_PROMOCAO as promo_indicator,  
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.pack_size AS size,
		product_form as product_form,
		P.size as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMGA3_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE P.country = 'BR' AND P.subcategory = 'ANTISSEPTICOS BUCAIS' AND P.normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL    
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- body cleansing atual total soaps

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'total soaps'                 AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand , 
		P.raw_IDADE_DE_USO as life_stage, 
		P.subcategory,
		'' AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.promo_indicator, 
        P.raw_APRESENTACAO_REGULAR AS pack_size,
       -- P.long_desc, 
        P.raw_INTERVALO_DE_PESO AS size, 
        raw_CONSISTENCIA as product_form,
        raw_R_EMBALAGEM as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL  
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- bar soap

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'bar soap'                       AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
      --  IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number, 
		P.brand, 
		P.life_stage, 
		P.subcategory,
		'' AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_H3 as pack_size,
		--P.long_desc, 
		P.size, 
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA4_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
         WHERE P.country = 'BR' AND P.subcategory = 'SABONETES SOLIDOS' AND P.normalized_hierarchy = 'main' 
         AND P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
         --AND life_stage in ('ADULTO','INFANTIL')        
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- shower gel 
 
        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'shower gel'                     AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.raw_DISTR__NUMERICA  AS INT64))  AS numeric_dist,
        --IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand,
		P.raw_IDADE_DE_USO_H4 AS life_stage,
		raw_FORMATOS_COLGATE_H4 AS subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand,
		raw_VERSAO_AROMA_H4 AS variant,
		P.raw_EMBALAGEM_PROMOCIONAL_H4 as promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO_H4 as size, 
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'  
        AND P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- shower gel adult

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'shower gel adult'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.raw_DISTR__NUMERICA  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand,
		P.raw_IDADE_DE_USO_H4 AS life_stage,
		raw_FORMATOS_COLGATE_H4 AS subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand,
		raw_VERSAO_AROMA_H4 AS variant,
		P.raw_EMBALAGEM_PROMOCIONAL_H4 as promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO_H4 as size, 
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'  
        AND P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name

UNION ALL

-- shower gel baby

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'shower gel baby'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.raw_DISTR__NUMERICA  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand,
		P.raw_IDADE_DE_USO_H4 AS life_stage,
		raw_FORMATOS_COLGATE_H4 AS subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand,
		raw_VERSAO_AROMA_H4 AS variant,
		P.raw_EMBALAGEM_PROMOCIONAL_H4 as promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO_H4 as size, 
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE'  
        AND P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name

		
UNION ALL

-- total liquid soap 

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'total liquid soap'              AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.raw_DISTR__NUMERICA  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand,
		P.raw_IDADE_DE_USO_H4 AS life_stage,
		raw_FORMATOS_COLGATE_H4 AS subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand,
		raw_VERSAO_AROMA_H4 AS variant,
		P.raw_EMBALAGEM_PROMOCIONAL_H4 as promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO_H4 as size,
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
		LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name

		
UNION ALL

-- shampoo

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
			  SELECT DISTINCT
       'shampoo'                        AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand ,
		P.raw_IDADE_DE_USO as life_stage, 
		P.subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand, 
		P.variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size, 
		raw_TIPO_DE_TRATAMENTO as product_form,
		raw_OPCAO as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSH4_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND subcategory = 'SHAMPOOS - TOTAL' AND hierarchy_name = 'SHAMPOO - TOTAL' 
        AND normalized_hierarchy = 'main' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 
		)A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--post shampoo

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (

SELECT 
        product, 
		start_date,
        end_date,
        market_desc,
        IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 		
		Level_name,
        weighted_dist,
        numeric_dist,
       -- raw_prod,
        level_number, 
		brand, 
		life_stage, 
		subcategory,
		consumer_usage,
		subbrand,
		variant,
        promo_indicator,      
	    pack_size, 
		--long_desc,
		size, 
		product_form,
	    package_form,
		normalized_hierarchy,
	    hierarchy_name


FROM (
        SELECT DISTINCT
       'post shampoo'                   AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		CASE
        WHEN hierarchy_name = 'CONDICIONADOR - TOTAL H2'      THEN raw_FABRICANTE_H2
        WHEN hierarchy_name = 'CREME PARA PENTEAR - TOTAL H3' THEN raw_FABRICANTE_H3
        WHEN hierarchy_name = 'CR TRATAMENTO - TOTAL H4'      THEN raw_FABRICANTE_H4
        WHEN hierarchy_name = 'FINALIZADORES H5'              THEN raw_FABRICANTE_H5
        WHEN hierarchy_name = 'PROTECAO H6'                   THEN raw_FABRICANTE_H6
        END
        AS manufacturer,
		
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
        --IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , P.raw_MARCA_H2 as brand, 
		P.life_stage AS life_stage, 
		P.subcategory,
		CAST(NULL AS string) AS consumer_usage,
		raw_SUB_MARCA_H2 AS subbrand,
		raw_VERSAO_H2 AS variant,
        raw_PROMOCAO_H2 AS promo_indicator,      
	    pack_size AS pack_size, 
		--long_desc,
		raw_INTERVALO_DE_PESO_H2 AS size, 
		raw_TIPO_H2 as product_form,
	    raw_EMBALAGEM_H2 as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
 
        WHERE P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL

		)P
		
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
		
		
UNION ALL

--hair conditioner

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'hair conditioner'               AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.raw_FABRICANTE_H2) AS manufacturer,
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.raw_MARCA_H2 as brand , 
		P.life_stage AS life_stage, 
		P.subcategory,
		CAST(NULL AS string) AS consumer_usage,
		raw_SUB_MARCA_H2 AS subbrand, 
		raw_VERSAO_H2 AS variant,      
		raw_PROMOCAO_H2 AS promo_indicator,      
		pack_size AS pack_size, 
		--long_desc,
		raw_INTERVALO_DE_PESO_H2 AS size, 
		raw_TIPO_H2 as product_form,
		raw_EMBALAGEM_H2 as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG1HC8_product` AS P ON S.id = P.id
    	LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.raw_FABRICANTE_H2 = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'CONDICIONADOR - TOTAL H2' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--liquid cleaners

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'liquid cleaners'                AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand, 
		P.life_stage , 
		P.subcategory,
		P.consumer_usage,subbrand AS subbrand,
		P.product_form AS variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size,
		'' as product_form,
		P.variant as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
    	LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND subcategory = 'TOTAL CATEGORIA' AND hierarchy_name = 'TOTAL CATEGORIA H1' 
        AND normalized_hierarchy = 'main'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--disinfectant

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'disinfectant'                   AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand, 
		P.life_stage , 
		P.subcategory,
		P.consumer_usage,subbrand AS subbrand,
		P.product_form AS variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size,
		'' as product_form,
		P.variant as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR'
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--bdc

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'bdc'                            AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand, 
		P.life_stage , 
		P.subcategory,
		P.consumer_usage,subbrand AS subbrand,
		P.product_form AS variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size,
		'' as product_form,
		P.variant as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR'  
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--specialized

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'specialized'                      AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer, 
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
       -- IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand, 
		P.life_stage , 
		P.subcategory,
		P.consumer_usage,subbrand AS subbrand,
		P.product_form AS variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size,
		'' as product_form,
		P.variant as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' 
        AND	P.raw_prod is not null AND P.level_name is not null AND P.long_desc IS NOT NULL
        AND subcategory = 'TOTAL CATEGORIA'
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

--other cleaners

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'other cleaners'                 AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
      --  IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number , 
		P.brand, 
		P.life_stage , 
		P.subcategory,
		P.consumer_usage,subbrand AS subbrand,
		P.product_form AS variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR as pack_size,
		--P.long_desc, 
		P.size,
		'' as product_form,
		P.variant as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMDI2_product` AS P ON S.id = P.id
  	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'COZINHA + BANHEIRO + LIMPADOR SANITARIO + TIRA LIMO + LIMP' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
				
UNION ALL 

---LHS 

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'lhs'              AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.raw_DISTR__NUMERICA  AS INT64))  AS numeric_dist,
        --IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod ,
        P.level_number, 
		P.brand,
		P.raw_IDADE_DE_USO_H4 AS life_stage,
		raw_FORMATOS_COLGATE_H4 AS subcategory,
		CAST(NULL AS string) AS consumer_usage, 
		P.subbrand,
		raw_VERSAO_AROMA_H4 AS variant,
		P.raw_EMBALAGEM_PROMOCIONAL_H4 as promo_indicator, 
		P.pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO_H4 as size,
		'' as product_form,
		'' as package_form,
		normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSAP_product` AS P ON S.id = P.id
		LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES LIQUIDOS H4 COLGATE' 
        AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL 
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		
UNION ALL

-- total soaps kids

        SELECT 		
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
    MAX(weighted_dist) AS weighted_dist,
    MAX(numeric_dist) AS numeric_dist,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
		FROM (
        SELECT DISTINCT
       'total soaps kids'       AS product, 
		S.start_date,
        S.end_date,
        S.market_desc,
		IFNULL(C.Manufacturer_BQ,P.manufacturer) AS manufacturer,  
		P.Level_name,
   (CAST(S.weighted_dist AS INT64))  AS weighted_dist,
   (CAST(S.numeric_dist  AS INT64))  AS numeric_dist,
		--IFNULL(S.raw_prod,P.raw_prod)   AS raw_prod,
        P.level_number, 
		P.brand , 
		P.raw_IDADE_DE_USO as life_stage, 
		P.subcategory,
		'' AS consumer_usage,
		subbrand,variant,
		P.promo_indicator, 
		P.raw_APRESENTACAO_REGULAR AS pack_size,
		--P.long_desc, 
		P.raw_INTERVALO_DE_PESO AS size, 
		raw_CONSISTENCIA as product_form,
		raw_R_EMBALAGEM as package_form,normalized_hierarchy,
	    hierarchy_name
        FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_sales` S
        INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCGMSA2_product` AS P ON S.id = P.id
	    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` C 
		ON P.manufacturer = C.manufacturer_nielsen  
        WHERE country = 'BR' AND hierarchy_name = 'SABONETES SOLIDOS + LIQ H1' AND normalized_hierarchy = 'main'
		AND	P.raw_prod is not null and P.level_name is not null and P.long_desc IS NOT NULL  		
        )A
		GROUP BY
		product, 
		start_date,
        end_date,
        market_desc, 
		manufacturer, 
		Level_name,
        level_number, 
		brand, 
		life_stage, 
		subcategory, 
		consumer_usage, 
		subbrand, 
		variant,
		promo_indicator, 
		pack_size,
		size, 
		product_form,
		package_form, 
		normalized_hierarchy,
	    hierarchy_name
;
-- ====================================================================================================================================================================================================
-- FIM BASE SALES TODOS OS LEVELS - CRIADA PARA CALCULO DA DISTRIBUICAO EM TODOS OS LEVELS ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- UPDATE DISTRIBUICÕES ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 1 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist1 = B.weighted_dist, A.numeric_dist1 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.product = B.product  
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND  A.hierarchy_name = B.hierarchy_name
		AND B.level_number = 1 AND A.product in ('toothpaste', 'total soaps','hair conditioner','liquid cleaners','manual tb',
       'mouthwash','shampoo','bar soap', 'bdc','disinfectant','specialized','total soaps kids')
;

	    UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist1 = B.weighted_dist, A.numeric_dist1 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.product = B.product  
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND  A.hierarchy_name = B.hierarchy_name
		AND B.level_number = 1 AND A.product in ('post shampoo','shower gel','shower gel adult','shower gel baby','total liquid soap','lhs')
;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- FIM LEVEL 1 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 2 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   
        UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist2 = B.weighted_dist, A.numeric_dist2 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product 
		AND  A.hierarchy_name = B.hierarchy_name
		AND B.level_number = 2 AND A.product in ('toothpaste', 'total soaps','hair conditioner','liquid cleaners','manual tb',
       'mouthwash','shampoo')	
;

        UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist2 = B.weighted_dist, A.numeric_dist2 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product 
		AND B.level_number = 2 AND A.product in ('bar soap')		
;		
	
	    UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist2 = B.weighted_dist, A.numeric_dist2 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product 
        AND A.normalized_hierarchy = B.normalized_hierarchy
	    AND  A.hierarchy_name = B.hierarchy_name
 		AND B.level_number = 2 AND A.product in ('bdc','disinfectant','specialized')
;

        UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist2 = B.weighted_dist, A.numeric_dist2 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product 
	    AND  A.hierarchy_name = B.hierarchy_name
 		AND B.level_number = 2 AND A.product in ('post shampoo')
;

	    UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist2 = B.weighted_dist, A.numeric_dist2 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.life_stage = B.life_stage
		AND A.Brand = B.brand
		AND B.level_number = 4 AND A.product in ('total soaps kids')		
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 2 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 3 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist3 = B.weighted_dist, A.numeric_dist3 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.brand = B.brand 
		AND   A.market_desc = B.market_desc 
		AND   A.year =  EXTRACT(year FROM B.START_DATE) 
		AND   A.month = EXTRACT(month FROM B.START_DATE) 
		AND   A.manufacturer = B.manufacturer
		AND   A.product = B.product
		AND   B.level_number = 3 AND A.product in ('total soaps','hair conditioner','liquid cleaners','manual tb','mouthwash','post shampoo',
       'shampoo','toothpaste')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist3 = B.weighted_dist, A.numeric_dist3 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.life_stage = B.life_stage
		AND A.Brand = B.brand
		AND B.level_number = 4 AND A.product in ('total soaps kids')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist3 = B.weighted_dist, A.numeric_dist3 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.brand = B.brand  
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer 
		AND A.product = B.product 
        AND A.normalized_hierarchy = B.normalized_hierarchy
	    AND  A.hierarchy_name = B.hierarchy_name
 		AND B.level_number = 3 AND A.product in ('bdc','disinfectant','specialized')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist3 = B.weighted_dist, A.numeric_dist3 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.life_stage = B.life_stage 
		AND   A.market_desc = B.market_desc 
		AND   A.year =  EXTRACT(year FROM B.START_DATE) 
		AND   A.month = EXTRACT(month FROM B.START_DATE) 
		AND   A.manufacturer = B.manufacturer
		AND   A.product = B.product
		AND   B.level_number = 3 AND A.product in ('bar soap')		
;
    	
		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist3 = B.weighted_dist, A.numeric_dist3 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.life_stage = B.life_stage 
		AND   A.market_desc = B.market_desc 
		AND   A.year =  EXTRACT(year FROM B.START_DATE) 
		AND   A.month = EXTRACT(month FROM B.START_DATE) 
		AND   A.product = B.product
		AND A.subcategory = B.subcategory
		AND   B.level_number = 3 AND A.product in ('shower gel','shower gel baby','total liquid soap','lhs','shower gel adult')
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 3 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 4 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist4 = B.weighted_dist, A.numeric_dist4 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.manufacturer = B.manufacturer
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.life_stage = B.life_stage
		AND A.subcategory = B.subcategory
		AND B.level_number = 4 AND A.product in ('shower gel baby', 'total liquid soap', 'shower gel', 'lhs', 'shower gel adult')
;		

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist4 = B.weighted_dist, A.numeric_dist4 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.life_stage = B.life_stage
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		AND A.Brand = B.brand
		AND B.level_number = 4 AND A.product in ('total soaps','total soaps kids','manual tb')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist4 = B.weighted_dist, A.numeric_dist4 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.brand = B.brand
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.life_stage = B.life_stage
		AND B.level_number = 4 AND A.product in ('bar soap')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist4 = B.weighted_dist, A.numeric_dist4 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.consumer_usage = B.consumer_usage
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND B.level_number = 4 AND A.product in ('bdc','disinfectant','liquid cleaners','specialized')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist4 = B.weighted_dist, A.numeric_dist4 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.subbrand = B.subbrand
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND B.level_number = 4 AND A.product in ('hair conditioner','mouthwash','post shampoo','shampoo','toothpaste')
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 4 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 5 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.brand = B.brand 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.LIFE_STAGE = B.LIFE_STAGE
		AND A.subcategory = B.subcategory
		AND B.level_number = 5 AND a.product in ('shower gel baby', 'total liquid soap', 'shower gel','lhs', 'shower gel adult')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.product_form = B.product_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.LIFE_STAGE = B.LIFE_STAGE
		AND A.Brand = B.brand
		AND B.level_number = 5 AND a.product in ('total soaps', 'total soaps kids')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.subbrand = B.subbrand 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND A.consumer_usage = B.consumer_usage
		AND B.level_number = 5 AND B.product in ('bdc','disinfectant','liquid cleaners','specialized')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.subbrand = B.subbrand 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.LIFE_STAGE = B.LIFE_STAGE
		AND A.brand = B.brand
		AND B.level_number = 5 AND B.product in ('bar soap','manual tb')		
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.variant = B.variant 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.subbrand = B.subbrand
		AND B.level_number = 5 AND A.product in ('mouthwash','shampoo','toothpaste')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist5 = B.weighted_dist, A.numeric_dist5 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.package_form = B.package_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.subbrand = B.subbrand
		AND B.level_number = 5 AND A.product in ('hair conditioner','post shampoo')
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 5 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 6 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.life_stage = B.life_stage 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.subbrand = B.subbrand
		and A.variant = B.variant
		AND B.level_number = 6 AND B.product in ('toothpaste')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.subbrand = B.subbrand 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		and A.life_stage = B.life_stage
		AND A.subcategory = B.subcategory
		AND B.level_number = 6 AND A.product in ('lhs', 'shower gel adult','shower gel baby', 'total liquid soap', 'shower gel')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.variant = B.variant 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.life_stage = B.life_stage
		AND B.level_number = 6 AND A.product in ('bar soap','manual tb')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.variant = B.variant 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND A.consumer_usage = B.consumer_usage
		AND A.subbrand = B.subbrand 
		AND B.level_number = 6 AND A.product in ('bdc','disinfectant','liquid cleaners','specialized')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.package_form = B.package_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.variant = B.variant
		AND B.level_number = 6 AND B.product in ('mouthwash')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.package_form = B.package_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.variant = B.variant
		AND B.level_number = 6 AND B.product in ('shampoo')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.LIFE_STAGE = B.LIFE_STAGE
		and A.product_form = B.product_form 
		AND B.level_number = 6 AND B.product in ('total soaps','total soaps kids')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist6 = B.weighted_dist, A.numeric_dist6 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.product_form = B.product_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.subbrand = B.subbrand
		AND A.package_form = B.package_form 
		AND B.level_number = 6 AND B.product in ('hair conditioner','post shampoo')
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 6 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 7 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.variant = B.variant
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		AND A.life_stage = B.life_stage 
		AND B.level_number = 7 AND a.product in ('toothpaste')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.package_form = B.package_form 
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		AND A.product_form = B.product_form 
		AND B.level_number = 7 AND a.product in ('hair conditioner','post shampoo')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.variant = B.variant
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		and A.life_stage = B.life_stage
		AND B.level_number = 7 AND a.product in ('bar soap')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.product_form = B.product_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.variant = B.variant
		AND A.package_form = B.package_form
		AND B.level_number = 7 AND a.product in ('shampoo')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.package_form = B.package_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.LIFE_STAGE = B.LIFE_STAGE
		and A.product_form = B.product_form 
        AND A.size = B.size
		AND B.level_number = 7 AND A.product in ('total soaps','total soaps kids')	
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.package_form = B.package_form 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND A.consumer_usage = B.consumer_usage
		AND A.subbrand = B.subbrand 
		AND A.variant = B.variant 
		AND B.level_number = 7 AND A.product in ('bdc','disinfectant','liquid cleaners','specialized')	
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand 
		AND A.variant = B.variant 
        AND A.package_form = B.package_form 
		AND B.level_number = 7 AND A.product in ('mouthwash')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.promo_indicator = B.promo_indicator 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.life_stage = B.life_stage
		AND A.variant = B.variant
		AND B.level_number = 7 AND A.product in ('manual tb')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist7 = B.weighted_dist, A.numeric_dist7 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.variant = B.variant 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		and A.life_stage = B.life_stage
		AND A.subcategory = B.subcategory
		AND A.subbrand = B.subbrand 
		AND B.level_number = 7 AND A.product in ('lhs', 'shower gel adult','shower gel baby', 'total liquid soap', 'shower gel')
;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 7 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- INICIO LEVEL 8 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		and A.life_stage = B.life_stage
		AND A.subcategory = B.subcategory
		AND A.subbrand = B.subbrand 
		and A.variant = B.variant 
		AND B.level_number = 8 AND A.product in ('lhs', 'shower gel adult','shower gel baby', 'total liquid soap', 'shower gel')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.product = B.product
		AND A.manufacturer = B.manufacturer
		and A.brand = B.brand
		AND A.consumer_usage = B.consumer_usage
		AND A.subbrand = B.subbrand 
		AND A.variant = B.variant 
		AND A.package_form = B.package_form  
		AND B.level_number = 8 AND A.product in ('bdc','disinfectant','liquid cleaners','specialized')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.size = B.size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.variant = B.variant
		AND A.package_form = B.package_form
		AND A.product_form = B.product_form 
		AND B.level_number = 8 AND a.product in ('shampoo')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.promo_indicator = B.promo_indicator 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.variant = B.variant
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		and A.life_stage = B.life_stage
		AND A.size = B.size 
		AND B.level_number = 8 AND a.product in ('bar soap')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.promo_indicator = B.promo_indicator 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.variant = B.variant
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		AND A.life_stage = B.life_stage 
		and A.size = B.size 
		AND B.level_number = 8 AND a.product in ('toothpaste')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.pack_size = B.pack_size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		and A.brand = B.brand
		AND A.subbrand = B.subbrand 
		and A.life_stage = B.life_stage
		AND A.variant = B.variant
		AND A.promo_indicator = B.promo_indicator 
		AND B.level_number = 8 AND a.product in ('manual tb')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.variant = B.variant 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.package_form = B.package_form 
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand
		AND A.product_form = B.product_form 
		AND A.size = B.size 
		AND B.level_number = 8 AND a.product in ('hair conditioner','post shampoo')
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.pack_size = B.pack_size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		and A.LIFE_STAGE = B.LIFE_STAGE
		and A.product_form = B.product_form 
        AND A.size = B.size
		and A.package_form = B.package_form 
		AND B.level_number = 8 AND a.product in ('total soaps','total soaps kids')	
;

		UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`  A

		SET A.weighted_dist8 = B.weighted_dist, A.numeric_dist8 = B.numeric_dist

		FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp` B

		WHERE A.pack_size = B.pack_size 
		AND A.market_desc = B.market_desc 
		AND A.year =  EXTRACT(year FROM B.START_DATE) 
		AND A.month = EXTRACT(month FROM B.START_DATE) 
		AND A.manufacturer = B.manufacturer
		AND A.product = B.product
		AND A.brand = B.brand 
		AND A.subbrand = B.subbrand 
		AND A.variant = B.variant 
        AND A.package_form = B.package_form 
		and A.size = B.size 
		AND B.level_number = 8 AND a.product in ('mouthwash')				
;
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- FIM LEVEL 8 ---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ====================================================================================================================================================================================================
-- FIM UPDATE DISTRIBUICOES ===========================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE FINAL RETAIL: NIELSEN MARKET DATA RETAIL - NMDR E INCLUSÃO DO ALL MARKET E ALL BASKET ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
PARTITION BY start_date cluster by Year, Product, Market, Area
AS                                                            

WITH  market_view AS ( 
SELECT  start_date,
        end_date,
        market_desc,
		raw_prod,
		year,
        month,
		UPPER(product)                AS product,
		SUM(sales_units)              AS sales_units,
		SUM(units_nc)                 AS units_nc,
    	SUM(units_c)                  AS units_c,
		SUM(sales_value)              AS sales_value,
		SUM(sales_volume)             AS sales_volume,
		Level_name                    AS Level_name,	
        area                          AS area,
		market                        AS market,
		microregion                   AS microregion,	 			
		-- Share of Market	 			 
		SUM(som_value)                AS som_value,		 
		SUM(som_volume)               AS som_volume,
        -- Year to Date      
		SUM(sales_value_YTD)          AS sales_value_YTD,
		SUM(sales_units_YTD)          AS sales_units_YTD,
    		SUM(units_nc_YTD)         AS units_nc_YTD,
    	SUM(units_c_YTD)              AS units_c_YTD,
		SUM(sales_volume_YTD)         AS sales_volume_YTD,
      	-- Share of Market Year to Date
        SUM(som_value_YTD)            AS som_value_YTD,
        SUM(som_volume_YTD)           AS som_volume_YTD,
		SUM(prev_sales_value)         AS prev_sales_value,
		SUM(prev_sales_volume)        AS prev_sales_volume,
		SUM(prev_sales_units)         AS prev_sales_units,
        SUM(prev_units_nc)            AS prev_units_nc,
        SUM(prev_units_c)             AS prev_units_c,
		-- Share of Market Last Year
		SUM(prev_som_value)           AS prev_som_value,
		SUM(prev_som_volume)          AS prev_som_volume, 
		
		-- Year to Date Last Year     
		SUM(prev_sales_value_YTD)     AS prev_sales_value_YTD,
		SUM(prev_sales_volume_YTD)    AS prev_sales_volume_YTD,  
		SUM(prev_sales_units_YTD)     AS prev_sales_units_YTD,
        SUM(prev_units_nc_YTD)        AS prev_units_nc_YTD,
        SUM(prev_units_c_YTD)         AS prev_units_c_YTD,
		-- Share of Market Year to Date Last Year
		SUM(prev_som_value_YTD)       AS prev_som_value_YTD,
		SUM(prev_som_volume_YTD)      AS prev_som_volume_YTD,
		CASE WHEN SUM(VALIDADOR) <= 0 then 0 else 1 end as validador,
		-- SOA
		SUM(soa_value) AS soa_value, 
		SUM(soa_value_YTD) AS soa_value_YTD,
		
		--Informações adicionais--
		--------------------------

        manufacturer,
        long_desc,
        brand,
        subbrand,
        variant,
        subcategory,
        consumer_usage,
        product_form,
        package_form,
        life_stage,
        pack_size,
        size,
        promo_indicator, 
	    country , 
	    normalized_hierarchy,
	    hierarchy_name,
		weighted_dist9,
		numeric_dist9,
		weighted_dist8, 
		numeric_dist8,
		weighted_dist7, 
		numeric_dist7,
		weighted_dist6, 
		numeric_dist6,
	    weighted_dist5, 
		numeric_dist5,
		weighted_dist4, 
		numeric_dist4,
	    weighted_dist3, 
		numeric_dist3,
	    weighted_dist2, 
		numeric_dist2,
	    weighted_dist1,
		numeric_dist1,
		mkt_segment, 
		cp_pricetier
 
FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp` 
GROUP BY start_date,
        end_date,
        market_desc,
		raw_prod,
		year,
        month,
		product,
		Level_name,	
        area,
		market,
		microregion,
		manufacturer,
        long_desc,
        brand,
        subbrand,
        variant,
        subcategory,
        consumer_usage,
        product_form,
        package_form,
        life_stage,
        pack_size,
        size,
        promo_indicator, 
	    country , 
	    normalized_hierarchy,
	    hierarchy_name,
		weighted_dist9,
		numeric_dist9,
		weighted_dist8, 
		numeric_dist8,
		weighted_dist7, 
		numeric_dist7,
		weighted_dist6, 
		numeric_dist6,
	    weighted_dist5, 
		numeric_dist5,
		weighted_dist4, 
		numeric_dist4,
	    weighted_dist3, 
		numeric_dist3,
	    weighted_dist2, 
		numeric_dist2,
	    weighted_dist1,
		numeric_dist1,
		mkt_segment, 
		cp_pricetier

),

all_market_view AS (
        SELECT
        start_date,
        end_date,
        market_desc,
		'ALL MARKET'                  AS raw_prod,
		year,
        month,
		product,
		SUM(sales_units)              AS sales_units,
		SUM(units_nc)                 AS units_nc,
    	SUM(units_c)                  AS units_c,
		SUM(sales_value)              AS sales_value,
		SUM(sales_volume)             AS sales_volume,
		'ALL MARKET'                  AS Level_name,	
        area                          AS area,
		market                        AS market,
		microregion                   AS microregion,				
		-- Share of Market	 			 
		SUM(som_value)                AS som_value,		 
		SUM(som_volume)               AS som_volume,
        -- Year to Date      
		SUM(sales_value_YTD)          AS sales_value_YTD,
		SUM(sales_units_YTD)          AS sales_units_YTD,
    	SUM(units_nc_YTD)             AS units_nc_YTD,
    	SUM(units_c_YTD)              AS units_c_YTD,
		SUM(sales_volume_YTD)         AS sales_volume_YTD,
      	-- Share of Market Year to Date
        SUM(som_value_YTD)            AS som_value_YTD,
        SUM(som_volume_YTD)           AS som_volume_YTD,
		SUM(prev_sales_value)         AS prev_sales_value,
		SUM(prev_sales_volume)        AS prev_sales_volume,
		SUM(prev_sales_units)         AS prev_sales_units,
        SUM(prev_units_nc)            AS prev_units_nc,
        SUM(prev_units_c)             AS prev_units_c,
		-- Share of Market Last Year
		SUM(prev_som_value)           AS prev_som_value,
		SUM(prev_som_volume)          AS prev_som_volume, 
		-- Year to Date Last Year     
		SUM(prev_sales_value_YTD)     AS prev_sales_value_YTD,
		SUM(prev_sales_volume_YTD)    AS prev_sales_volume_YTD, 
		SUM(prev_sales_units_YTD)     AS prev_sales_units_YTD,
        SUM(prev_units_nc_YTD)        AS prev_units_nc_YTD,
        SUM(prev_units_c_YTD)         AS prev_units_c_YTD,		
		-- Share of Market Year to Date Last Year
		SUM(prev_som_value_YTD) AS prev_som_value_YTD,
		SUM(prev_som_volume_YTD)      AS prev_som_volume_YTD,
		CASE WHEN SUM(VALIDADOR) <= 0 then 0 else 1 end as validador,
		-- SOA
		SUM(soa_value) AS soa_value, 
		SUM(soa_value_YTD) AS soa_value_YTD,
		
		
		--Informações adicionais--
		--------------------------

        'ALL MARKET'                  AS manufacturer,
        'ALL MARKET'                  AS long_desc,
        'ALL MARKET'                  AS brand,
        'ALL MARKET'                  AS subbrand,
        'ALL MARKET'                  AS variant,
        'ALL MARKET'                  AS subcategory,
        'ALL MARKET'                  AS consumer_usage,
        'ALL MARKET'                  AS product_form,
        'ALL MARKET'                  AS package_form,
        'ALL MARKET'                  AS life_stage,
        'ALL MARKET'                  AS pack_size,
        'ALL MARKET'                  AS size,
        'ALL MARKET'                  AS promo_indicator, 
	    'ALL MARKET'                  AS country , 
	    'ALL MARKET'                  AS normalized_hierarchy,
	    'ALL MARKET'                  AS hierarchy_name,
		0                             AS  weighted_dist9,
		0                             AS  numeric_dist9,
		0                             AS  weighted_dist8, 
		0                             AS  numeric_dist8,
		0                             AS  weighted_dist7, 
		0                             AS  numeric_dist7,
		0                             AS  weighted_dist6, 
		0                             AS  numeric_dist6,
	    0                             AS  weighted_dist5, 
		0                             AS  numeric_dist5,
		0                             AS  weighted_dist4, 
		0                             AS  numeric_dist4,
	    0                             AS  weighted_dist3, 
		0                             AS  numeric_dist3,
	    0                             AS  weighted_dist2, 
		0                             AS  numeric_dist2,
	    0                             AS  weighted_dist1,
		0                             AS  numeric_dist1,
		'ALL MARKET'                  AS  mkt_segment, 
		'ALL MARKET'                  AS  cp_pricetier
		
		FROM market_view
		WHERE manufacturer IS NOT NULL 
GROUP BY         
        start_date,
        end_date,
        market_desc,
		year,
        month,
		product,
		Level_name,
        variant,
        subcategory,
        consumer_usage,
        product_form,
        package_form,
        life_stage,
        pack_size,
        size,
        promo_indicator, 
	    country , 
	    normalized_hierarchy,
	    hierarchy_name,
		area,
		market,
		microregion
		),
		
all_basket_view AS (
        SELECT
        start_date,
        end_date,
        market_desc,
		raw_prod                      AS raw_prod,
		year,
        month,
		'ALL BASKET' as product,
		SUM(sales_units)              AS sales_units,
		SUM(units_nc)                 AS units_nc,
    	SUM(units_c)                  AS units_c,
		SUM(sales_value)              AS sales_value,
		SUM(sales_volume)             AS sales_volume,
		'ALL BASKET'                  AS Level_name,	
        area                          AS area,
		market                        AS market,
		microregion                   AS microregion,				
		-- Share of Market	 			 
SAFE_DIVIDE(SUM(sales_value),   SUM(SUM(sales_value))     OVER (PARTITION BY  month, year,  microregion, market, area ORDER BY month))*100   AS som_value,			 
SAFE_DIVIDE(SUM(sales_volume),  SUM(SUM(sales_volume))    OVER (PARTITION BY  month, year,  microregion, market, area ORDER BY month))*100               AS som_volume,
        -- Year to Date      
		SUM(sales_value_YTD)          AS sales_value_YTD,
		SUM(sales_units_YTD)          AS sales_units_YTD,
    	SUM(units_nc_YTD)             AS units_nc_YTD,
    	SUM(units_c_YTD)              AS units_c_YTD,
		SUM(sales_volume_YTD)         AS sales_volume_YTD,
      	-- Share of Market Year to Date
SAFE_DIVIDE(SUM(sales_value_YTD),         SUM(SUM(sales_value_YTD))       OVER (PARTITION BY   year, month, market,area,  microregion  ORDER BY year))*100    AS som_value_YTD,
SAFE_DIVIDE(SUM(sales_volume_YTD) ,       SUM(SUM(sales_volume_YTD))      OVER (PARTITION BY   year, month, market,area,  microregion  ORDER BY year))*100    AS som_volume_YTD,
		SUM(prev_sales_value)         AS prev_sales_value,
		SUM(prev_sales_volume)        AS prev_sales_volume,
		SUM(prev_sales_units)         AS prev_sales_units,
        SUM(prev_units_nc)            AS prev_units_nc,
        SUM(prev_units_c)             AS prev_units_c,
		-- Share of Market Last Year
SAFE_DIVIDE(SUM(prev_sales_value),   SUM(SUM(prev_sales_value))       OVER (PARTITION BY  month, year,  microregion, market, area ORDER BY month))*100 AS prev_som_value,
SAFE_DIVIDE(SUM(prev_sales_volume),   SUM(SUM(prev_sales_volume))     OVER (PARTITION BY  month, year,  microregion, market, area ORDER BY month))*100 AS prev_som_volume, 
		-- Year to Date Last Year     
		SUM(prev_sales_value_YTD)     AS prev_sales_value_YTD,
		SUM(prev_sales_volume_YTD)    AS prev_sales_volume_YTD, 
		SUM(prev_sales_units_YTD)     AS prev_sales_units_YTD,
        SUM(prev_units_nc_YTD)        AS prev_units_nc_YTD,
        SUM(prev_units_c_YTD)         AS prev_units_c_YTD,		
		-- Share of Market Year to Date Last Year
SAFE_DIVIDE(SUM(prev_sales_value_YTD) ,         SUM(SUM(prev_sales_value_YTD))        OVER (PARTITION BY   year, month, market,area,  microregion  ORDER BY year))*100 AS prev_som_value_YTD,
SAFE_DIVIDE(SUM(prev_sales_volume_YTD),         SUM(SUM(prev_sales_volume_YTD))       OVER (PARTITION BY   year, month, market,area,  microregion  ORDER BY year))*100 AS prev_som_volume_YTD,
		CASE WHEN SUM(VALIDADOR) <= 0 then 0 else 1 end as validador,
		-- SOA
		0 AS soa_value, 
		0 AS soa_value_YTD,
		
		
		--Informações adicionais--
		--------------------------

         manufacturer                  AS manufacturer,
        'ALL BASKET'                  AS long_desc,
        'ALL BASKET'                  AS brand,
        'ALL BASKET'                  AS subbrand,
        'ALL BASKET'                  AS variant,
        'ALL BASKET'                  AS subcategory,
        'ALL BASKET'                  AS consumer_usage,
        'ALL BASKET'                  AS product_form,
        'ALL BASKET'                  AS package_form,
        'ALL BASKET'                  AS life_stage,
        'ALL BASKET'                  AS pack_size,
        'ALL BASKET'                  AS size,
        'ALL BASKET'                  AS promo_indicator, 
	    'ALL BASKET'                  AS country , 
	    'ALL BASKET'                  AS normalized_hierarchy,
	    'ALL BASKET'                  AS hierarchy_name,
		0                             AS  weighted_dist9,
		0                             AS  numeric_dist9,
		0                             AS  weighted_dist8, 
		0                             AS  numeric_dist8,
		0                             AS  weighted_dist7, 
		0                             AS  numeric_dist7,
		0                             AS  weighted_dist6, 
		0                             AS  numeric_dist6,
	    0                             AS  weighted_dist5, 
		0                             AS  numeric_dist5,
		0                             AS  weighted_dist4, 
		0                             AS  numeric_dist4,
	    0                             AS  weighted_dist3, 
		0                             AS  numeric_dist3,
	    0                             AS  weighted_dist2, 
		0                             AS  numeric_dist2,
	    0                             AS  weighted_dist1,
		0                             AS  numeric_dist1,
		'ALL BASKET'                  AS  mkt_segment, 
		'ALL BASKET'                  AS  cp_pricetier
		
		FROM market_view
		WHERE manufacturer IS NOT NULL AND  
		product  in ('TOOTHPASTE', 'MANUAL TB', 'MOUTHWASH', 'BAR SOAP', 'SHOWER GEL', 'LHS', 'SHAMPOO', 'POST SHAMPOO', 'LIQUID CLEANERS')

GROUP BY         
        start_date,
        end_date,
        market_desc,
		raw_prod,
		year,
        month,
		manufacturer,
		Level_name,
        variant,
        subcategory,
        consumer_usage,
        product_form,
        package_form,
        life_stage,
        pack_size,
        size,
        promo_indicator, 
	    country , 
	    normalized_hierarchy,
	    hierarchy_name,
		area,
		market,
		microregion
		)	
		
		SELECT *, MaxDate FROM market_view
		UNION ALL 
		SELECT *, MaxDate FROM all_market_view
        UNION ALL
        SELECT *, MaxDate FROM all_basket_view
;		
				
-- ====================================================================================================================================================================================================
-- FIM DA BASE FINAL RETAIL: NIELSEN MARKET DATA RETAIL - NMDR E INCLUSÃO DO ALL MARKET E ALL BASKET ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- ============================================================================================================================================================================================================
-- DELETA DADOS DE SHOWER GEL E ATUALIZA DADOS DE SHOWER GEL ADULTO PARA LHS CORRIGINDO ERRO DA BASE NIELSEN-----------------------------------------------------------------------------------------------
-- ====================================================================================================================================================================================================

DELETE FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`

WHERE  manufacturer = 'UNILEVER' AND
brand = 'DOVE' AND
subbrand = 'DOVE' AND   
variant = 'PELE SENSIVEL' AND
size = '181 A 200 G' AND 
product = 'SHOWER GEL' AND
life_stage = 'ADULTO'

;

UPDATE `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial` A	
SET A.product = 'LHS'
WHERE  manufacturer = 'UNILEVER' AND
brand = 'DOVE' AND
subbrand = 'DOVE' AND   
variant = 'PELE SENSIVEL' AND
size = '181 A 200 G' AND 
product = 'SHOWER GEL ADULT' AND
life_stage = 'ADULTO'
;

-- ================================================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- TABELA FINAL PARTICIONADA COM OS TIPOS DE PERIODOS, MENSAL, YTD, FY, QUARTER PARA CONEXÃO COM O DOMO ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- ===============================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_nielsen_retail_inicial_table` 
PARTITION BY start_date cluster by Year, Product, Market, Area
AS				
--MLY
SELECT
		start_date,
		end_date,
		market_desc,
		raw_prod,
		year,
		month,
		EXTRACT(QUARTER FROM start_date) AS Quarter,
		product,
		sales_units,
		units_nc,
    	units_c,
		
        CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc
        END AS units,
		sales_value,
		sales_volume,
		Level_name,
		area,
		market,
		microregion,
		som_value,
		som_volume,
		soa_value,
		prev_sales_value,
		prev_sales_volume,
		prev_sales_units,
        prev_units_nc,
        prev_units_c,
		CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END AS prev_units,
		prev_som_value,
		prev_som_volume,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		weighted_dist9 AS WD_9,
		numeric_dist9  AS ND_9,
		weighted_dist8 AS WD_8,
		numeric_dist8  AS ND_8,
		weighted_dist7 AS WD_7,
		numeric_dist7  AS ND_7,
		weighted_dist6 AS WD_6,
		numeric_dist6  AS ND_6,
		weighted_dist5 AS WD_5,
		numeric_dist5  AS ND_5,
		weighted_dist4 AS WD_4,
		numeric_dist4  AS ND_4,
		weighted_dist3 AS WD_3,
		numeric_dist3  AS ND_3,
		weighted_dist2 AS WD_2,
		numeric_dist2  AS ND_2,
		weighted_dist1 AS WD_1,
		numeric_dist1  AS ND_1,
		MaxDate,
       'MLY'           AS Data_Type,
		mkt_segment, 
		cp_pricetier  

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE year >= EXTRACT(YEAR FROM MaxDate)-5

UNION ALL
-- FY
        SELECT
		MAX(start_date),
        MAX(end_date),
		market_desc,
		raw_prod,
		year,
		MAX(month) as month,
		0 AS Quarter,
		product,
		SUM(sales_units) as sales_units,
		SUM(units_nc)    AS units_nc,
    	SUM(units_c)     AS units_c,
		
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc
        END) AS units,
		
		SUM(sales_value) as sales_value,
		SUM(sales_volume) as sales_volume,
		Level_name,
		area,
		market,
		microregion,
      
		SAFE_DIVIDE(SUM(sales_value),    SUM(SUM(sales_value))      OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_value,		 
		SAFE_DIVIDE(SUM(sales_volume),   SUM(SUM(sales_volume))     OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_volume,
       
			SUM(
			CASE WHEN month = 12 THEN soa_value ELSE 0 END) as soa_value,

		
		SUM(prev_sales_value) as prev_sales_value,
		SUM(prev_sales_volume) as prev_sales_volume,
		SUM(prev_sales_units) as prev_sales_units,
        SUM(prev_units_nc) as prev_units_nc,
        SUM(prev_units_c) as prev_units_c,
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END) AS prev_units,
		SUM(
			CASE WHEN month=12 THEN prev_som_value_YTD ELSE 0 END) as prev_som_value,
		SUM(
			CASE WHEN month=12 THEN prev_som_volume_YTD ELSE 0 END) as prev_som_volume,
		
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		
		MAX(
		CASE WHEN month=12 THEN weighted_dist9 ELSE 0 END) as WD_9,
		MAX(
		CASE WHEN month=12 THEN numeric_dist9 ELSE 0 END) as ND_9,
		MAX(
		CASE WHEN month=12 THEN weighted_dist8 ELSE 0 END) as WD_8,
		MAX(
		CASE WHEN month=12 THEN numeric_dist8 ELSE 0 END) as ND_8,
		MAX(
		CASE WHEN month=12 THEN weighted_dist7 ELSE 0 END) as WD_7,
		MAX(
		CASE WHEN month=12 THEN numeric_dist7 ELSE 0 END) as ND_7,
		MAX(
		CASE WHEN month=12 THEN weighted_dist6 ELSE 0 END) as WD_6,
		MAX(
		CASE WHEN month=12 THEN numeric_dist6 ELSE 0 END) as ND_6,
		MAX(
		CASE WHEN month=12 THEN weighted_dist5 ELSE 0 END) as WD_5,
		MAX(
		CASE WHEN month=12 THEN numeric_dist5 ELSE 0 END) as ND_5,
		MAX(
		CASE WHEN month=12 THEN weighted_dist4 ELSE 0 END) as WD_4,
		MAX(
		CASE WHEN month=12 THEN numeric_dist4 ELSE 0 END) as ND_4,		
		MAX(
		CASE WHEN month=12 THEN weighted_dist3 ELSE 0 END) as WD_3,	
		MAX(
		CASE WHEN month=12 THEN numeric_dist3 ELSE 0 END) as ND_3,	
		MAX(
		CASE WHEN month=12 THEN weighted_dist2 ELSE 0 END) as WD_2,		
		MAX(
		CASE WHEN month=12 THEN numeric_dist2 ELSE 0 END) as ND_2,	
		MAX(
		CASE WHEN month=12 THEN weighted_dist1 ELSE 0 END) as WD_1,	
		MAX(
		CASE WHEN month=12 THEN numeric_dist1 ELSE 0 END) as WD_1,	

		MaxDate,
       'YLY'           AS Data_Type,
		mkt_segment, 
		cp_pricetier

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE  year >= EXTRACT(YEAR FROM MaxDate)-5 and year < EXTRACT(YEAR FROM MaxDate) -- and month = 12 
AND MANUFACTURER <> 'ALL MARKET'
GROUP BY
		market_desc,
		raw_prod,
		year,
		product,
		Level_name,
		area,
		market,
		microregion,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,		
		MaxDate,
		mkt_segment, 
		cp_pricetier
		
UNION ALL
-- FY ALL MARKET------
        SELECT
		MAX(start_date),
        MAX(end_date),
		market_desc,
		raw_prod,
		year,
		MAX(month) as month,
		0 AS Quarter,
		product,
		SUM(sales_units) as sales_units,
		SUM(units_nc)    AS units_nc,
    	SUM(units_c)     AS units_c,
		
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc
        END) AS units,
		
		SUM(sales_value) as sales_value,
		SUM(sales_volume) as sales_volume,
		Level_name,
		area,
		market,
		microregion,
      
        SAFE_DIVIDE(SUM(sales_value),    SUM(SUM(sales_value))      OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_value,		 
		SAFE_DIVIDE(SUM(sales_volume),   SUM(SUM(sales_volume))     OVER (PARTITION BY  year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_volume,
       
			SUM(
			CASE WHEN month = 12 THEN soa_value ELSE 0 END) as soa_value,

		
		SUM(prev_sales_value) as prev_sales_value,
		SUM(prev_sales_volume) as prev_sales_volume,
		SUM(prev_sales_units) as prev_sales_units,
        SUM(prev_units_nc) as prev_units_nc,
        SUM(prev_units_c) as prev_units_c,
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END) AS prev_units,
		SUM(
			CASE WHEN month=12 THEN prev_som_value_YTD ELSE 0 END) as prev_som_value,
		SUM(
			CASE WHEN month=12 THEN prev_som_volume_YTD ELSE 0 END) as prev_som_volume,
		
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		
		MAX(
		CASE WHEN month=12 THEN weighted_dist9 ELSE 0 END) as WD_9,
		MAX(
		CASE WHEN month=12 THEN numeric_dist9 ELSE 0 END) as ND_9,
		MAX(
		CASE WHEN month=12 THEN weighted_dist8 ELSE 0 END) as WD_8,
		MAX(
		CASE WHEN month=12 THEN numeric_dist8 ELSE 0 END) as ND_8,
		MAX(
		CASE WHEN month=12 THEN weighted_dist7 ELSE 0 END) as WD_7,
		MAX(
		CASE WHEN month=12 THEN numeric_dist7 ELSE 0 END) as ND_7,
		MAX(
		CASE WHEN month=12 THEN weighted_dist6 ELSE 0 END) as WD_6,
		MAX(
		CASE WHEN month=12 THEN numeric_dist6 ELSE 0 END) as ND_6,
		MAX(
		CASE WHEN month=12 THEN weighted_dist5 ELSE 0 END) as WD_5,
		MAX(
		CASE WHEN month=12 THEN numeric_dist5 ELSE 0 END) as ND_5,
		MAX(
		CASE WHEN month=12 THEN weighted_dist4 ELSE 0 END) as WD_4,
		MAX(
		CASE WHEN month=12 THEN numeric_dist4 ELSE 0 END) as ND_4,		
		MAX(
		CASE WHEN month=12 THEN weighted_dist3 ELSE 0 END) as WD_3,	
		MAX(
		CASE WHEN month=12 THEN numeric_dist3 ELSE 0 END) as ND_3,	
		MAX(
		CASE WHEN month=12 THEN weighted_dist2 ELSE 0 END) as WD_2,		
		MAX(
		CASE WHEN month=12 THEN numeric_dist2 ELSE 0 END) as ND_2,	
		MAX(
		CASE WHEN month=12 THEN weighted_dist1 ELSE 0 END) as WD_1,	
		MAX(
		CASE WHEN month=12 THEN numeric_dist1 ELSE 0 END) as WD_1,	

		MaxDate,
       'YLY'           AS Data_Type,
		mkt_segment, 
		cp_pricetier

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE  year >= EXTRACT(YEAR FROM MaxDate)-5 and year < EXTRACT(YEAR FROM MaxDate) -- and month = 12 
AND MANUFACTURER = 'ALL MARKET'
GROUP BY
		market_desc,
		raw_prod,
		year,
		product,
		Level_name,
		area,
		market,
		microregion,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,		
		MaxDate,
		mkt_segment, 
		cp_pricetier
		
UNION ALL
---YTD
    SELECT
		MAX(start_date) as start_date,
        MAX(end_date) as end_date,
		market_desc,
		raw_prod,
		year,
		MAX(month) as month,
		0 AS Quarter,
		product,
		MAX(sales_units_YTD) as sales_units,
		MAX(units_nc_YTD)    AS units_nc,
    	MAX(units_c_YTD)     AS units_c,
		
		MAX(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units_YTD

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc_YTD
        END) AS units,
		
		MAX(sales_value_YTD) as sales_value,
		MAX(sales_volume_YTD) as sales_volume,
		Level_name,
		area,
		market,
		microregion,
		MAX(som_value_YTD) as som_value,
		MAX(som_volume_YTD) as som_volume,
		MAX(soa_value_YTD) AS soa_value,
		MAX(prev_sales_value_YTD) as prev_sales_value,
		MAX(prev_sales_volume_YTD) as prev_sales_volume,
		MAX(prev_sales_units_YTD) as prev_sales_units,
        MAX(prev_units_nc_YTD) as prev_units_nc,
        MAX(prev_units_c_YTD) as prev_units_c,
		MAX(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END) AS prev_units,
		MAX(prev_som_value_YTD) as prev_som_value,
		MAX(prev_som_volume_YTD) as prev_som_volume,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'		
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		MAX(weighted_dist9) AS WD_9,
		MAX(numeric_dist9)  AS ND_9,
		MAX(weighted_dist8) AS WD_8,
		MAX(numeric_dist8)  AS ND_8,
		MAX(weighted_dist7) AS WD_7,
		MAX(numeric_dist7)  AS ND_7,
		MAX(weighted_dist6) AS WD_6,
		MAX(numeric_dist6)  AS ND_6,
		MAX(weighted_dist5) AS WD_5,
		MAX(numeric_dist5)  AS ND_5,
		MAX(weighted_dist4) AS WD_4,
		MAX(numeric_dist4)  AS ND_4,
		MAX(weighted_dist3) AS WD_3,
		MAX(numeric_dist3)  AS ND_3,
		MAX(weighted_dist2) AS WD_2,
		MAX(numeric_dist2)  AS ND_2,
		MAX(weighted_dist1) AS WD_1,
		MAX(numeric_dist1)  AS ND_1,
		MaxDate,
       'YTD'           AS Data_Type,
		mkt_segment, 
		cp_pricetier

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE  year >= EXTRACT(YEAR FROM MaxDate)-5 and month = EXTRACT(MONTH FROM MaxDate)

GROUP BY
		market_desc,
		raw_prod,
		year,
		product,
		Level_name,
		area,
		market,
		microregion,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,		
		MaxDate,
		mkt_segment, 
		cp_pricetier

UNION ALL		
-- QTR: QUARTER
SELECT
		start_date,
		end_date,
		market_desc,
		raw_prod,
		year,
		month,
		Quarter,
		product,
		SUM(sales_units) AS sales_units,
		SUM(units_nc) AS units_nc,
    	SUM(units_c) AS units_c,
		SUM(units) AS units,
		SUM(sales_value) AS sales_value,
		SUM(sales_volume) AS sales_volume,
		Level_name,
		area,
		market,
		microregion,
		SAFE_DIVIDE(SUM(sales_value),    SUM(SUM(sales_value))              OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_value,		 
		SAFE_DIVIDE(SUM(sales_volume),   SUM(SUM(sales_volume))             OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_volume,
		SAFE_DIVIDE(SUM(ND_9),           SUM(SUM(ND_9))                     OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS soa_value,
		SUM(prev_sales_value),
		SUM(prev_sales_volume),
		SUM(prev_sales_units) as prev_sales_units,
        SUM(prev_units_nc) as prev_units_nc,
        SUM(prev_units_c) as prev_units_c,
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END) AS prev_units,
		SAFE_DIVIDE(SUM(prev_sales_value),    SUM(SUM(prev_sales_value))    OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS prev_som_value,		 
		SAFE_DIVIDE(SUM(prev_sales_volume),   SUM(SUM(prev_sales_volume))   OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS prev_som_volume,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		MAX(WD_9) AS WD_9,
		MAX(ND_9) AS ND_9,
		MAX(WD_8) AS WD_8,
		MAX(ND_8) AS ND_8,
		MAX(WD_7) AS WD_7,
		MAX(ND_7) AS ND_7,
		MAX(WD_6) AS WD_6,
		MAX(ND_6) AS ND_6,
		MAX(WD_5) AS WD_5,
		MAX(ND_5) AS ND_5,
		MAX(WD_4) AS WD_4,
		MAX(ND_4) AS ND_4,
		MAX(WD_3) AS WD_3,
		MAX(ND_3) AS ND_3,
		MAX(WD_2) AS WD_2,
		MAX(ND_2) AS ND_2,
		MAX(WD_1) AS WD_1,
		MAX(ND_1) AS ND_1,
		MaxDate,
        Data_Type,
		mkt_segment, 
		cp_pricetier
		
        FROM 
(
SELECT
		Date(year,1,1) AS start_date,
		Date(year,1,1) AS end_date,
		market_desc,
		raw_prod,
		year,
		0 AS month,
		EXTRACT(QUARTER FROM start_date) AS Quarter,
		product,
		sales_units,
		units_nc,
    	units_c,
		
        CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc
        END AS units,
		sales_value,
		sales_volume,
		Level_name,
		area,
		market,
		microregion,
		prev_sales_value,
		prev_sales_volume,
		prev_sales_units as prev_sales_units,
        prev_units_nc as prev_units_nc,
        prev_units_c as prev_units_c,
		CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END AS prev_units,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		weighted_dist9 AS WD_9,
		numeric_dist9  AS ND_9,
		weighted_dist8 AS WD_8,
		numeric_dist8  AS ND_8,
		weighted_dist7 AS WD_7,
		numeric_dist7  AS ND_7,
		weighted_dist6 AS WD_6,
		numeric_dist6  AS ND_6,
		weighted_dist5 AS WD_5,
		numeric_dist5  AS ND_5,
		weighted_dist4 AS WD_4,
		numeric_dist4  AS ND_4,
		weighted_dist3 AS WD_3,
		numeric_dist3  AS ND_3,
		weighted_dist2 AS WD_2,
		numeric_dist2  AS ND_2,
		weighted_dist1 AS WD_1,
		numeric_dist1  AS ND_1,
		MaxDate,
       'QTR'           AS Data_Type,
		mkt_segment, 
		cp_pricetier  

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE year >= EXTRACT(YEAR FROM MaxDate)-5 AND manufacturer <> 	'ALL MARKET'
)A

GROUP BY 
		start_date,
		end_date,
		market_desc,
		raw_prod,
		year,
		month,
		Quarter,
		product,
		Level_name,
		area,
		market,
		microregion,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		MaxDate,
        Data_Type,
		mkt_segment, 
		cp_pricetier 

UNION ALL 
---QTR ALL MARKET--------
SELECT
		start_date,
		end_date,
		market_desc,
		raw_prod,
		year,
		month,
		Quarter,
		product,
		SUM(sales_units) AS sales_units,
		SUM(units_nc) AS units_nc,
    	SUM(units_c) AS units_c,
		SUM(units) AS units,
		SUM(sales_value) AS sales_value,
		SUM(sales_volume) AS sales_volume,
		Level_name,
		area,
		market,
		microregion,
		SAFE_DIVIDE(SUM(sales_value),    SUM(SUM(sales_value))              OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_value,		 
		SAFE_DIVIDE(SUM(sales_volume),   SUM(SUM(sales_volume))             OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS som_volume,
		SAFE_DIVIDE(SUM(ND_9),           SUM(SUM(ND_9))                     OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS soa_value,
		SUM(prev_sales_value),
		SUM(prev_sales_volume),
		SUM(prev_sales_units) as prev_sales_units,
        SUM(prev_units_nc) as prev_units_nc,
        SUM(prev_units_c) as prev_units_c,
		SUM(CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END) AS prev_units,
		SAFE_DIVIDE(SUM(prev_sales_value),    SUM(SUM(prev_sales_value))    OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS prev_som_value,		 
		SAFE_DIVIDE(SUM(prev_sales_volume),   SUM(SUM(prev_sales_volume))   OVER (PARTITION BY  Quarter,year, market_desc, microregion, market, area, product ORDER BY year))*100   AS prev_som_volume,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		MAX(WD_9) AS WD_9,
		MAX(ND_9) AS ND_9,
		MAX(WD_8) AS WD_8,
		MAX(ND_8) AS ND_8,
		MAX(WD_7) AS WD_7,
		MAX(ND_7) AS ND_7,
		MAX(WD_6) AS WD_6,
		MAX(ND_6) AS ND_6,
		MAX(WD_5) AS WD_5,
		MAX(ND_5) AS ND_5,
		MAX(WD_4) AS WD_4,
		MAX(ND_4) AS ND_4,
		MAX(WD_3) AS WD_3,
		MAX(ND_3) AS ND_3,
		MAX(WD_2) AS WD_2,
		MAX(ND_2) AS ND_2,
		MAX(WD_1) AS WD_1,
		MAX(ND_1) AS ND_1,
		MaxDate,
        Data_Type,
		mkt_segment, 
		cp_pricetier
		
        FROM 
(
SELECT
		Date(year,1,1) AS start_date,
		Date(year,1,1) AS end_date,
		market_desc,
		raw_prod,
		year,
		0 AS month,
		EXTRACT(QUARTER FROM start_date) AS Quarter,
		product,
		sales_units,
		units_nc,
    	units_c,
		
        CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN sales_units

        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN units_nc
        END AS units,
		sales_value,
		sales_volume,
		Level_name,
		area,
		market,
		microregion,
		prev_sales_value,
		prev_sales_volume,
		prev_sales_units as prev_sales_units,
        prev_units_nc as prev_units_nc,
        prev_units_c as prev_units_c,
		CASE WHEN product in ('TOTAL SOAPS KIDS', 'TOTAL SOAPS','SHOWER GEL','SHOWER GEL ADULT', 'LHS',
       'SHOWER GEL BABY','TOTAL LIQUID SOAP','MANUAL TB', 'MOUTHWASH','BAR SOAP') THEN prev_sales_units
        WHEN product IN ('HAIR CONDITIONER','TOOTHPASTE', 'SHAMPOO', 'POST SHAMPOO','LIQUID CLEANERS', 
		'DISINFECTANT', 'BDC','SPECIALIZED','OTHER CLEANERS')                     THEN prev_units_nc
        END AS prev_units,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		CASE WHEN product = 'TOOTHPASTE' AND RIGHT(size,1) <> 'G'                       THEN concat(size,' ','G')
             WHEN product = 'TOOTHPASTE' AND size ='105G'                               THEN concat('105',' ','G')  
             WHEN product = 'HAIR CONDITIONER' AND size = 'ATE 5 ML'                    THEN   '0 A 5 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 5 A 15 ML'          THEN   '6 A 15 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'HAIR CONDITIONER' AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'LHS'              AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'LHS'              AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MOUTHWASH'        AND size = '1500 ML E MAIS'              THEN   'ACIMA DE 1499 ML'
             WHEN product = 'MOUTHWASH'        AND size = 'ATE 99 ML'                   THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH'        AND size = '100 ATE 199 ML'              THEN   '100 A 199 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 15 A 35 ML'         THEN   '16 A 35 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 35 A 60 ML'         THEN   '36 A 60 ML'
             WHEN product = 'SHAMPOO'          AND size = 'ACIMA DE 60 A 100 ML'        THEN   '61 A 100 ML'
             WHEN product = 'SHOWER GEL'       AND (size = '600 OU MAIS' OR size = '600 G OU MAIS') THEN   'ACIMA DE 599 G'
             WHEN product = 'SHOWER GEL'       AND size = 'ATE 80 G'                    THEN   '0 A 80 G' 
             WHEN product = 'BAR SOAP'         AND size = 'ATE 80 G'                    THEN   '0 A 80 G'
             WHEN product = 'MANUAL TB'                                                 THEN   concat(size,' ','UNID')
             WHEN product = 'SPECIALIZED'                                               THEN   concat(size,' ','ML')
             WHEN product = 'LIQUID CLEANERS'                                           THEN   concat(size,' ','ML')
             WHEN product = 'DISINFECTANT'                                              THEN   concat(size,' ','ML')
             WHEN product = 'BDC'                                                       THEN   concat(size,' ','ML')
             WHEN product = 'MOUTHWASH' AND size = '100 ATE 199 ML'                     THEN   '100 A 199 ML'
             WHEN product = 'MOUTHWASH' AND size = 'ATE 99 ML'                          THEN   '0 A 99 ML'
             WHEN product = 'MOUTHWASH' AND size = '1500 ML E MAIS'                     THEN   'ACIMA DE 1499 ML' 
             
             ELSE size END AS size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		weighted_dist9 AS WD_9,
		numeric_dist9  AS ND_9,
		weighted_dist8 AS WD_8,
		numeric_dist8  AS ND_8,
		weighted_dist7 AS WD_7,
		numeric_dist7  AS ND_7,
		weighted_dist6 AS WD_6,
		numeric_dist6  AS ND_6,
		weighted_dist5 AS WD_5,
		numeric_dist5  AS ND_5,
		weighted_dist4 AS WD_4,
		numeric_dist4  AS ND_4,
		weighted_dist3 AS WD_3,
		numeric_dist3  AS ND_3,
		weighted_dist2 AS WD_2,
		numeric_dist2  AS ND_2,
		weighted_dist1 AS WD_1,
		numeric_dist1  AS ND_1,
		MaxDate,
       'QTR'           AS Data_Type,
		mkt_segment, 
		cp_pricetier  

FROM `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.BR_Nielsen_Retail_Inicial`
WHERE year >= EXTRACT(YEAR FROM MaxDate)-5 AND manufacturer = 'ALL MARKET'
)A

GROUP BY 
		start_date,
		end_date,
		market_desc,
		raw_prod,
		year,
		month,
		Quarter,
		product,
		Level_name,
		area,
		market,
		microregion,
		manufacturer,
		long_desc,
		brand,
		subbrand,
		variant,
		subcategory,
		consumer_usage,
		product_form,
		package_form,
		life_stage,
		pack_size,
		size,
		promo_indicator,
		country,
		normalized_hierarchy,
		hierarchy_name,
		MaxDate,
        Data_Type,
		mkt_segment, 
		cp_pricetier 			
		
;
-- ================================================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- FIM DA TABELA FINAL PARTICIONADA COM OS TIPOS DE PERIODOS, MENSAL, YTD, FY, QUARTER PARA CONEXÃO COM O DOMO ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- ===============================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- TABELA: NIELSEN MARKET DATA RETAIL - CONTRIBUTION ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE   `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_nielsen_retail_inicial_contribution_table` 
AS	
with  
    manufacturer_view as (
        select product,	
        market,	
        area,	
        manufacturer,	
        year,	
        month,	
        microregion,
        Data_Type,	
        sum(sales_value) as sales_value, 
        brand, 
        subbrand,
        sum(sales_volume) as sales_volume, MaxDate 
        FROM `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_nielsen_retail_inicial_table`  
        group by product,	market,	area,	manufacturer,	year,	month,	microregion,Data_Type, brand, subbrand, MaxDate
    ),

    market_view as (
        select 
        *
        from manufacturer_view where market = 'TOTAL RE' and area = 'TOTAL BRAZIL'
    ),

    sob_view as (
        select 
        mf.year, 
        mf.month, 
        mf.product, 
        mf.market, 
        mf.area, 
        mf.manufacturer,
        mf.microregion,
        mf.Data_Type, 
        ma.brand, 
        ma.subbrand,
        SAFE_DIVIDE(mf.sales_value * 100, ma.sales_value ) as som_sales_value,
        SAFE_DIVIDE(mf.sales_volume * 100, ma.sales_volume ) as som_sales_volume, mf.MaxDate
        from manufacturer_view mf inner join market_view ma 
        on mf.product = ma.product
        and mf.manufacturer = ma.manufacturer
        and mf.year = ma.year
        and mf.month = ma.month
        and mf.microregion = ma.microregion
        and mf.Data_Type = ma.Data_Type

        
        where ma.sales_value != 0 and ma.sales_volume != 0
    ),
      sob_area_market  as ( 
        select *
        FROM sob_view
        where manufacturer = 'ALL MARKET'
    )
    ,
        som_manufacturer as (
        select product,	market,	area,	manufacturer,	year,	month,	microregion, Data_Type,	sum(sales_value) as sales_value	,sum(som_value) as som_value, brand, subbrand,
        sum(sales_volume) as sales_volume, MaxDate 
		FROM `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_nielsen_retail_inicial_table` 
        group by product,	market,	area,	manufacturer,	year,	month,	microregion,Data_Type, brand, subbrand, MaxDate
    ),
    variation_contribution_view as (
      select v1.year, v1.month, v1.product, v1.market, v1.area, v1.manufacturer, v1.microregion,
      v1.som_value as som_sales_value, v1.Data_Type, v1.brand, v1.subbrand,
      v2.som_sales_value as area_market_som_sales_value,
      SAFE_DIVIDE((v1.som_value * v2.som_sales_value), 100) as sales_value_area_market_som_contribution, v1.MaxDate
      from som_manufacturer v1 inner join sob_area_market v2
      on v1.product = v2.product
      and v1.market = v2.market
      and v1.microregion = v2.microregion
      and v1.area = v2.area
      and v1.year = v2.year
      and v1.month = v2.month
      and v1.Data_Type = v2.Data_Type
    ),
    current_prev_contribution_view as (
      select *,
      LAG(som_sales_value,1,0.0)
      OVER(PARTITION BY manufacturer, product, market, area, month,microregion, brand, subbrand, Data_Type ORDER BY year) as prev_som_sales_value,
      LAG(area_market_som_sales_value,1,0.0)
      OVER(PARTITION BY manufacturer, product, market, area, month,microregion, brand, subbrand, Data_Type ORDER BY year) as prev_area_market_som_sales_value,
      LAG(sales_value_area_market_som_contribution,1,0.0)
      OVER(PARTITION BY manufacturer, product, market, area, month,microregion, brand, subbrand, Data_Type ORDER BY year) as prev_sales_value_area_market_som_contribution
      from variation_contribution_view
    ),

    final_view as (
        select *, 
        SAFE_SUBTRACT(sales_value_area_market_som_contribution, prev_sales_value_area_market_som_contribution) as sales_value_area_market_som_contribution_abs_var
        from current_prev_contribution_view
    )

    select * from final_view

;

-- ====================================================================================================================================================================================================
-- FIM DA TABELA: NIELSEN MARKET DATA RETAIL - CONTRIBUTION ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- EXCLUSÃO DAS BASES TEMPORÁRIAS ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================

DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_product_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_area_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_sales_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_dates_possibles_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_total_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_areas_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_indicators_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_aditionais_temp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.BR_Nielsen_Retail.nmdr_salesgeral_temp`;

-- ====================================================================================================================================================================================================
-- FIM DA EXCLUSÃO DAS BASES TEMPORÁRIAS ========================================================================================================================================================================================
-- ====================================================================================================================================================================================================
-- changed
	   
  END IF;
END;
