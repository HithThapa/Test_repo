-- ####################################################################################################################################################################################################
-- ####################################################################################################################Price################################################################################
-- ############################################################ BASE NIELSEN: PnP, PRICE TRACKING E SCANTRACK #########################################################################################
-- ####################################################################################################################################################################################################
-- Fweek####################################################################################################################################################################################################

-- ===================================================================================================================================================================================================
-- ÍNDICE ============================================================================================================================================================================================
-- ===================================================================================================================================================================================================

-- DECLARAÇÃO DE VARIÁVEIS .............................................................. 0025
-- BASE PRINCIPAL  
		-- BASE TEMPORÁRIA DE PRODUTOS .................................................. 0086
		-- BASE TEMPORÁRIA DE CALENDÁRIO ................................................ 0476
		-- BASE TEMPORÁRIA DE ÁREA ...................................................... 0504
		-- BASE TEMPORÁRIA DO ANO ATUAL ................................................. 0524
		-- BASE TEMPORÁRIA DO ANO ANTERIOR .............................................. 0862
		-- INSERE DADOS NA BASE HISTÓRICA ............................................... 1205
-- SCANTRACK ............................................................................ 1409
-- PRICE TRACKING 
		-- PRICE TRACKING ............................................................... 2187		
		-- COMPARISON ................................................................... 2673
-- PNP
-- 		ELASTICIDADE .................................................................... 2760
-- 		TPR ............................................................................. 3937
-- 		INDEX ........................................................................... 4371
-- 		CRESCIMENTO ..................................................................... 4580
-- 		SUMÁRIO ......................................................................... 4934


-- ====================================================================================================================================================================================================
-- DECLARAÇÃO E DEFINIÇÃO INICIAL DE VARIÁVEIS ========================================================================================================================================================
-- ====================================================================================================================================================================================================
--BEGIN	
-- DECLARAÇÃO DE VARIÁVEIS BASE INICIAL
---------------------------------------
DECLARE MAX_DATE_TB1, MAX_DATE_TH1, MAX_DATE_MW1, MAX_DATE_TT1, MAX_DATE DATE DEFAULT CURRENT_DATE();
DECLARE MaxYear, MaxWeek, MaxMonth, WeekNum INT64; 	-- Respectivamente: Maior ano do calendário Nielsen, Maior semana do calendário Nielsen, 
													-- Maior mês do Calendário Nielsen, Número de semanas da atualização (Week ajusted).
DECLARE Check_Dates string;

-- DECLARAÇÃO DE VARIÁVEIS DE CRESCIMENTO (GROWTH)
--------------------------------------------------
DECLARE TP_RNG_IN, TB_RNG_IN, MW_RNG_IN, BS_RNG_IN, LA_RNG_IN, LK_RNG_IN, SH_RNG_IN, LH_RNG_IN,
TP_RNG_IN4, TB_RNG_IN4, MW_RNG_IN4, BS_RNG_IN4, LA_RNG_IN4, LK_RNG_IN4, SH_RNG_IN4, LH_RNG_IN4,
TP_RNG_IN5, TB_RNG_IN5, MW_RNG_IN5, BS_RNG_IN5, LA_RNG_IN5, LK_RNG_IN5, SH_RNG_IN5, LH_RNG_IN5,
TP_RNG_IN6, TB_RNG_IN6, MW_RNG_IN6, BS_RNG_IN6, LA_RNG_IN6, LK_RNG_IN6, SH_RNG_IN6, LH_RNG_IN6,
TP_RNG_IN2, TB_RNG_IN2, MW_RNG_IN2, BS_RNG_IN2, LA_RNG_IN2, LK_RNG_IN2, SH_RNG_IN2, LH_RNG_IN2,
TP_RNG_IN1, TB_RNG_IN1, MW_RNG_IN1, BS_RNG_IN1, LA_RNG_IN1, LK_RNG_IN1, SH_RNG_IN1, LH_RNG_IN1
 INT64;
DECLARE TP_RNG_IN05, TB_RNG_IN05, MW_RNG_IN05, BS_RNG_IN05, LA_RNG_IN05, LK_RNG_IN05, SH_RNG_IN05, LH_RNG_IN05 FLOAT64;

-- DECLARAÇÃO DE VARIÁVEL INDEX
-------------------------------
DECLARE Rank_id, Rank_Size INT64 DEFAULT 1;

-- DECLARAÇÃO DE VARIÁVEIS DE SCANTRACK
---------------------------------------
DECLARE FYLen, YTDLen, MonthLen, WeekLen, WeekLYOffset INT64;
DECLARE MAX_DATE_SCAN DATE;

-- ====================================================================================================================================================================================================
-- FIM DECLARAÇÃO E DEFINIÇÃO INICIAL DE VARIÁVEIS ====================================================================================================================================================
-- ====================================================================================================================================================================================================

SET MAX_DATE_TB1 = (SELECT MAX(end_date) AS end_date FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_sales` WHERE (end_date >= DATE(EXTRACT(YEAR FROM CURRENT_DATE())-1, 1, 1)));
SET MAX_DATE_TH1 = (SELECT MAX(end_date) AS end_date FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_sales` WHERE (end_date >= DATE(EXTRACT(YEAR FROM CURRENT_DATE())-1, 1, 1)));
SET MAX_DATE_MW1 = (SELECT MAX(end_date) AS end_date FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_sales` WHERE (end_date >= DATE(EXTRACT(YEAR FROM CURRENT_DATE())-1, 1, 1)));
SET MAX_DATE_TT1 = (SELECT MAX(end_date) AS end_date FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_sales` WHERE (end_date >= DATE(EXTRACT(YEAR FROM CURRENT_DATE())-1, 1, 1)));

-- PEGA A MAIOR DATA ENTRE TODAS AS BASES
-----------------------------------------
SET MAX_DATE =
(
    SELECT MAX(end_date) AS end_date
    FROM (
        SELECT MAX_DATE_TB1 AS end_date
        UNION ALL
        SELECT MAX_DATE_TH1 AS end_date
        UNION ALL
        SELECT MAX_DATE_MW1 AS end_date
        UNION ALL
        SELECT MAX_DATE_TT1 AS end_date
    )
);

-- PEGA A MAIOR SEMANA, ANO E MÊS DE ACORDO COM A MAIOR DATA
------------------------------------------------------------
SET MaxWeek = (SELECT week_ajusted FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar` WHERE EndDateBQ = MAX_DATE);
SET MaxYear = (SELECT Year FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar` WHERE  EndDateBQ = MAX_DATE);
SET MaxMonth = (SELECT Month FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar` where EndDateBQ = MAX_DATE);

-- VERIFICAR SE AS DATAS SÃO IGUAIS
-----------------------------------
 /*SET Check_Dates = (SELECT CASE WHEN  
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_sales`) = 
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_sales`) AND
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_sales`) = 
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_sales`) AND
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_sales`) =
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_sales`) AND
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_sales`) = 
                      (SELECT MAX(end_date) as data FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_sales`)              
 THEN 'SIM' ELSE 'NÃO' END) ;

--------------------------------------------------------------------------------------------------------------------------------------------------------
--  SE AS DATAS FOREM IGUAIS E A MAIOR DATA SEJA DIFERENTE DA DATA QUE JÁ EXISTE NA BASE, RODE TODO O SCRIPT
--  SE UMA DESSAS AFIRMAÇÕES FOREM FALSA PARE O SCRIPT
-- *SE ALGUMA BASE NÃO ESTIVER ATUALIZADA E PEDIREM PARA RODAR O SCRIPT, BASE COMENTAR O IF LOGO ABAIXO*----------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
IF (Check_Dates = 'SIM' and MAX_DATE <> (SELECT MAX(MaxDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`)) THEN
*/  

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ############################################################ BASE NIELSEN: TABELAS TEMPORÁRIAS #####################################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################

-- ====================================================================================================================================================================================================
-- BASE CONSOLIDADA DE PRODUTOS =======================================================================================================================================================================
-- ====================================================================================================================================================================================================
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Produtos_temp`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)) AS

WITH 
SCAN_PRODUCT AS (

-- BASE TOOTHBRUSH 
	SELECT DISTINCT
        'TOOTHBRUSH'                		   AS Category,               
		'TB'								   AS Short_Category,		   	
		UPPER(TRIM(country))		           AS Country,					
		UPPER(TRIM(manufacturer))   		   AS Manufacturer,			                           
        UPPER(TRIM(long_desc))      		   AS Long_desc,				                       
        UPPER(TRIM(cast (brand as string)))    AS Brand,					                      
        UPPER(TRIM(cast (subbrand as string))) AS SubBrand,				                            
		UPPER(TRIM(cast (variant as string)))  AS Variant,						                    
		UPPER(TRIM(cast (size as string)))	   AS Size,					 
		'NAO CONSTA'						   AS Packing,						    			
		UPPER(TRIM(product_form))		       AS Product_Form,				        		
		UPPER(TRIM(life_stage))				   AS Life_Stage,				
		UPPER(TRIM(consumer_usage))			   AS Consumer_usage,			
		UPPER(TRIM(benefit))				   AS Global_segment,		    
		UPPER(TRIM(oph_global_price_tier)) 	   AS Global_PriceTier,		   
		UPPER(TRIM(level_name))				   AS Level_name,				
		level_number				           AS Level_number,			    
		UPPER(TRIM(id))             		   AS id,						           				
		UPPER(TRIM(item))           		   AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))           AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		    AS short_desc,					 
	UPPER(TRIM(promo_indicator))           	   AS promo_indicator
	
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_product`
   
    WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TB1%'

UNION ALL

-- BASE TOOTHPASTE 
	SELECT  DISTINCT
        'TOOTHPASTE'              			    AS Category,               
		'TP'							        AS Short_Category,
		UPPER(TRIM(country))		            AS Country,					
		UPPER(TRIM(manufacturer))   		    AS Manufacturer,			
        UPPER(TRIM(long_desc))      		    AS Long_desc,				
        UPPER(TRIM(cast (brand as string)))     AS Brand,				    	
        UPPER(TRIM(cast (subbrand as string)))  AS SubBrand,					
	    UPPER(TRIM(cast (variant as string)))   AS Variant,						
	    UPPER(TRIM(cast (size as string)))	    AS Size,					
		'NAO CONSTA'					      	AS Packing,					
		UPPER(TRIM(product_form))			    AS Product_Form,					
		UPPER(TRIM(life_stage))				    AS Life_Stage,                      
		UPPER(TRIM(consumer_usage))			    AS Consumer_usage,
		UPPER(TRIM(benefit))				    AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	    AS Global_PriceTier,
		UPPER(TRIM(level_name))				    AS Level_name,              
		level_number						    AS Level_number,
		UPPER(TRIM(id))             		    AS id,						
		UPPER(TRIM(item))           		    AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))           AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		    AS short_desc,					
    UPPER(TRIM(promo_indicator))           	    AS promo_indicator
   
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_product`

	WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TH1%'

UNION ALL

-- BASE MOUTHWASH 
	SELECT DISTINCT
        'MOUTHWASH'    	           			    AS Category,                
		'MW'							        AS Short_Category, 
		UPPER(TRIM(country))		            AS Country,					                      
		UPPER(TRIM(manufacturer))   		    AS Manufacturer,			
        UPPER(TRIM(long_desc))      		    AS Long_desc,				
        UPPER(TRIM(cast (brand as string)))     AS Brand,					
        UPPER(TRIM(cast (subbrand as string)))  AS SubBrand,				
		UPPER(TRIM(cast (variant as string)))   AS Variant,					
		UPPER(TRIM(cast (size as string)))	    AS Size,					
		'NAO CONSTA'						    AS Packing,					
		UPPER(TRIM(product_form))			    AS Product_Form,					
		UPPER(TRIM(life_stage))				    AS Life_Stage,                   
		UPPER(TRIM(consumer_usage))			    AS Consumer_usage,
		UPPER(TRIM(benefit))				    AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	    AS Global_PriceTier,
		UPPER(TRIM(level_name))				    AS Level_name,              
		level_number						    AS Level_number,
		UPPER(TRIM(id))             		    AS id,						
		UPPER(TRIM(item))           		    AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))           AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		    AS short_desc,					
    UPPER(TRIM(promo_indicator))           	    AS promo_indicator	      
			  
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_product`

    WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4MW1%'

UNION ALL

-- BASE TOTAL SOAPS 
	SELECT DISTINCT
        'TOTAL SOAPS'							 AS Category,                
		'TOTAL SOAPS'							 AS Short_Category,          
		UPPER(TRIM(country))		             AS Country,				 
		UPPER(TRIM(manufacturer))   		     AS Manufacturer,			 		       
        UPPER(TRIM(long_desc))      		     AS Long_desc,				               
		UPPER(TRIM(cast (brand as string)))      AS Brand,					                 
        UPPER(TRIM(cast (subbrand as string)))   AS SubBrand,				               
		UPPER(TRIM(cast (variant as string)))    AS Variant,						      
		UPPER(TRIM(cast (size as string)))	     AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		     AS Packing,				  		
		UPPER(TRIM(product_form))			     AS Product_Form,				               	
		UPPER(TRIM(life_stage))				     AS Life_Stage,                                 
		UPPER(TRIM(consumer_usage))			     AS Consumer_usage,
		UPPER(TRIM(benefit))				     AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	     AS Global_PriceTier,
		UPPER(TRIM(level_name))				     AS Level_name,                             
		level_number						     AS Level_number,
		UPPER(TRIM(id))             		     AS id,						
		UPPER(TRIM(item))           		     AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))            AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		     AS short_desc,				
    UPPER(TRIM(raw_PROMOCAO_H2))           	     AS promo_indicator    
		
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
    WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%' 

UNION ALL

-- BASE BAR SOAPS [TT1] 
	SELECT DISTINCT
        'BAR SOAPS'						         AS Category,                
		'BS'								     AS Short_Category,          
		UPPER(TRIM(country))		             AS Country,				 
		UPPER(TRIM(manufacturer))   		     AS Manufacturer,			 		       
        UPPER(TRIM(long_desc))      		     AS Long_desc,				               
		UPPER(TRIM(cast (brand as string)))      AS Brand,					                  
        UPPER(TRIM(cast (subbrand as string)))   AS SubBrand,				               
		UPPER(TRIM(cast (variant as string)))    AS Variant,						       
		UPPER(TRIM(cast (size as string)))	     AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		     AS Packing,				 		
		UPPER(TRIM(product_form))			     AS Product_Form,				               	
		UPPER(TRIM(life_stage))				     AS Life_Stage,                                 
		UPPER(TRIM(consumer_usage))			     AS Consumer_usage,
		UPPER(TRIM(benefit))				     AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	     AS Global_PriceTier,
		UPPER(TRIM(level_name))				     AS Level_name,                            
		level_number						     AS Level_number,
		UPPER(TRIM(id))             		     AS id,						
		UPPER(TRIM(item))           		     AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))            AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		     AS short_desc,				
    UPPER(TRIM(raw_PROMOCAO_H2))           	     AS promo_indicator

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
 
	WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'SOLIDO'

UNION ALL

-- BASE SHOWER GEL TOTAL 
	SELECT DISTINCT
        'SG TOTAL'							   AS Category,                
		'SG TOTAL'							   AS Short_Category,
		UPPER(TRIM(country))		           AS Country,					
		UPPER(TRIM(manufacturer))   		   AS Manufacturer,	                          		
        UPPER(TRIM(long_desc))      		   AS Long_desc,				              
        UPPER(TRIM(cast (brand as string)))    AS Brand,					              
        UPPER(TRIM(cast (subbrand as string))) AS SubBrand,				                  
		UPPER(TRIM(cast (variant as string)))  AS Variant,						          
		UPPER(TRIM(cast (size as string)))	   AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		   AS Packing,						
		UPPER(TRIM(product_form))			   AS Product_Form,					               
		UPPER(TRIM(life_stage))				   AS Life_Stage,                                   
		UPPER(TRIM(consumer_usage))			   AS Consumer_usage,
		UPPER(TRIM(benefit))				   AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	   AS Global_PriceTier,
		UPPER(TRIM(level_name))				   AS Level_name,                              
		level_number						   AS Level_number,
		UPPER(TRIM(id))             		   AS id,						
		UPPER(TRIM(item))           		   AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))          AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		   AS short_desc,					
    UPPER(TRIM(raw_PROMOCAO_H2))           	   AS promo_indicator
		
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
    WHERE
        ((level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND raw_R_EMBALAGEM = 'NAO CONSTA'
        --AND (size <> '600 OU MAIS' OR manufacturer = 'CP')
		AND (NOT size IN ('2000 OU MAIS','1000 A 1999 G'))
        AND life_stage = 'ADULTO' AND UPPER(TRIM(item)) <> '7891150095670') 
      OR
        ((level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND life_stage = 'INFANTIL')
	
UNION ALL

-- BASE SHOWER GEL ADULTO [TT1] 
	SELECT DISTINCT
        'SG ADULT'						       AS Category,                	
		'SG ADULT'							   AS Short_Category,
		UPPER(TRIM(country))		           AS Country,					
		UPPER(TRIM(manufacturer))   		   AS Manufacturer,	                          		
        UPPER(TRIM(long_desc))      		   AS Long_desc,				              
        UPPER(TRIM(cast (brand as string)))    AS Brand,					              
        UPPER(TRIM(cast (subbrand as string))) AS SubBrand,				                  
		UPPER(TRIM(cast (variant as string)))  AS Variant,						           
		UPPER(TRIM(cast (size as string)))	   AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		   AS Packing,						
		UPPER(TRIM(product_form))			   AS Product_Form,					               
		UPPER(TRIM(life_stage))				   AS Life_stage,                                   
		UPPER(TRIM(consumer_usage))			   AS Consumer_usage,
		UPPER(TRIM(benefit))				   AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	   AS Global_PriceTier,
		UPPER(TRIM(level_name))				   AS Level_name,                              
		level_number						   AS Level_number,
		UPPER(TRIM(id))             		   AS id,						
		UPPER(TRIM(item))           		   AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))          AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		   AS short_desc,					
    UPPER(TRIM(raw_PROMOCAO_H2))           	   AS promo_indicator
 
 
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
    
	WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND raw_R_EMBALAGEM = 'NAO CONSTA'
        --AND (size <> '600 OU MAIS' OR manufacturer = 'CP')
		AND (NOT size IN ('2000 OU MAIS','1000 A 1999 G'))
        AND life_stage = 'ADULTO' AND UPPER(TRIM(item)) <> '7891150095670'

UNION ALL

-- BASE SHOWER GEL KIDS 
	SELECT DISTINCT
        'SG KIDS'						       AS Category,          		
		'SG KIDS'							   AS Short_Category,
		UPPER(TRIM(country))		           AS Country,					
		UPPER(TRIM(manufacturer))   		   AS Manufacturer,			                    
        UPPER(TRIM(long_desc))      		   AS Long_desc,				                
        UPPER(TRIM(cast (brand as string)))    AS Brand,					                
        UPPER(TRIM(cast (subbrand as string))) AS SubBrand,				                   
		UPPER(TRIM(cast (variant as string)))  AS Variant,						            
		UPPER(TRIM(cast (size as string)))	   AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		   AS Packing,						
		UPPER(TRIM(product_form))			   AS Product_Form,					                 
		UPPER(TRIM(life_stage))				   AS Life_Stage,                                	 
		UPPER(TRIM(consumer_usage))			   AS Consumer_usage,
		UPPER(TRIM(benefit))				   AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	   AS Global_PriceTier,
		UPPER(TRIM(level_name))				   AS Level_name,                           	 
		level_number						   AS Level_number,
		UPPER(TRIM(id))             		   AS id,				 		
		UPPER(TRIM(item))           		   AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))          AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		   AS short_desc,					
    UPPER(TRIM(raw_PROMOCAO_H2))           	   AS promo_indicator

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`

	WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND life_stage = 'INFANTIL'

UNION ALL

-- BASE LHS [TT1] 	
	SELECT DISTINCT
        'LHS'							        AS Category,        		
		'LHS'								    AS Short_Category,
		UPPER(TRIM(country))		            AS Country,					
		UPPER(TRIM(manufacturer))   		    AS Manufacturer,			                   
        UPPER(TRIM(long_desc))      		    AS Long_desc,				                    
        UPPER(TRIM(cast (brand as string)))     AS Brand,					                    
        UPPER(TRIM(cast (subbrand as string)))  AS SubBrand,				                    
		UPPER(TRIM(cast (variant as string)))   AS Variant,						                
		UPPER(TRIM(cast (size as string)))	    AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		    AS Packing,				
		UPPER(TRIM(product_form))			    AS Product_Form,					                    
		UPPER(TRIM(life_stage))				    AS Life_Stage,                                 		
		UPPER(TRIM(consumer_usage))			    AS Consumer_usage, 
		UPPER(TRIM(benefit))				    AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	    AS Global_PriceTier,
		UPPER(TRIM(level_name))				    AS Level_name,                            		
		level_number						    AS Level_number,
		UPPER(TRIM(id))             		    AS id,					  	
		UPPER(TRIM(item))           		    AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))           AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		    AS short_desc,					
    UPPER(TRIM(raw_PROMOCAO_H2))           	    AS promo_indicator
  
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
    
    WHERE
      (
      (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND life_stage = 'ADULTO'
        AND raw_R_EMBALAGEM <> 'NAO CONSTA'
      )
       OR
      (
      (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
      AND (long_desc IS NOT NULL)
      AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
      AND id LIKE 'BRCG4TT1%'
      AND product_form = 'LIQUIDO'
      AND life_stage = 'ADULTO'
      AND raw_R_EMBALAGEM = 'NAO CONSTA'
      --AND (size = '600 OU MAIS' AND manufacturer<>'CP')
	  AND size IN ('2000 OU MAIS','1000 A 1999 G')
      )
	  
	  UNION ALL
	  ---EAN ADICIONADO A BASE DE LHS ERRO NIELSEN 7891150095670
	  	SELECT DISTINCT
        'LHS'						           AS Category,                	
		'LHS'							       AS Short_Category,
		UPPER(TRIM(country))		           AS Country,					
		UPPER(TRIM(manufacturer))   		   AS Manufacturer,	                          		
        UPPER(TRIM(long_desc))      		   AS Long_desc,				              
        UPPER(TRIM(cast (brand as string)))    AS Brand,					              
        UPPER(TRIM(cast (subbrand as string))) AS SubBrand,				                  
		UPPER(TRIM(cast (variant as string)))  AS Variant,						           
		UPPER(TRIM(cast (size as string)))	   AS Size,					
		UPPER(TRIM(raw_R_EMBALAGEM))		   AS Packing,						
		UPPER(TRIM(product_form))			   AS Product_Form,					               
		UPPER(TRIM(life_stage))				   AS Life_stage,                                   
		UPPER(TRIM(consumer_usage))			   AS Consumer_usage,
		UPPER(TRIM(benefit))				   AS Global_segment,
		UPPER(TRIM(oph_global_price_tier)) 	   AS Global_PriceTier,
		UPPER(TRIM(level_name))				   AS Level_name,                              
		level_number						   AS Level_number,
		UPPER(TRIM(id))             		   AS id,						
		UPPER(TRIM(item))           		   AS ean_desc,
    UPPER(TRIM(normalized_hierarchy))          AS normalized_hierarchy,
    UPPER(TRIM(short_desc))           		   AS short_desc,					
    UPPER(TRIM(raw_PROMOCAO_H2))           	   AS promo_indicator
 
 
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product`
    
	WHERE (level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
        AND (long_desc IS NOT NULL)
        AND (item IS NOT NULL OR (manufacturer='PL' AND long_desc='PL'))
        AND id LIKE 'BRCG4TT1%'
        AND product_form = 'LIQUIDO'
        AND raw_R_EMBALAGEM = 'NAO CONSTA'
        --AND (size <> '600 OU MAIS' OR manufacturer = 'CP')
		AND (NOT size IN ('2000 OU MAIS','1000 A 1999 G'))
        AND life_stage = 'ADULTO' AND UPPER(TRIM(item)) = '7891150095670'
 ),

 BASE_PRODUCT AS(
SELECT *,
(CASE
        WHEN LENGTH(ean_desc)<13
            THEN CONCAT(LEFT('0000000000000', 13-LENGTH(ean_desc)),ean_desc)
        ELSE ean_desc END) 
											AS ean_desc_KEY
	FROM SCAN_PRODUCT
),
----------------------------------------------------------------------------------------------------------------
---------------------------------------------BASE DE-PARA PPG---------------------------------------------------
----------------------------------------------------------------------------------------------------------------
BASE_SEGMENTOS AS (
    SELECT DISTINCT
 		UPPER(TRIM(MKT_Segment))			        AS MKT_Segment,
		UPPER(TRIM(mkt_ppg))				        AS mkt_ppg,
		UPPER(TRIM(local_segment))			        AS local_segment, 
		UPPER(TRIM(RCD_segment))			        AS RCD_Segment,
		UPPER(TRIM(CP_PriceTier))			        AS CP_PriceTier,
		UPPER(TRIM(ean_desc))				        AS ean_desc,
	
        (CASE
        WHEN RIGHT(Long_desc,3) IN('BP1','BP2','BP3','BP4','BP5','BP6','BP7','BP8') AND
        LENGTH(TRIM(CAST(ean_wo_BP AS STRING)))<=13
            THEN CONCAT(TRIM(CAST(CAST(ean_wo_BP AS int64) AS STRING FORMAT '0000000000000')), RIGHT(Long_desc,3))
        WHEN RIGHT(Long_desc,3) IN('BP1','BP2','BP3','BP4','BP5','BP6','BP7','BP8') AND
        LENGTH(TRIM(CAST(ean_wo_BP AS STRING)))=14
            THEN CONCAT(TRIM(CAST(CAST(ean_wo_BP AS int64) AS STRING FORMAT '00000000000000')), RIGHT(Long_desc,3))
        WHEN LENGTH(TRIM(CAST(ean_wo_BP AS STRING)))<=13
            THEN TRIM(CAST(CAST(ean_wo_BP AS int64) AS STRING FORMAT '0000000000000'))
        ELSE TRIM(CAST(ean_wo_BP AS STRING)) END) 
											AS ean_wo_BP,   	
		
		1   AS Category_Rank,  		
		'ATIVO'								AS Status

    FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Product`
)	
	SELECT  P.Category                  		AS Category,       		
		P.Short_Category					    AS Short_Category,
		P.Country					            AS Country,					
		P.Manufacturer                          AS Manufacturer,			                   
        P.Long_desc                     	    AS Long_desc,				                    
        P.Brand                 			    AS Brand,					                    
        P.Subbrand                  			AS SubBrand,				                    
		P.Variant                   		    AS Variant,						               
		P.Size              	    			AS Size,					
		P.Packing                   		    AS Packing,				
		P.Product_form                          AS Product_Form,					            
		P.Life_stage                    	    AS Life_Stage,                                  
		P.consumer_usage					    AS Consumer_usage, 
		P.Global_segment					    AS Global_segment,
		P.Global_PriceTier				 	    AS Global_PriceTier,
		P.Level_name                            AS Level_name,                            		
		P.Level_number                          AS Level_number,
		P.id 			             		    AS id,					  	
		IFNULL(S.ean_wo_BP, P.ean_desc)  		AS ean_wo_BP,
			
		S.MKT_Segment, 
		S.mkt_ppg, 
		S.local_segment, 
		S.RCD_segment, 
		S.CP_PriceTier, 
		IFNULL(S.Status,'PREENCHER') 			AS Status,
        S.Category_Rank,
        P.normalized_hierarchy,
        P.short_desc,
		P.promo_indicator
  
	FROM BASE_PRODUCT P
	LEFT JOIN BASE_SEGMENTOS S
		ON P.ean_desc_KEY = S.ean_wo_BP
		;
-- ====================================================================================================================================================================================================
-- FIM BASE CONSOLIDADA DE PRODUTOS ===================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE CALENDÁRIO NIELSEN ============================================================================================================================================================================
-- ====================================================================================================================================================================================================
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)) AS

WITH MaxMonth AS(
SELECT Month, Year, MAX(EndDateBQ) as Date FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar`
GROUP BY Month,Year
)  
SELECT  StartDate,
        EndDate,
        RefDate,
        Week,
        A.Month,
        Quarter,
        A.Year,
        EndDateBQ      AS DateKey,
        'Real'         AS DateType,
        data_scan_msg,
		week_ajusted,
        B.Date AS MaxMonthDate  
FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar` A
LEFT JOIN MaxMonth B ON A.Year=B.Year AND A.Month = B.Month;

-- ====================================================================================================================================================================================================
-- FIM BASE CALENDÁRIO NIELSEN ========================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE DE-PARA ÁREA ==================================================================================================================================================================================
-- ====================================================================================================================================================================================================
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.AreaDePara_temp`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)) AS
SELECT DISTINCT
    UPPER(TRIM(MKT_LDESC))   AS Descricao_Mercado, 
    UPPER(TRIM(Area_desc))   AS Area,              
    UPPER(TRIM(RE_desc))     AS RE,                
    CASE WHEN UPPER(TRIM(RE_desc)) = 'TOTAL RE' THEN 'TOTAL RE' ELSE UPPER(TRIM(RE_desc))  END   AS RE1,               -- RE_desc --Modificado All por Brasil
    UPPER(TRIM(State_desc))  AS UF                 

FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_RE_Area`
WHERE (UPPER(TRIM(RE_desc)) IN ('TOTAL RE', 'C&C', 'DRUGS', 'H&S', 'SUPER', 'HIPER', 'SUPER GDE', 'SUPER PEQ'))
  --AND (UPPER(TRIM(State_desc)) = 'BR')
  AND (UPPER(TRIM(Area_desc)) != '') AND (UPPER(TRIM(Area_desc)) IS NOT NULL)
  AND (UPPER(TRIM(MKT_LDESC)) != '') AND (UPPER(TRIM(MKT_LDESC)) IS NOT NULL);

-- ====================================================================================================================================================================================================
-- FIM BASE DE-PARA ÁREA ==============================================================================================================================================================================
-- ====================================================================================================================================================================================================

--=====================================================================================================================================================================================================
-- BASE DE VENDAS ATUALIZAÇÃO ÚLTIMOS N SEMANAS =======================================================================================================================================================
-- ====================================================================================================================================================================================================

-- APAGA ÚLTIMOS REGISTROS
--------------------------
SET WeekNum = 8; --Número de semanas para atualização.

DELETE FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` 
WHERE CASE WHEN MaxWeek - WeekNum >=0
      THEN Year = MaxYear AND week_ajusted >= MaxWeek - WeekNum
      ELSE Year = MaxYear OR(Year=MaxYear-1 AND week_ajusted>= 53- ABS(MaxWeek - WeekNum))
      END;

-- TABELA TEMPORÁRIA PARA ÚLTIMOS REGISTROS
-------------------------------------------
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1` 
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)) AS

SELECT
    -- Chaves
    A.id       				      	AS id,      	   
    A.Descricao_Mercado       	    AS Market,    	

    -- Dados de Mercado
    M.Area        		    		AS Area,
    M.RE        			   	   	AS RE,
    M.RE1                      	    AS RE1, 
	M.UF,
    -- Dados de Produto
    P.Manufacturer        	    	AS Manufacturer,
    IFNULL(P.Brand,
    P.manufacturer)    	        	AS Brand,
    IFNULL(P.SubBrand, IFNULL(P.Brand,
    P.manufacturer))    	      	AS SubBrand,
    P.Category            	      	AS Category, 
    P.Variant             	     	AS Variant,
    P.Size                	    	AS Size,
    P.Packing             	    	AS Packing,
    P.Product_Form        	    	AS Product_Form,
    P.Life_Stage           	    	AS Life_Stage,
    P.ean_wo_BP                 	AS EAN,         
    P.Category_Rank        			AS PPGRank,      
    P.Short_Category              	AS Short_Category,
    P.Country                     	AS Country,
    P.Long_desc                   	AS Product,    
    P.Consumer_usage,
    P.Global_segment,  
    P.Global_PriceTier, 
    P.Level_name,
    P.Level_number,
    P.MKT_Segment                	AS Segment,   
    P.mkt_ppg                    	AS PPG,       
    P.local_segment,
    P.RCD_segment, 
    P.CP_PriceTier                	AS PriceTier, 
    P.Status,                
    -- Dados de Data
    Data_Alvo                     	AS EndDate,   
    MAX_DATE                      	AS MaxDate,
    MaxMonthDate					AS MaxMonthDate,
	DATE(Year,Month,1)          	AS RefDate,
    Year                       		AS Year,
    Month                      		AS Month,
    Quarter                    		AS Quarter,
    Week                       		AS Week,
    data_scan_msg                 	AS data_scan_msg,
	week_ajusted 					AS week_ajusted,			
    
	-- Dados sumarizados
    Vendas_Em_Valor               	AS Value,    
    Vendas_Em_Unidades            	AS Units,     
    Vendas_Em_Volume  	          	AS Volume,    
    TPR_Em_Valor                  	AS TPR_Value, 
    TPR_Em_Unidades               	AS TPR_Units, 
    TPR_Em_Volume    	          	AS TPR_Volume,
   			

-- Dados fictícios do ano anterior
    0       						AS ValueLY,    
    0       						AS UnitsLY,     
    0 	    						AS VolumeLY,   
    0       						AS TPR_ValueLY, 
    0       						AS TPR_UnitsLY,
    0    							AS TPR_VolumeLY,


---ND e WD

    ND                              AS ND,
    WD                              AS WD,
    ND_TPR                          AS ND_TPR,
    ND_TPR                          AS WD_TPR,        
	P.normalized_hierarchy,
    P.short_desc,
    start_date,	
    P.promo_indicator

FROM (

-- BASE TOOTHBRUSH [TB1]
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,			
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,        
        V.end_date                            AS Data_Alvo,                
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,       

        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,          

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,   

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,            

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                      
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,        
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR
	   
       FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_sales`  V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
    ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN C.Year = MaxYear AND C.week_ajusted >= MaxWeek - WeekNum
			ELSE C.Year = MaxYear OR(C.Year=MaxYear-1 AND C.week_ajusted>= 53-ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)       
		AND (P.id LIKE 'BRCG4TB1%')


-- BASE TOOTHPASTE [TH1]
    UNION ALL
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg, 
		C.week_ajusted 						  AS week_ajusted,		
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,        
        V.end_date                            AS Data_Alvo,                
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,       
 
        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,          

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,    

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,            

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                       
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,        
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR
 
    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_sales` V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
    ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN C.Year = MaxYear AND C.week_ajusted >= MaxWeek - WeekNum
			ELSE C.Year = MaxYear OR(C.Year=MaxYear-1 AND C.week_ajusted>= 53 - ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)      
		AND (P.id LIKE 'BRCG4TH1%')                


-- BASE MOUTHWASH [MW1]
    UNION ALL
	
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,        
        V.end_date                            AS Data_Alvo,                
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,       

        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,          

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,    

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,            

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                       
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,        
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_sales` V
		INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_product` P
		ON (UPPER(TRIM(V.id)) = P.id)
        INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
        ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN C.Year = MaxYear AND C.week_ajusted >= MaxWeek - WeekNum
			ELSE C.Year = MaxYear OR(C.Year=MaxYear-1 AND C.week_ajusted>= 53 - ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)       
		AND (P.id LIKE 'BRCG4MW1%')               


    UNION ALL

-- BASE SABONETES SOLIDOS + LIQ [TT1]
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,          
        V.end_date                            AS Data_Alvo,                  
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,         

        V.sales_units                         AS Vendas_Em_Unidades_Total,   
        V.sales_value                         AS Vendas_Em_Valor,           
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,           

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,     

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,             

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,              

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                        
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,         
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_sales` V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
	INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
        ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN C.Year = MaxYear AND C.week_ajusted >= MaxWeek - WeekNum
			ELSE C.Year = MaxYear OR(C.Year=MaxYear-1 AND C.week_ajusted>= 53 - ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)        
		AND (P.id LIKE 'BRCG4TT1%')) A

    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Produtos_temp` P
     ON (A.id = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.AreaDePara_temp` M
     ON A.Descricao_Mercado = M.Descricao_Mercado;
     
--------------------------------------------------------------------------------------------------------------------------------------------------
-- TABELA TEMPORÁRIA PARA O ANO ANTERIOR
--------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2` 
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)) AS
   
SELECT
    -- Chaves
    A.id       				      	AS id,      	    
    A.Descricao_Mercado           	AS Market,    	

    -- Dados de Mercado
    M.Area        		    	  	AS Area,
    M.RE        			      	AS RE,
    M.RE1                         	AS RE1, 
	M.UF,
    -- Dados de Produto
    P.Manufacturer        	      	AS Manufacturer,
    IFNULL(P.Brand,
    P.manufacturer)    	          	AS Brand,
    IFNULL(P.SubBrand, IFNULL(P.Brand,
    P.manufacturer))    	      	AS SubBrand,
    P.Category            	      	AS Category, 
    P.Variant             	     	AS Variant,
    P.Size                	     	AS Size,
    P.Packing             	      	AS Packing,
    P.Product_Form        	    	AS Product_Form,
    P.Life_Stage           	      	AS Life_Stage,
    P.ean_wo_BP                   	AS EAN,       
    P.Category_Rank        		  	AS PPGRank,     
    P.Short_Category              	AS Short_Category,
    P.Country                     	AS Country,
    P.Long_desc                   	AS Product,     
    P.Consumer_usage,
    P.Global_segment,  
    P.Global_PriceTier, 
    P.Level_name,
    P.Level_number,
    P.MKT_Segment                  	AS Segment,  
    P.mkt_ppg                      	AS PPG,     
    P.local_segment,
    P.RCD_segment, 
    P.CP_PriceTier                 	AS PriceTier,
    P.Status,                
    
	-- Dados de Data
	DATE_ADD(DATE_ADD(DATE_SUB(DATE(EXTRACT(YEAR FROM A.Data_Alvo), 1, 1), INTERVAL (EXTRACT(DAYOFWEEK FROM DATE(EXTRACT(YEAR FROM A.Data_Alvo), 1, 1)) -2) DAY), 
		INTERVAL EXTRACT(WEEK FROM A.Data_Alvo) WEEK), INTERVAL DATE_DIFF(DATE_ADD(A.Data_Alvo,INTERVAL 1 YEAR),A.Data_Alvo, DAY)+(357-DATE_DIFF(DATE_ADD(A.Data_Alvo,INTERVAL 1 YEAR),
		A.Data_Alvo, DAY)) DAY)		AS EndDate,   
    MAX_DATE                       	AS MaxDate,
    DATE_ADD(DATE_ADD(DATE_SUB(DATE(EXTRACT(YEAR FROM A.MaxMonthDate), 1, 1), INTERVAL (EXTRACT(DAYOFWEEK FROM DATE(EXTRACT(YEAR FROM A.MaxMonthDate), 1, 1)) -2) DAY), 
		INTERVAL EXTRACT(WEEK FROM A.MaxMonthDate) WEEK), INTERVAL DATE_DIFF(DATE_ADD(A.MaxMonthDate,INTERVAL 1 YEAR),A.MaxMonthDate, DAY)+(357-DATE_DIFF(DATE_ADD(A.MaxMonthDate,INTERVAL 1 YEAR),
		A.MaxMonthDate, DAY)) DAY)	AS MaxMonthDate,
	
	DATE(A.Year+1,A.Month,1)       	AS RefDate,
    A.Year  + 1                    	AS Year,
    A.Month                        	AS Month,
    A.Quarter                      	AS Quarter,
    
	0	                         	AS Week,
	DATE(EXTRACT(YEAR FROM data_scan_msg)+1, EXTRACT(MONTH FROM data_scan_msg), 1) AS data_scan_msg,
	week_ajusted 					AS week_ajusted,
	
    -- Dados sumarizados
    0    							AS Value,     
    0    							AS Units,     
    0  	 							AS Volume,    
    0    							AS TPR_Value, 
    0    							AS TPR_Units, 
    0    							AS TPR_Volume,

---------------------------------------------

-- Dados sumarizados
    Vendas_Em_Valor    				AS ValueLY,    
    Vendas_Em_Unidades 				AS UnitsLY,     
    Vendas_Em_Volume   				AS VolumeLY,   
    TPR_Em_Valor       				AS TPR_ValueLY, 
    TPR_Em_Unidades    				AS TPR_UnitsLY,
    TPR_Em_Volume      				AS TPR_VolumeLY,

 ---ND e WD

    0                              	AS ND,
    0                              	AS WD,
    0                          		AS ND_TPR,
    0                          		AS WD_TPR,        
	P.normalized_hierarchy,
    P.short_desc,
	
	DATE_ADD(DATE_ADD(DATE_SUB(DATE(EXTRACT(YEAR FROM A.start_date), 1, 1), INTERVAL (EXTRACT(DAYOFWEEK FROM DATE(EXTRACT(YEAR FROM A.start_date), 1, 1)) -2) DAY), 
	INTERVAL EXTRACT(WEEK FROM A.start_date) WEEK), INTERVAL DATE_DIFF(DATE_ADD(A.start_date,INTERVAL 1 YEAR),A.start_date, DAY)+(357-DATE_DIFF(DATE_ADD(A.start_date,INTERVAL 1 YEAR),
	A.start_date, DAY)) DAY)		AS start_date,
	P.promo_indicator
	
FROM (
-- BASE TOOTHBRUSH [TB1]
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg, 
		C.week_ajusted 						  AS week_ajusted,        
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,        
        V.end_date                            AS Data_Alvo,                
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,       

        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,         

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,    

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,           

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                     
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,        
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR
		
       FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_sales`  V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TB1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
   	INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
        ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN Year = MaxYear-1 AND week_ajusted >= MaxWeek - WeekNum
			ELSE (Year = MaxYear-1 AND week_ajusted<=MaxWeek) 
			OR(Year=MaxYear-2 AND week_ajusted>= 53-ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)      
		AND (P.id LIKE 'BRCG4TB1%')


-- BASE TOOTHPASTE [TH1]
    UNION ALL
	
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,        
        V.end_date                            AS Data_Alvo,             
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,      
 
        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,          

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,    

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,            

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                       
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,       
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_sales` V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TH1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
   	INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
      ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN Year = MaxYear-1 AND week_ajusted >= MaxWeek - WeekNum
			ELSE (Year = MaxYear-1 AND week_ajusted<=MaxWeek) 
			OR(Year=MaxYear-2 AND week_ajusted>= 53-ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)       
		AND (P.id LIKE 'BRCG4TH1%')                


-- BASE MOUTHWASH [MW1]
    UNION ALL
	
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,       
        V.end_date                            AS Data_Alvo,               
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,       

        V.sales_units                         AS Vendas_Em_Unidades_Total, 
        V.sales_value                         AS Vendas_Em_Valor,          
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,         

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,    

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,            

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,             

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                       
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,        
        numeric_dist                          AS ND,
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_sales` V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4MW1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
      ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN Year = MaxYear-1 AND week_ajusted >= MaxWeek - WeekNum
			ELSE (Year = MaxYear-1 AND week_ajusted<=MaxWeek) 
			OR(Year=MaxYear-2 AND week_ajusted>= 53-ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)       
		AND (P.id LIKE 'BRCG4MW1%')                


UNION ALL

-- BASE SABONETES SOLIDOS + LIQ [TT1]
    SELECT
        C.Year								  AS Year,
		C.Month 							  AS Month,
		C.Week 								  AS Week,
		C.Quarter 							  AS Quarter,
        C.MaxMonthDate						  AS MaxMonthDate,
		C.data_scan_msg                       AS data_scan_msg,
		C.week_ajusted 						  AS week_ajusted,
		UPPER(TRIM(V.market_desc))            AS Descricao_Mercado,          
        V.end_date                            AS Data_Alvo,                 
        V.start_date                          as start_date,
        (CASE
            WHEN (LEFT(P.long_desc, 2) = 'CB')
            THEN 0
            ELSE V.sales_units
        END)                                  AS Vendas_Em_Unidades,        

        V.sales_units                         AS Vendas_Em_Unidades_Total,   
        V.sales_value                         AS Vendas_Em_Valor,            
        V.sales_volume                        AS Vendas_Em_Volume,
        (CASE
            WHEN ((LEFT(P.long_desc, 2) = 'CB') OR (V.reduced_price_sales_units IS NULL))
            THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades,          

        (CASE
            WHEN (V.reduced_price_sales_units IS NULL) THEN 0
            ELSE V.reduced_price_sales_units
        END)                                  AS TPR_Em_Unidades_Total,     

        (CASE
            WHEN (V.reduced_price_sales_volume IS NULL) THEN 0
            ELSE V.reduced_price_sales_volume
        END)                                  AS TPR_Em_Volume,             

        (CASE
            WHEN (V.reduced_price_sales_value IS NULL) THEN 0
            ELSE (V.reduced_price_sales_value)
         END)                                 AS TPR_Em_Valor,              

        UPPER(TRIM(P.item))                   AS EAN,
        UPPER(TRIM(V.id))                     AS id,                        
        UPPER(TRIM(P.long_desc))              AS Descricao_Produto,         
        numeric_dist                          AS ND,  
        weighted_dist                         AS WD,
        raw_DISTR__NUMERICA__tpr_only_        AS ND_TPR,
        reduced_price_sales_weighted_dist     AS WD_TPR

    FROM `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_sales` V
    INNER JOIN `cp-saa-prod-ext-data-ingst.nielsen.BRCG4TT1_product` P
      ON (UPPER(TRIM(V.id)) = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.Calendario_temp` C
      ON (V.end_date =C.DateKey) 
          
	WHERE 
		CASE WHEN MaxWeek - WeekNum >=0
			THEN Year = MaxYear-1 AND week_ajusted >= MaxWeek - WeekNum
			ELSE (Year = MaxYear-1 AND week_ajusted<=MaxWeek) 
			OR(Year=MaxYear-2 AND week_ajusted>= 53-ABS(MaxWeek - WeekNum))
		END
		AND (P.level_name = "ITEM" OR (manufacturer='PL' AND long_desc='PL'))
		AND (P.long_desc IS NOT NULL)         
		AND (P.id LIKE 'BRCG4TT1%')) A

    LEFT OUTER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Produtos_temp` P
    ON (A.id = P.id)
    INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.AreaDePara_temp` M
    ON A.Descricao_Mercado = M.Descricao_Mercado;

-------------------------------------------------------
----------------ATUALIZA MAXDATE-----------------------
-------------------------------------------------------
UPDATE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` A	
SET A.MaxDate = MAX_DATE
where A.MaxDate is not null;
-------------------------------------------------------------------
---------------CORRIGE NOME DOS FABRICANTES------------------------
-------------------------------------------------------------------
UPDATE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1` A
	SET A.Manufacturer=B.Manufacturer_BQ
	FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` B
	WHERE A.Manufacturer = B.Manufacturer_Nielsen;
	
UPDATE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2` A
	SET A.Manufacturer=B.Manufacturer_BQ
	FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Manufacturer` B
	WHERE A.Manufacturer = B.Manufacturer_Nielsen;

-- ====================================================================================================================================================================================================
-- INSERE DADOS NA BASE HISTÓRICA =====================================================================================================================================================================
-- ====================================================================================================================================================================================================
INSERT INTO `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`

SELECT 
    id,      	   
    Market,    	    
    -- Dados de Mercado
    Area,
    RE,
    RE1						AS RE_Market, 
	UF,
    -- Dados de Produto
    Manufacturer,
    Brand,
    SubBrand,
    Category, 
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,             
    PPGRank,          
    Short_Category,
    Country,
    Product,          
    Consumer_usage,
    Global_segment,  
    Global_PriceTier, 
    Level_name,
    Level_number,
    Segment,         
    PPG,             
    local_segment,
    RCD_segment, 
    PriceTier,       
    Status,                
	
	EndDate as EndDate,  
    MaxDate,
    RefDate,
    Year,
    Month,
    
	Quarter,
    MAX(Week) as Week,
    MAX(data_scan_msg) 	 AS data_scan_msg,
	current_datetime('-03:00') AS datetime_update,
    
	-- Dados sumarizados
    SUM(Value)           AS Value,   
    SUM(Units)           AS Units,     
    SUM(Volume)  	     AS Volume,   
    SUM(TPR_Value)       AS TPR_Value, 
    SUM(TPR_Units)       AS TPR_Units, 
    SUM(TPR_Volume)    	 AS TPR_Volume,
(CASE
        WHEN (SUM(TPR_Units) IS NULL OR SUM(TPR_Units) = 0) THEN SUM(Units)
        ELSE (SUM(Units) - SUM(TPR_Units))
     END)       AS Base_Units,    			

     (CASE
        WHEN (SUM(TPR_Value) IS NULL OR SUM(TPR_Value) = 0) THEN SUM(Value)
        ELSE (SUM(Value) - SUM(TPR_Value))
     END)       AS Base_Value,    			

     (CASE
        WHEN (SUM(TPR_Volume) IS NULL OR SUM(TPR_Volume) = 0) THEN SUM(Volume)
        ELSE (SUM(Volume) - SUM(TPR_Volume))
     END)       AS Base_Volume, 


    SUM(ValueLY)         AS ValueLY,
	SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN ValueLY  ELSE 0 END)   	AS ValueLY_YTD,    
    SUM(UnitsLY)         AS UnitsLY,    
    SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN UnitsLY ELSE 0  END)		AS UnitsLY_YTD,
    SUM(VolumeLY)        AS VolumeLY , 
    SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN VolumeLY ELSE 0  END)  	AS VolumeLY_YTD, 
    SUM(TPR_ValueLY)     AS TPR_ValueLY, 
    SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_ValueLY  ELSE 0  END)	AS TPR_ValueLY_YTD, 
    
    SUM(TPR_UnitsLY)     AS TPR_UnitsLY,
    SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_UnitsLY   ELSE 0  END) AS TPR_UnitsLY_YTD, 
    SUM(TPR_VolumeLY)    AS TPR_VolumeLY, 
    SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_VolumeLY  ELSE 0  END) AS TPR_VolumeLY_YTD, 

	(CASE
        WHEN (SUM(TPR_UnitsLY) IS NULL OR SUM(TPR_UnitsLY) = 0) THEN SUM(UnitsLY)
        ELSE (SUM(UnitsLY) - SUM(TPR_UnitsLY))
     END)       AS Base_UnitsLY, 
	
	(CASE
        WHEN (SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_UnitsLY ELSE 0 END) IS NULL 
			OR SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_UnitsLY ELSE 0 END) = 0) 
		THEN SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN UnitsLY ELSE 0  END)
        ELSE (SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN UnitsLY ELSE 0  END) 
		- SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_UnitsLY   ELSE 0 END))
	END)     AS Base_UnitsLY_YTD, 

	(CASE
        WHEN (SUM(TPR_ValueLY) IS NULL OR SUM(TPR_ValueLY) = 0) THEN SUM(ValueLY)
        ELSE (SUM(ValueLY) - SUM(TPR_ValueLY))
	END)       AS Base_ValueLY, 

	(CASE
        WHEN ( SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <=MaxWeek THEN TPR_ValueLY  ELSE 0  END) IS NULL 
		OR  SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <=MaxWeek THEN TPR_ValueLY  ELSE 0  END) = 0) 
		THEN SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN ValueLY  ELSE 0 END)
        ELSE (SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN ValueLY  ELSE 0 END) 
		- SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_ValueLY  ELSE 0  END))
	END)   		AS Base_ValueLY_YTD,    			

	(CASE
        WHEN (SUM(TPR_VolumeLY) IS NULL OR SUM(TPR_VolumeLY) = 0) THEN SUM(VolumeLY)
        ELSE (SUM(VolumeLY) - SUM(TPR_VolumeLY))
	END)       AS Base_VolumeLY,

	(CASE
        WHEN (SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_VolumeLY  ELSE 0  END) IS NULL 
		OR SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_VolumeLY  ELSE 0  END) = 0) 
		THEN SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN VolumeLY ELSE 0  END)
        ELSE (SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <=MaxWeek THEN VolumeLY ELSE 0  END) 
		- SUM(CASE WHEN Month <= MaxMonth AND week_ajusted <= MaxWeek THEN TPR_VolumeLY  ELSE 0  END))
	END)         AS Base_VolumeLY_YTD,


 ---ND e WD

    SUM(ND)                         AS ND,
    SUM(WD)                         AS WD,
    SUM(ND_TPR)                     AS ND_TPR,
    SUM(ND_TPR)                     AS WD_TPR,
    MAX(MaxMonthDate)				AS MaxMonthDate,
	week_ajusted 				 	AS week_ajusted,	
	normalized_hierarchy,
    short_desc,
    start_date,
	promo_indicator
 
FROM 
(
--============================================================================================================================================================================================================================================
--AGRUPA ANO ATUAL COM ANO ANTERIOR E AGRUPA AREAS II + III E IV +V---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--============================================================================================================================================================================================================================================

SELECT A.* except (Area, Market, Level_name,short_desc),Area, Market,Level_name,short_desc FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1` A
UNION ALL
SELECT a.* except (Area, Market,Level_name,short_desc),Area, Market,Level_name,short_desc FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2` A
UNION ALL
select A.* except (Area, Market,Level_name,short_desc),'AREA II + III' AS Area, 'AREA II + III' AS Market, 'ITEM' AS Level_name, '' AS short_desc
         FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1` A
		 WHERE AREA IN ( 'AREA II', 'AREA III') 
         UNION ALL
select A.* except (Area, Market,Level_name,short_desc),'AREA II + III' AS Area, 'AREA II + III' AS Market, 'ITEM' AS Level_name, '' AS short_desc
         FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2` A
		 WHERE AREA IN ( 'AREA II', 'AREA III') 
         UNION ALL
select A.* except (Area, Market,Level_name,short_desc),'AREA IV + V' AS Area, 'AREA IV + V' AS Market, 'ITEM' AS Level_name, '' AS short_desc
         FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1` A
		 WHERE AREA IN ( 'AREA IV', 'AREA V') 
UNION ALL
select A.* except (Area, Market,Level_name,short_desc),'AREA IV + V' AS Area, 'AREA IV + V' AS Market, 'ITEM' AS Level_name, '' AS short_desc
         FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2` A
		 WHERE AREA IN ( 'AREA IV', 'AREA V') 

)

WHERE Category is not null 

-- Alteração devido a virada de Ano.
--and  EndDate <= MaxDate and Year <= EXTRACT(YEAR FROM MAX_DATE)

GROUP BY
    id,      	    
    Market,    	
    Area,
    RE,
    RE1,
    UF, 	
    Manufacturer,
    Brand,
    SubBrand,
    Category, 
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,       
    PPGRank,   
    Short_Category,
    Country,
    Product,  
    Consumer_usage,
    Global_segment,  
    Global_PriceTier, 
    Level_name,
    Level_number,
    Segment, 
    PPG,
    local_segment,
    RCD_segment, 
    PriceTier,
    Status,                
    MaxDate,
	RefDate,
    Year,
    Month,
    Quarter,
    week_ajusted,
	normalized_hierarchy,
    short_desc,
    start_date,
	EndDate,
	promo_indicator
	;

-- ====================================================================================================================================================================================================
-- FIM INSERE DADOS DA BASE HISTÓRICA =================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE SCAN PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack_inicial_table`
PARTITION BY EndDate cluster by Manufacturer, Category, RE, Area
AS

SELECT 
    id,      	   
    -- Dados de Mercado
    Market,    	    
    Area,
    RE,
    RE_Market, 
	UF,
    -- Dados de Produto
    Manufacturer,
    Brand,
    SubBrand,
    CASE WHEN EAN = '7891150095670' THEN 'LHS' ELSE Category END AS Category , 
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,             
    PPGRank,          
    Short_Category,
    Country,
    Product,          
    Consumer_usage,
    Global_segment,  
    Global_PriceTier, 
    Level_name,
    Level_number,
    Segment,         
    PPG,             
    local_segment,
    RCD_segment, 
    PriceTier,       
    Status,                
    -- Dados de Data
    EndDate,  
    MaxDate,
    RefDate,
    Year,
    Month,
    Quarter,
    Week,
    data_scan_msg,
	datetime_update,
    MaxMonthDate,
    -- Dados de vendas
    Value,   
    Units,     
    Volume,   
    TPR_Value, 
    TPR_Units, 
    TPR_Volume,
    Base_Units,    			
    Base_Value,    			
    Base_Volume, 

-- Dados de Vendas do Ano Anterior
    ValueLY,
    ValueLY_YTD,    
    UnitsLY,
    UnitsLY_YTD,    
    VolumeLY,
    VolumeLY_YTD,   
    TPR_ValueLY,
    TPR_ValueLY_YTD, 
    TPR_UnitsLY,
    TPR_UnitsLY_YTD,
    TPR_VolumeLY,
    TPR_VolumeLY_YTD, 
    Base_UnitsLY,
    Base_UnitsLY_YTD,    			
    Base_ValueLY,
    Base_ValueLY_YTD,    			
    Base_VolumeLY,
    Base_VolumeLY_YTD,
	ND,
    WD,
    ND_TPR,
    WD_TPR,
	promo_indicator

    FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
	WHERE UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
	; 

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE SCAN PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ############################################################ BASE NIELSEN: SCANTRACK ###############################################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################

-- Quantidade de anos completos (Full Years) a serem exibidos
SET FYLen = 8;
-- Quantidade de anos até a data (Year To Date) a serem exibidos
SET YTDLen = 8;
-- Quantidade de meses a serem exibidos
SET MonthLen = 100;
-- Quantidade de semanas a serem eibidas
SET WeekLen = 1000;
-- Define o deslocamento de semana para o comparativo com o ano anterior (números negativos deslocam a semana do ano anterior para trás e positivos para frente)
SET WeekLYOffset = -1;
SET MAX_DATE_SCAN = (SELECT MAX(MaxMonthDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`);

-- ====================================================================================================================================================================================================
-- BASE FINAL SCANTRACK ===============================================================================================================================================================================
-- ====================================================================================================================================================================================================
CREATE OR REPLACE TABLE  `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`
AS
-- VENDAS DO ANO ANTERIOR (FULL YEAR) ------------------------------------------
--------------------------------------------------------------------------------
SELECT
      -- Tipo de data
    'FY'                  AS Date_type,
    -- Dados de Mercado
    Market                AS Market,
    Area                  AS Area,
    RE_Market             AS RE,
    Manufacturer          AS Manufacturer,
    Brand                 AS Brand,
    SubBrand              AS SubBrand,
    PPG                   AS PPG,
    Segment               AS Segment,
    Category              AS Category,
    Product               AS Product,
    Variant               AS Variant,
    Size                  AS Size,
    Packing               AS Packing,
    Product_Form          AS Product_Form,--verificar
    Life_Stage            AS Life_Stage,
    EAN                   AS EAN,
    PPGRank               AS PPGRank,
    PriceTier             AS PriceTier,
	RCD_Segment,
	local_segment,

    -- Dados de Data
    MAX_DATE              AS MaxDate,
    Year                  AS Year,
    DATE(Year, 1, 1)      AS EndDate,
    DATE(Year, 1, 1)      AS RefDate,
    1                     AS Month,
    1                     AS Quarter,     
    1                     AS Week,
    MAX(data_scan_msg)    AS data_scan_msg,
	MAX(MaxMonthDate)	  AS MaxMonthDate,

    SUM(Value)            AS Value, 
    SUM(Units)            AS Units,	
    SUM(Volume)           AS Volume,   
    SUM(TPR_Value)        AS TPR_Value, 
    SUM(TPR_Units)        AS TPR_Units, 
    SUM(TPR_Volume)       AS TPR_Volume,
    SUM(Base_Units)       AS Base_Units,    			
    SUM(Base_Value)       AS Base_Value,    			
    SUM(Base_Volume)      AS Base_Volume, 
    SUM(ValueLY)          AS ValueLY,     
    SUM(UnitsLY)          AS UnitsLY,    
    SUM(VolumeLY)         AS VolumeLY,   
    SUM(TPR_ValueLY)      AS TPR_ValueLY, 
    SUM(TPR_UnitsLY)      AS TPR_UnitsLY,
    SUM(TPR_VolumeLY)     AS TPR_VolumeLY, 
    SUM(Base_UnitsLY)     AS Base_UnitsLY,    			
    SUM(Base_ValueLY)     AS Base_ValueLY,    			
    SUM(Base_VolumeLY)    AS Base_VolumeLY,

	SUM(SUM(Value)) OVER(PARTITION BY Year, Area, RE_Market, Category)           AS Total_Sales,
    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales,
	----------------------------------------SOM TPR E BASE----------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
	SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_Value),
	SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales_Base,
    ----------------------------------------------------------------------------------------------------
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)         AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY,
	-----------------------------------------SOM TPR E BASE LY------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY),
	SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY),
	SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_Base,
	----------------------------------------------------------------------------------------------------
	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)          AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume,
	-----------------------------------------SOM VOLUME TPR E BASE--------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
	SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
	SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume_Base,
	----------------------------------------------------------------------------------------------------

    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)        AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)	AS SOM_Volume_LY,
	-----------------------------------------SOM VOLUME TPR E BASE LY-----------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY),
	SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)	AS SOM_Volume_LY_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY),
	SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)	AS SOM_Volume_LY_Base,
	----------------------------------------------------------------------------------------------------
    CASE WHEN DATE(Year, 12, 31) > MAX_DATE THEN 0 ELSE 1 END 			AS CompleteInterval,
	normalized_hierarchy,
    short_desc,
    DATE(Year, 1, 1)      AS start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator	
		
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`	
  WHERE
    Year BETWEEN EXTRACT(YEAR FROM MAX_DATE_SCAN)-FYLen AND EXTRACT(YEAR FROM MAX_DATE_SCAN)-1
	AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
  GROUP BY 
  Market,                
  Area,
  RE_Market,
  Manufacturer,
  Brand,
  SubBrand,
  PPG,
  Segment,
  Category,
  Product,
  Variant,
  Size,
  Packing,
  Product_Form,
  Life_Stage,
  EAN,
  PPGRank,
  PriceTier,
  RCD_Segment,
  local_segment,
  Year,
  normalized_hierarchy,
  short_desc,
  level_name,
  promo_indicator

UNION ALL

-- VENDAS DO ANO YEAR TO DATE (YTD) --------------------------------------------
--------------------------------------------------------------------------------
SELECT
    -- Tipo de data
    'YTD'                                       AS Date_type,
    -- Dados de Mercado
    Market                                      AS Market,
    Area                                        AS Area,
    RE_Market                                   AS RE,
    Manufacturer                                AS Manufacturer,
    Brand                                       AS Brand,
    SubBrand                                    AS SubBrand,
    PPG                                         AS PPG,
    Segment                                     AS Segment,
    Category                                    AS Category,
    Product                                     AS Product,
    Variant                                     AS Variant,
    Size                                        AS Size,
    Packing                                     AS Packing,
    Product_Form                                AS Product_Form,
    Life_Stage                                  AS Life_Stage,
    EAN                                         AS EAN,
    PPGRank                                     AS PPGRank,
    PriceTier                                   AS PriceTier,
	RCD_Segment,
	local_segment,

    -- Dados de Data
    MAX_DATE                                    AS MaxDate,
    Year                                        AS Year,
    DATE(Year, 1, 1)       						AS EndDate,
    DATE(Year, 1, 1)                            AS RefDate,
    MAX(MAX(Month)) OVER (PARTITION BY Year)         AS Month,
    EXTRACT(QUARTER FROM DATE(Year, MAX(MAX(Month)) 
		OVER (PARTITION BY Year), 1))   		AS Quarter,
    EXTRACT(WEEK FROM DATE(Year, MAX(MAX(Month)) 
		OVER (PARTITION BY Year), 1))      		AS Week,
    MAX(data_scan_msg)                          AS data_scan_msg,
	MAX(MaxMonthDate)	  						AS MaxMonthDate,

    -- Dados ano
    SUM(Value)            						AS Value, 
    SUM(Units)            						AS Units,	
    SUM(Volume)           						AS Volume,   
    SUM(TPR_Value)        						AS TPR_Value, 
    SUM(TPR_Units)        						AS TPR_Units, 
    SUM(TPR_Volume)       						AS TPR_Volume,
    SUM(Base_Units)       						AS Base_Units,    			
    SUM(Base_Value)       						AS Base_Value,    			
    SUM(Base_Volume)      						AS Base_Volume, 
    SUM(ValueLY_YTD)          					AS ValueLY,     
    SUM(UnitsLY_YTD)          					AS UnitsLY,    
    SUM(VolumeLY_YTD)         					AS VolumeLY,   
    SUM(TPR_ValueLY_YTD)      					AS TPR_ValueLY, 
    SUM(TPR_UnitsLY_YTD)      					AS TPR_UnitsLY,
    SUM(TPR_VolumeLY_YTD)     					AS TPR_VolumeLY, 
    SUM(Base_UnitsLY_YTD)     					AS Base_UnitsLY,    			
    SUM(Base_ValueLY_YTD)     					AS Base_ValueLY,    			
    SUM(Base_VolumeLY_YTD)    					AS Base_VolumeLY,

-- Dados para o cálculo do SOM
    SUM(SUM(Value)) OVER(PARTITION BY Year,Area, RE_Market, Category)           AS Total_Sales,
    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales,
	----------------------------------------SOM TPR E BASE----------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
	SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_Value),
	SUM(SUM(Value)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)      AS SOM_Sales_Base,
	----------------------------------------------------------------------------------------------------

    SUM(SUM(ValueLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)         AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY_YTD),
    SUM(SUM(ValueLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY,
	----------------------------------------SOM TPR E BASE LY-------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY_YTD),
    SUM(SUM(ValueLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY_YTD),
    SUM(SUM(ValueLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_Base,
	----------------------------------------------------------------------------------------------------
	
	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)          AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume,
	----------------------------------------SOM VOLUME TPR E BASE---------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)     AS SOM_Volume_Base,	
    ----------------------------------------------------------------------------------------------------
	
    SUM(SUM(VolumeLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)        AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY_YTD),
    SUM(SUM(VolumeLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY,
	----------------------------------------SOM VOLUME TPR E BASE LY------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY_YTD),
    SUM(SUM(VolumeLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY_YTD),
    SUM(SUM(VolumeLY_YTD)) OVER(PARTITION BY Year, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_Base,
	----------------------------------------------------------------------------------------------------
	
	CASE WHEN DATE(Year, 12, 31) > MAX_DATE THEN 0 ELSE 1 END 			AS CompleteInterval,
	normalized_hierarchy,
    short_desc,
    DATE(Year, 1, 1)      AS start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator 
	
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
  WHERE
    Year >= EXTRACT(YEAR FROM MAX_DATE_SCAN) - YTDLen  AND
	week_ajusted <= MaxWeek and week_ajusted >0 AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ==============================================================================  
  GROUP BY 
  Market,                
  Area,
  RE_Market,
  Manufacturer,
  Brand,
  SubBrand,
  PPG,
  Segment,
  Category,
  Product,
  Variant,
  Size,
  Packing,
  Product_Form,
  Life_Stage,
  EAN,
  PPGRank,
  PriceTier,
  RCD_Segment,
  local_segment,
  Year,
  normalized_hierarchy,
  short_desc,
  level_name,
  promo_indicator

UNION ALL

-- VENDAS MENSAIS --------------------------------------------------------------
--------------------------------------------------------------------------------
SELECT
    -- Tipo de data
    'Monthly'                                   AS Date_type,
    -- Dados de Mercado
    Market                                      AS Market,
    Area                                        AS Area,
    RE_Market                                   AS RE,
    Manufacturer                                AS Manufacturer,
    Brand                                       AS Brand,
    SubBrand                                    AS SubBrand,
    PPG                                         AS PPG,
    Segment                                     AS Segment,
    Category                                    AS Category,
    Product                                     AS Product,
    Variant                                     AS Variant,
    Size                                        AS Size,
    Packing                                     AS Packing,
    Product_Form                                AS Product_Form,
    Life_Stage                                  AS Life_Stage,
    EAN                                         AS EAN,
    PPGRank                                     AS PPGRank,
    PriceTier                                   AS PriceTier,
	RCD_Segment,
	local_segment,

    -- Dados de Data
    MAX_DATE                                    AS MaxDate,
    Year                                        AS Year,
    (CASE WHEN  EXTRACT(YEAR FROM EndDate) = Year 
		THEN EndDate
		ELSE MaxDate 
		END)                					AS EndDate,
    DATE(Year, Month, 1)                        AS RefDate,
    Month                                       AS Month,
    EXTRACT(QUARTER FROM DATE(Year, Month, 1))  AS Quarter,
    EXTRACT(WEEK FROM DATE(Year, Month, 1))     AS Week,
    data_scan_msg                               AS data_scan_msg,
	MaxMonthDate		  						AS MaxMonthDate,

	-- Dados sumarizados
    SUM(Value)            						AS Value, 
    SUM(Units)            						AS Units,	
    SUM(Volume)           						AS Volume,   
    SUM(TPR_Value)        						AS TPR_Value, 
    SUM(TPR_Units)        						AS TPR_Units, 
    SUM(TPR_Volume)       						AS TPR_Volume,
    SUM(Base_Units)       						AS Base_Units,    			
    SUM(Base_Value)       						AS Base_Value,    			
    SUM(Base_Volume)      						AS Base_Volume, 
    SUM(ValueLY)          						AS ValueLY,     
    SUM(UnitsLY)          						AS UnitsLY,    
    SUM(VolumeLY)         						AS VolumeLY,   
    SUM(TPR_ValueLY)      						AS TPR_ValueLY, 
    SUM(TPR_UnitsLY)      						AS TPR_UnitsLY,
    SUM(TPR_VolumeLY)     						AS TPR_VolumeLY, 
    SUM(Base_UnitsLY)     						AS Base_UnitsLY,    			
    SUM(Base_ValueLY)     						AS Base_ValueLY,    			
    SUM(Base_VolumeLY)    						AS Base_VolumeLY,

-- Dados para o cálculo do SOM
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)           AS Total_Sales,
    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)      AS SOM_Sales,
----------------------------------------SOM TPR E BASE----------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)      AS SOM_Sales_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)      AS SOM_Sales_Base,
----------------------------------------------------------------------------------------------------	
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)         AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)    AS SOM_Sales_LY,
----------------------------------------SOM TPR E BASE LY-------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)    AS SOM_Sales_LY_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)), 0)    AS SOM_Sales_LY_Base,
----------------------------------------------------------------------------------------------------	
	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)          AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)     AS SOM_Volume,
----------------------------------------SOM TPR E BASE----------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)     AS SOM_Volume_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)     AS SOM_Volume_Base,
----------------------------------------------------------------------------------------------------
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Month,Area, RE_Market, Category)        AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY,
----------------------------------------SOM TPR E BASE LY-------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Month, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_Base,
----------------------------------------------------------------------------------------------------	
	CASE
      WHEN MaxMonthDate > MAX_DATE THEN 0 ELSE 1  END 			  			   AS CompleteInterval,
	normalized_hierarchy,
    short_desc, 
	start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator 
	
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
  WHERE
    DATE(Year, Month, 1) >= DATE_SUB(DATE(EXTRACT(YEAR FROM MAX_DATE), EXTRACT(MONTH FROM MAX_DATE), 1), INTERVAL MonthLen-1 MONTH) 
    AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ==============================================================================   
  GROUP BY
    Date_type,
    Market,
    Area,
    RE_Market,
    Manufacturer,
    Brand,
    SubBrand,
    PPG,
    Segment,
    Category,
    Product,
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,
    PPGRank,
    PriceTier,
	RCD_Segment,
	local_segment,
    MaxDate,
	MaxMonthDate,
    Year,
    EndDate,
    RefDate,
    Month,
    Quarter,
    Week,
    data_scan_msg,
	MaxMonthDate,
	normalized_hierarchy,
    short_desc, 
	start_date,
	level_name,
    promo_indicator

UNION ALL

-- DATA MENSAL AJUSTADA PARA O CRESCIMENTO PARA IGUALAR O NÚMERO DE SEMANAS POR ANO
-- VENDAS MENSAIS --------------------------------------------------------------
--------------------------------------------------------------------------------

SELECT
    -- Tipo de data
    'Monthly Growth' 							AS Date_type,
    -- Dados de Mercado
    Market                                      AS Market,
    Area                                        AS Area,
    RE_Market                                   AS RE,
    Manufacturer                                AS Manufacturer,
    Brand                                       AS Brand,
    SubBrand                                    AS SubBrand,
    PPG                                         AS PPG,
    Segment                                     AS Segment,
    Category                                    AS Category,
    Product                                     AS Product,
    Variant                                     AS Variant,
    Size                                        AS Size,
    Packing                                     AS Packing,
    Product_Form                                AS Product_Form,
    Life_Stage                                  AS Life_Stage,
    EAN                                         AS EAN,
    PPGRank                                     AS PPGRank,
    PriceTier                                   AS PriceTier,
	RCD_Segment,
	local_segment,
    -- Dados de Data
    MAX_DATE									AS MaxDate,
    EXTRACT(YEAR FROM data_scan_msg) 			AS Year,
    (CASE WHEN  EXTRACT(YEAR FROM EndDate) = EXTRACT(YEAR FROM data_scan_msg)
		THEN EndDate ELSE MAX_DATE 
		END) 		  							AS EndDate,
    DATE(EXTRACT(YEAR FROM data_scan_msg) , 
		EXTRACT(MONTH FROM data_scan_msg), 1)	AS RefDate,
    EXTRACT(MONTH FROM data_scan_msg) 			AS Month,
    EXTRACT(QUARTER FROM DATE(EXTRACT(YEAR FROM data_scan_msg), 
	  EXTRACT(MONTH FROM data_scan_msg), 1))    AS Quarter,
    EXTRACT(WEEK FROM DATE(EXTRACT(YEAR FROM data_scan_msg), 
  	EXTRACT(MONTH FROM data_scan_msg), 1))      AS Week,
    data_scan_msg,
	MaxMonthDate		  						AS MaxMonthDate,

    -- Dados sumarizados
    SUM(Value)            						AS Value, 
    SUM(Units)            						AS Units,	
    SUM(Volume)           						AS Volume,   
    SUM(TPR_Value)        						AS TPR_Value, 
    SUM(TPR_Units)        						AS TPR_Units, 
    SUM(TPR_Volume)       						AS TPR_Volume,
    SUM(Base_Units)       						AS Base_Units,    			
    SUM(Base_Value)       						AS Base_Value,    			
    SUM(Base_Volume)      						AS Base_Volume, 
    SUM(ValueLY)          						AS ValueLY,     
    SUM(UnitsLY)          						AS UnitsLY,    
    SUM(VolumeLY)         						AS VolumeLY,   
    SUM(TPR_ValueLY)      						AS TPR_ValueLY, 
    SUM(TPR_UnitsLY)      						AS TPR_UnitsLY,
    SUM(TPR_VolumeLY)     						AS TPR_VolumeLY, 
    SUM(Base_UnitsLY)     						AS Base_UnitsLY,    			
    SUM(Base_ValueLY)     						AS Base_ValueLY,    			
    SUM(Base_VolumeLY)    						AS Base_VolumeLY,


    -- Dados para o cálculo do SOM
    SUM(SUM(Value)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg),Area, RE_Market, Category)        AS Total_Sales,

    	COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales,
----------------------------------------SOM TPR E BASE----------------------------------------------------	
    	COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
    SUM(SUM(Value)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales_TPR,
					
    	COALESCE(SAFE_DIVIDE(SUM(Base_Value),
    SUM(SUM(Value)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales_Base,
-----------------------------------------------------------------------------------------------------------					

    SUM(SUM(ValueLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)        AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales_LY,
----------------------------------------SOM TPR E BASE LY--------------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Sales_LY_Base,
-----------------------------------------------------------------------------------------------------------				

	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)        AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Volume,
----------------------------------------SOM VOLUME TPR E BASE----------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Volume_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)   AS SOM_Volume_Base,
-----------------------------------------------------------------------------------------------------------					

    SUM(SUM(VolumeLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)        AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)	AS SOM_Volume_LY,
----------------------------------------SOM VOLUME TPR E BASE LY-------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)	AS SOM_Volume_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY EXTRACT(YEAR FROM data_scan_msg),
					EXTRACT(MONTH FROM data_scan_msg), Area,RE_Market, Category)), 0)	AS SOM_Volume_LY_Base,					
-----------------------------------------------------------------------------------------------------------
    CASE
       WHEN MaxMonthDate > MAX_DATE THEN 0 ELSE 1  END 							AS CompleteInterval,
	normalized_hierarchy,
    short_desc, 
	start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator 	

    FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` MONTHLY
    WHERE
    DATE(EXTRACT(YEAR FROM data_scan_msg),EXTRACT(MONTH FROM data_scan_msg), 1) >= DATE_SUB(DATE(EXTRACT(YEAR FROM MAX_DATE), EXTRACT(MONTH FROM MAX_DATE), 1), INTERVAL MonthLen-1 MONTH) 
    AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ==============================================================================    
	GROUP BY
    Date_type,
    Market,
    Area,
    RE_Market,
    Manufacturer,
    Brand,
    SubBrand,
    PPG,
    Segment,
    Category,
    Product,
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,
    PPGRank,
    PriceTier,
	RCD_Segment,
	local_segment,
    MaxDate,
	MaxMonthDate,
	EndDate,
    data_scan_msg,
	MaxMonthDate,
	normalized_hierarchy,
    short_desc, 
	start_date,
	level_name,
    promo_indicator

-- VENDAS SEMANAIS -------------------------------------------------------------
--------------------------------------------------------------------------------
UNION ALL
	
	SELECT
    -- Tipo de data
    'Weekly'                                   AS Date_type,
    -- Dados de Mercado
    Market                                      AS Market,
    Area                                        AS Area,
    RE_Market                                   AS RE,
    Manufacturer                                AS Manufacturer,
    Brand                                       AS Brand,
    SubBrand                                    AS SubBrand,
    PPG                                         AS PPG,
    Segment                                     AS Segment,
    Category                                    AS Category,
    Product                                     AS Product,
    Variant                                     AS Variant,
    Size                                        AS Size,
    Packing                                     AS Packing,
    Product_Form                                AS Product_Form,
    Life_Stage                                  AS Life_Stage,
    EAN                                         AS EAN,
    PPGRank                                     AS PPGRank,
    PriceTier                                   AS PriceTier,
	RCD_Segment,
	local_segment,

    -- Dados de Data
    MAX_DATE                                    AS MaxDate,
    Year                                        AS Year,
    EndDate					  					AS EndDate,
    DATE(Year, Month, 1)                        AS RefDate,
    Month                                       AS Month,
    Quarter										AS Quarter,
    week_ajusted							    AS Week,
    data_scan_msg                               AS data_scan_msg,
	MaxMonthDate		  						AS MaxMonthDate,

	-- Dados sumarizados
    SUM(Value)            						AS Value, 
    SUM(Units)            						AS Units,	
    SUM(Volume)           						AS Volume,   
    SUM(TPR_Value)        						AS TPR_Value, 
    SUM(TPR_Units)        						AS TPR_Units, 
    SUM(TPR_Volume)       						AS TPR_Volume,
    SUM(Base_Units)       						AS Base_Units,    			
    SUM(Base_Value)       						AS Base_Value,    			
    SUM(Base_Volume)      						AS Base_Volume, 
    SUM(ValueLY)          						AS ValueLY,     
    SUM(UnitsLY)          						AS UnitsLY,    
    SUM(VolumeLY)         						AS VolumeLY,   
    SUM(TPR_ValueLY)      						AS TPR_ValueLY, 
    SUM(TPR_UnitsLY)      						AS TPR_UnitsLY,
    SUM(TPR_VolumeLY)     						AS TPR_VolumeLY, 
    SUM(Base_UnitsLY)     						AS Base_UnitsLY,    			
    SUM(Base_ValueLY)     						AS Base_ValueLY,    			
    SUM(Base_VolumeLY)    						AS Base_VolumeLY,

-- Dados para o cálculo do SOM
    SUM(SUM(Value)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)      		AS Total_Sales,
    
	COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0) 		AS SOM_Sales,
	----------------------------------------SOM TPR E BASE----------------------------------------------------
	COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0) 		AS SOM_Sales_TPR,
	COALESCE(SAFE_DIVIDE(SUM(Base_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0) 		AS SOM_Sales_Base,
--------------------------------------------------------------------------------------------------------------	
    
	SUM(SUM(ValueLY)) OVER(PARTITION BY Year,week_ajusted, Area,RE_Market, Category)          	AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)     	AS SOM_Sales_LY,
	----------------------------------------SOM TPR E BASE LY-------------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)     	AS SOM_Sales_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)     	AS SOM_Sales_LY_Base,	
--------------------------------------------------------------------------------------------------------------
	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)            AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)       AS SOM_Volume,
----------------------------------------SOM VOLUME TPR E BASE-------------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)       AS SOM_Volume_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, week_ajusted,Area, RE_Market, Category)), 0)       AS SOM_Volume_Base,
--------------------------------------------------------------------------------------------------------------

    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)         	AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0)		AS SOM_Volume_LY,
----------------------------------------SOM VOLUME TPR E BASE LY----------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0)		AS SOM_Volume_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, week_ajusted, Area,RE_Market, Category)), 0)		AS SOM_Volume_LY_Base,	
--------------------------------------------------------------------------------------------------------------	
	
	CASE
      WHEN MaxMonthDate > MAX_DATE THEN 0 ELSE 1  END 			  			   AS CompleteInterval,
	normalized_hierarchy,
    short_desc, 
	start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator 	
	
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
  WHERE
     EndDate >= DATE_SUB(MAX_DATE, INTERVAL WeekLen * 7 DAY) AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ==============================================================================  
  GROUP BY
    Date_type,
    Market,
    Area,
    RE,
    Manufacturer,
    Brand,
    SubBrand,
    PPG,
    Segment,
    Category,
    Product,
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,
    PPGRank,
    PriceTier,
	RCD_Segment,
	local_segment,
    MaxDate,
    Year,
    EndDate,
    RefDate,
    Month,
    Quarter,
    data_scan_msg,
    week_ajusted,
	MaxMonthDate,
	normalized_hierarchy,
    short_desc, 
	start_date,
    level_name,
    promo_indicator 	
	
	
-- VENDAS QUARTER --------------------------------------------------------------
--------------------------------------------------------------------------------
UNION ALL

  SELECT
    -- Tipo de data
    'Quarter'                                   AS Date_type,
    -- Dados de Mercado
    Market                                      AS Market,
    Area                                        AS Area,
    RE_Market                                   AS RE,
    Manufacturer                                AS Manufacturer,
    Brand                                       AS Brand,
    SubBrand                                    AS SubBrand,
    PPG                                         AS PPG,
    Segment                                     AS Segment,
    Category                                    AS Category,
    Product                                     AS Product,
    Variant                                     AS Variant,
    Size                                        AS Size,
    Packing                                     AS Packing,
    Product_Form                                AS Product_Form,
    Life_Stage                                  AS Life_Stage,
    EAN                                         AS EAN,
    PPGRank                                     AS PPGRank,
    PriceTier                                   AS PriceTier,
	RCD_Segment,
	local_segment,

    -- Dados de Data
    MAX_DATE                                    AS MaxDate,
    Year                                        AS Year,
    DATE(Year, 1, 1)                			AS EndDate,
    DATE(Year, 1, 1)                            AS RefDate,
    0                                           AS Month,
    Quarter                                     AS Quarter,
    EXTRACT(WEEK FROM DATE(Year, 1, 1))         AS Week,
    DATE(Year, 1, 1)                            AS data_scan_msg,
	  DATE(Year, 1, 1)	  						AS MaxMonthDate,

	-- Dados sumarizados
    SUM(Value)            						AS Value, 
    SUM(Units)            						AS Units,	
    SUM(Volume)           						AS Volume,   
    SUM(TPR_Value)        						AS TPR_Value, 
    SUM(TPR_Units)        						AS TPR_Units, 
    SUM(TPR_Volume)       						AS TPR_Volume,
    SUM(Base_Units)       						AS Base_Units,    			
    SUM(Base_Value)       						AS Base_Value,    			
    SUM(Base_Volume)      						AS Base_Volume, 
    SUM(ValueLY)          						AS ValueLY,     
    SUM(UnitsLY)          						AS UnitsLY,    
    SUM(VolumeLY)         						AS VolumeLY,   
    SUM(TPR_ValueLY)      						AS TPR_ValueLY, 
    SUM(TPR_UnitsLY)      						AS TPR_UnitsLY,
    SUM(TPR_VolumeLY)     						AS TPR_VolumeLY, 
    SUM(Base_UnitsLY)     						AS Base_UnitsLY,    			
    SUM(Base_ValueLY)     						AS Base_ValueLY,    			
    SUM(Base_VolumeLY)    						AS Base_VolumeLY,

-- Dados para o cálculo do SOM
    SUM(SUM(Value)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)           AS Total_Sales,
    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)      AS SOM_Sales,
----------------------------------------SOM TPR E BASE-----------------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)      AS SOM_Sales_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)      AS SOM_Sales_Base,
-----------------------------------------------------------------------------------------------------------	
	
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)         AS Total_Sales_LY,
    COALESCE(SAFE_DIVIDE(SUM(ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY,
	----------------------------------------SOM TPR E BASE LY----------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_ValueLY),
    SUM(SUM(ValueLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)    AS SOM_Sales_LY_Base,	
-----------------------------------------------------------------------------------------------------------	
	 -- Dados para o cálculo do SOM do Volume
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)          AS Total_Volume,
    COALESCE(SAFE_DIVIDE(SUM(Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)     AS SOM_Volume,
	----------------------------------------SOM VOLUME TPR E BASE------------------------------------------
    COALESCE(SAFE_DIVIDE(SUM(TPR_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)     AS SOM_Volume_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_Volume),
    SUM(SUM(Volume)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)     AS SOM_Volume_Base,	
-----------------------------------------------------------------------------------------------------------	
	
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)        AS Total_Volume_LY,
    COALESCE(SAFE_DIVIDE(SUM(VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY,	
----------------------------------------SOM VOLUME TPR E BASE LY-------------------------------------------	
    COALESCE(SAFE_DIVIDE(SUM(TPR_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_TPR,
    COALESCE(SAFE_DIVIDE(SUM(Base_VolumeLY),
    SUM(SUM(VolumeLY)) OVER(PARTITION BY Year, Quarter, Area,RE_Market, Category)), 0)   AS SOM_Volume_LY_Base,
-----------------------------------------------------------------------------------------------------------	
-----------------------------------------------------------------------------------------------------------	
	1 			  			   AS CompleteInterval,
	normalized_hierarchy,
    short_desc, 
	start_date,
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
    MAX(ND_TPR) AS ND_TPR, 
    MAX(WD_TPR) AS WD_TPR, 
    level_name,
    promo_indicator 
	
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
  WHERE
    DATE(Year, Month, 1) >= DATE_SUB(DATE(EXTRACT(YEAR FROM MAX_DATE), EXTRACT(MONTH FROM MAX_DATE), 1), INTERVAL MonthLen-1 MONTH) 
    AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ==============================================================================  
 GROUP BY
    Date_type,
    Market,
    Area,
    RE_Market,
    Manufacturer,
    Brand,
    SubBrand,
    PPG,
    Segment,
    Category,
    Product,
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,
    PPGRank,
    PriceTier,
	RCD_Segment,
	local_segment,
    MaxDate,
	MaxMonthDate,
    Year,
    Quarter,
	normalized_hierarchy,
    short_desc, 
	start_date,
	level_name,
    promo_indicator
	
	
	;
-- ====================================================================================================================================================================================================
-- BASE FINAL SCANTRACK ===============================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
--  VALORES DO FABRICANTE CP NAS MARCAS COLGATE, SORRISO E ELMEX ADICIONADOS SEPARADAMENTE ============================================================================================================
-- ====================================================================================================================================================================================================
INSERT INTO `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`
            
    SELECT
    Date_Type           AS Date_Type,

    -- Dados de Mercado
    Market              AS Market,
    Area                AS Area,
    RE                  AS RE,

    -- Dados de Produto
    Brand               AS Manufacturer,
    Brand               AS Brand,
    SubBrand            AS SubBrand,
    PPG                 AS PPG,
    Segment             AS Segment,
    Category            AS Category,
    Product             AS Product,
    Variant             AS Variant,
    Size                AS Size,
    Packing             AS Packing,
    Product_Form        AS Product_Form,
    Life_Stage          AS Life_Stage,
    EAN                 AS EAN,
    PPGRank             AS PPGRank,
    PriceTier           AS PriceTier,
	RCD_Segment,
	local_segment,

    MaxDate             AS MaxDate,
    Year                AS Year,
    EndDate             AS EndDate,
    RefDate             AS RefDate,
    Month               AS Month,
    Quarter             AS Quarter,
    Week                AS Week,
    data_scan_msg       AS data_scan_msg, 
	MaxMonthDate		AS MaxMonthDate,

    Value               AS Value, 
    Units               AS Units,	
    Volume              AS Volume,   
    TPR_Value           AS TPR_Value, 
    TPR_Units           AS TPR_Units, 
    TPR_Volume          AS TPR_Volume,
    Base_Units          AS Base_Units,    			
    Base_Value          AS Base_Value,    			
    Base_Volume         AS Base_Volume, 
    ValueLY             AS ValueLY,     
    UnitsLY             AS UnitsLY,    
    VolumeLY            AS VolumeLY,   
    TPR_ValueLY         AS TPR_ValueLY, 
    TPR_UnitsLY         AS TPR_UnitsLY,
    TPR_VolumeLY        AS TPR_VolumeLY, 
    Base_UnitsLY        AS Base_UnitsLY,    			
    Base_ValueLY        AS Base_ValueLY,    			
    Base_VolumeLY       AS Base_VolumeLY, 

    Total_Sales         AS Total_Sales,
    SOM_Sales           AS SOM_Sales,
	SOM_Sales_TPR       AS SOM_Sales_TPR,
	SOM_Sales_Base      AS SOM_Sales_Base,
    Total_Sales_LY      AS Total_Sales_LY,
    SOM_Sales_LY        AS SOM_Sales_LY,
	SOM_Sales_LY_TPR    AS SOM_Sales_LY_TPR,
	SOM_Sales_LY_Base   AS SOM_Sales_LY_Base,
	Total_Volume        AS Total_Volume,
    SOM_Volume          AS SOM_Volume,
	SOM_Volume_TPR      AS SOM_Volume_TPR,
	SOM_Volume_Base     AS SOM_Volume_Base,
    Total_Volume_LY     AS Total_Volume_LY,
    SOM_Volume_LY       AS SOM_Volume_LY,
	SOM_Volume_LY_TPR   AS SOM_Volume_LY_TPR,
	SOM_Volume_LY_Base  AS SOM_Volume_LY_Base,
    CompleteInterval    AS CompleteInterval,
	normalized_hierarchy,
    short_desc, 
	start_date,
	ND AS ND, 
    WD AS WD, 
    ND_TPR AS ND_TPR, 
    WD_TPR AS WD_TPR, 
    level_name,
    promo_indicator

    FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`

    WHERE Manufacturer = 'CP' AND Brand IN('COLGATE', 'SORRISO', 'ELMEX') AND Category IN('TOOTHBRUSH','TOOTHPASTE');

-- ====================================================================================================================================================================================================
--  VALORES DO FABRICANTE CP NAS MARCAS COLGATE, SORRISO E ELMEX ADICIONADOS SEPARADAMENTE ============================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE SCANTRACK PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack_Table`
PARTITION BY EndDate cluster by Manufacturer, Category, RE, Area
AS 
SELECT
    Date_Type,
    Market,
    Area,
    RE,
    Manufacturer,
    Brand,
    SubBrand,
    PPG,
    Segment,
    Category,
    Product,
    Variant,
    Size,
    Packing,
    Product_Form,
    Life_Stage,
    EAN,
    Category AS PnPCategory,
    PPGRank,
    PriceTier,

    Year,
    EndDate,
    MaxDate,
    RefDate,
    Month,
    Quarter,
    Week,

    Value,
    Units,
    Volume,
    TPR_Value,
    TPR_Units,
    TPR_Volume,
    Base_Units,
    Base_Value,
    Base_Volume,

    ValueLY AS Value_LY,
    UnitsLY AS Units_LY,
    VolumeLY AS Volume_LY,
    TPR_ValueLY AS TPR_Value_LY,
    TPR_UnitsLY AS TPR_Units_LY,
    TPR_VolumeLY AS TPR_Volume_LY,
    Base_UnitsLY AS Base_Units_LY,
    Base_ValueLY AS Base_Value_LY,
    Base_VolumeLY,

    Total_Sales,
    SOM_Sales,
	SOM_Sales_TPR,
	SOM_Sales_Base,
    Total_Sales_LY,
    SOM_Sales_LY,
	SOM_Sales_LY_TPR,
	SOM_Sales_LY_Base,
	Total_Volume,
    SOM_Volume,
	SOM_Volume_TPR,
	SOM_Volume_Base,
    Total_Volume_LY,
    SOM_Volume_LY,
	SOM_Volume_LY_TPR,
	SOM_Volume_LY_Base,
    CompleteInterval,
	
	CASE 
 	WHEN Date_Type='FY' AND Year>= EXTRACT(YEAR FROM MaxDate)-1 THEN RIGHT(CAST(Year AS STRING),2)
 	WHEN Date_Type='YTD' AND Year>= EXTRACT(YEAR FROM MaxDate)-1 THEN CONCAT('YTD-', RIGHT(CAST(Year AS STRING),2))
  	WHEN Date_Type='Monthly' THEN CONCAT(FORMAT_DATE('%b',RefDate), '-', `Year` - 2000) 
	WHEN Date_Type='Weekly' THEN FORMAT_DATE('%d-%b',
    DATE_ADD(DATE_SUB(PARSE_DATE('%Y/%m/%d', CONCAT(Year, '/1/1')), INTERVAL (EXTRACT(DAYOFWEEK FROM PARSE_DATE('%Y/%m/%d', CONCAT(Year, '/1/1')))-1) DAY), INTERVAL (`Week`-1) WEEK))
    ELSE 'HIDE'
	END AS DateLabel,
	
	(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`
     WHERE Value > 0 AND Date_Type='Monthly') AS MaxDateRef,
	 
    --(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`
    --    WHERE EndDate <= MaxDate AND Date_Type='Monthly' AND RefDate <= MaxDate) AS MaxDateRef,
    short_desc, 
	start_date,
	ND AS ND, 
    WD AS WD, 
    ND_TPR AS ND_TPR, 
    WD_TPR AS WD_TPR, 
    level_name,
    promo_indicator 

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scantrack`	
;

-- ====================================================================================================================================================================================================
--  FIM DA TABELA FINAL PARTICIONADA DE SCANTRACK PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ############################################################ BASE NIELSEN: PRICE TRACKING ##########################################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################

-- ====================================================================================================================================================================================================
-- DECLARAÇÃO DE VARIÁVEIS PARA ADIÇÃO DE DATAS NO CALENDÁRIO NIELSEN =================================================================================================================================
--==============================================================================================================================================================================================================================================================================================================================================
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)) AS

-- DADOS MENSAIS
SELECT 'Monthly' 			      AS Date_Type,
		Category         	      AS Category,
		Short_Category			  AS Short_Category,
		PPG					      AS PPG,
		Segment				      AS Segment,
		Area				      AS Area,		
		RE_Market			      AS RE,
		UF,
		Country				      AS country,
		Manufacturer	   	      AS manufacturer,
		Brand				      AS brand,
		Subbrand			      AS subbrand,
		EAN					      AS EAN,
		Market				      AS Market,
		RCD_Segment,
	    local_segment,
		
		EndDate			    	  AS EndDate,
		Quarter				      AS Quarter,
		Month				      AS Month,
		Year				      AS Year,
		Week				      AS Week,
				
		SUM(Value)			      AS Value,
		SUM(Units)			      AS Units,
		SUM(Volume)			      AS Volume,
		CASE WHEN SUM(Units) = 0 THEN 0
		ELSE SAFE_DIVIDE(SUM(Value),SUM(Units))	END AS Price,
		CASE WHEN  SUM(Volume) = 0 THEN 0
		ELSE
		SAFE_DIVIDE(SUM(Value),
		SUM(Volume))		 END     AS Price_Volume,
		
		SUM(TPR_Value)		      AS TPR_Value,					
		SUM(TPR_Units)		      AS TPR_Units,
		SUM(TPR_Volume)		      AS TPR_Volume,
		
		SAFE_DIVIDE(SUM(TPR_Value),		
		SUM(TPR_Units))		      AS TPR_Price,
		
		SAFE_DIVIDE(SUM(TPR_Value),
		SUM(TPR_Volume))	      AS TPR_Price_Volume,
		
		SUM(Base_Value)		      AS Base_Value,
		SUM(Base_Units)		      AS Base_Units,
		SUM(Base_Volume)	      AS Base_Volume,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Units))	      AS Base_Price,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Volume)) 	      AS Base_Price_Volume,
        promo_indicator,
		    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Area, UF, RE_Market, Category)), 0)      AS SOM_Sales,
	
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 

    (SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
     WHERE Value > 0)AS MaxDateRef

	--(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
    -- WHERE EndDate <= MaxDate  AND RefDate >= MaxDate) AS MaxDateRef
	
	

	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
	WHERE Area <>'NC' AND Year >= EXTRACT(YEAR FROM MAX_DATE)-3 AND EndDate <= MAX_DATE 
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
	GROUP BY 
		Category,
		Short_Category,
		PPG,
		Segment,
		Area,		
		RE_Market,
		UF,
		country,
		EndDate,
		manufacturer,
		brand,
		subbrand,
		EAN,
		Market,
		RCD_Segment,
	    local_segment,
		Quarter,
		Year,
		Month,
		Week,
        promo_indicator

		
UNION ALL
-- DADOS TRIMESTRAIS
SELECT 'Quarter' 			      AS Date_Type,
		Category         	      AS Category,
		Short_Category			  AS Short_Category,
		PPG					      AS PPG,
		Segment				      AS Segment,
		Area				      AS Area,		
		RE_Market			      AS RE,
		UF,
		Country				      AS country,
		Manufacturer		      AS manufacturer,
		Brand			      	  AS brand,
		Subbrand			      AS subbrand,
		EAN					      AS EAN,
		Market				      AS Market,
		RCD_Segment,
	    local_segment,
		
		MAX(EndDate)		      AS EndDate,
		Quarter				      AS Quarter,
		MAX(Month)			      AS Month,
		Year				      AS Year,
		MAX(Week)			      AS Week,
				
		SUM(Value)			      AS Value,
		SUM(Units)			      AS Units,
		SUM(Volume)			      AS Volume,
		SAFE_DIVIDE(SUM(Value),
		SUM(Units))			      AS Price,
		SAFE_DIVIDE(SUM(Value),
		SUM(Volume))		      AS Price_Volume,
		
		SUM(TPR_Value)		      AS TPR_Value,					
		SUM(TPR_Units)		      AS TPR_Units,
		SUM(TPR_Volume)		      AS TPR_Volume,
		SAFE_DIVIDE(SUM(TPR_Value),		
		SUM(TPR_Units))		      AS TPR_Price,
		SAFE_DIVIDE(SUM(TPR_Value),
		SUM(TPR_Volume))	      AS TPR_Price_Volume,
		
		SUM(Base_Value)		      AS Base_Value,
		SUM(Base_Units)		      AS Base_Units,
		SUM(Base_Volume)	      AS Base_Volume,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Units))	      AS Base_Price,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Volume)) 	      AS Base_Price_Volume,
        promo_indicator,
		    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Quarter, Area, UF, RE_Market, Category)), 0)      AS SOM_Sales,
	
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 
     
	(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
     WHERE Value > 0)AS MaxDateRef 
	 
	--(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
    -- WHERE EndDate <= MaxDate  AND RefDate >= MaxDate) AS MaxDateRef
	

	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
	WHERE Area <>'NC'  AND Year >= EXTRACT(YEAR FROM MAX_DATE)-3 AND EndDate <= MAX_DATE 
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 	
	GROUP BY 
		Category,
		Short_Category,
		PPG,
		Segment,
		Area,		
		RE_Market,
		UF,
		country,
		manufacturer,
		brand,
		subbrand,
		EAN,
		Market,
		RCD_Segment,
	    local_segment,
		Quarter,
		Year,
        promo_indicator

UNION ALL
-- DADOS YTD: Apenas para o último mês de cada ano.
SELECT 'YTD' 			   	      AS Date_Type,
		Category         	      AS Category,
		Short_Category			  AS Short_Category,
		PPG					      AS PPG,
		Segment			    	  AS Segment,
		Area				      AS Area,		
		RE_Market			      AS RE,
		UF,
		Country				      AS country,
		Manufacturer		      AS manufacturer,
		Brand				      AS brand,
		Subbrand			      AS subbrand,
		EAN					      AS EAN,
		Market				      AS Market,
		RCD_Segment,
	    local_segment,
	--	MAX(EndDate)		      AS EndDate,
	--	MAX(Quarter)		      AS Quarter,
	--	MAX(Month)			      AS Month,
	--	Year				          AS Year,
--		MAX(Week)			        AS Week,
		
		max(EndDate)		      AS EndDate,
		extract(Quarter from max(EndDate))  	        AS Quarter,
		extract(month   from max(EndDate)) 		        AS Month,
	  year 				          AS Year,
		MaxWeek			          AS Week,


		SUM(Value)			      AS Value,
		SUM(Units)			      AS Units,
		SUM(Volume)			      AS Volume,
		SAFE_DIVIDE(SUM(Value),
		SUM(Units))			      AS Price,
		SAFE_DIVIDE(SUM(Value),
		SUM(Volume))		      AS Price_Volume,
		
		SUM(TPR_Value)		      AS TPR_Value,					
		SUM(TPR_Units)		      AS TPR_Units,
		SUM(TPR_Volume)		      AS TPR_Volume,
		SAFE_DIVIDE(SUM(TPR_Value),		
		SUM(TPR_Units))		      AS TPR_Price,
		SAFE_DIVIDE(SUM(TPR_Value),
		SUM(TPR_Volume))	      AS TPR_Price_Volume,
		
		SUM(Base_Value)		      AS Base_Value,
		SUM(Base_Units)		      AS Base_Units,
		SUM(Base_Volume)	      AS Base_Volume,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Units))	      AS Base_Price,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Volume)) 	      AS Base_Price_Volume,
        promo_indicator,
		    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Area, UF, RE_Market, Category)), 0)      AS SOM_Sales,
	
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 

    (SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
     WHERE Value > 0)AS MaxDateRef

	--(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
    -- WHERE EndDate <= MaxDate  AND RefDate >= MaxDate) AS MaxDateRef

	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
		WHERE Area <>'NC'  AND Year >= EXTRACT(YEAR FROM MAX_DATE)-3 --AND EndDate <= MAX_DATE 
		AND week_ajusted <= MaxWeek and week_ajusted > 0
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 	
	GROUP BY 
		Category,
		Short_Category,
		PPG,
		Segment,
		Area,		
		RE_Market,
		UF,
		country,
		manufacturer,
		brand,
		subbrand,
		EAN,
		Market,
		RCD_Segment,
	    local_segment,
		Year,
        promo_indicator
		
		
		UNION ALL
		
		-- DADOS Semanais
SELECT 'Weekly' 			      AS Date_Type,
		Category         	      AS Category,
		Short_Category			  AS Short_Category,
		PPG					      AS PPG,
		Segment				      AS Segment,
		Area				      AS Area,		
		RE_Market			      AS RE,
		UF,
		Country				      AS country,
		Manufacturer	   	      AS manufacturer,
		Brand				      AS brand,
		Subbrand			      AS subbrand,
		EAN					      AS EAN,
		Market				      AS Market,
		RCD_Segment,
	    local_segment,
		
		EndDate			    	  AS EndDate,
		Quarter				      AS Quarter,
		Month				      AS Month,
		Year				      AS Year,
		Week				      AS Week,
				
		SUM(Value)			      AS Value,
		SUM(Units)			      AS Units,
		SUM(Volume)			      AS Volume,
		CASE WHEN SUM(Units) = 0 THEN 0
		ELSE SAFE_DIVIDE(SUM(Value),SUM(Units))	END AS Price,
		CASE WHEN  SUM(Volume) = 0 THEN 0
		ELSE
		SAFE_DIVIDE(SUM(Value),
		SUM(Volume))		 END     AS Price_Volume,
		
		SUM(TPR_Value)		      AS TPR_Value,					
		SUM(TPR_Units)		      AS TPR_Units,
		SUM(TPR_Volume)		      AS TPR_Volume,
		
		SAFE_DIVIDE(SUM(TPR_Value),		
		SUM(TPR_Units))		      AS TPR_Price,
		
		SAFE_DIVIDE(SUM(TPR_Value),
		SUM(TPR_Volume))	      AS TPR_Price_Volume,
		
		SUM(Base_Value)		      AS Base_Value,
		SUM(Base_Units)		      AS Base_Units,
		SUM(Base_Volume)	      AS Base_Volume,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Units))	      AS Base_Price,
		SAFE_DIVIDE(SUM(Base_Value),
		SUM(Base_Volume)) 	      AS Base_Price_Volume,
        promo_indicator,
		    COALESCE(SAFE_DIVIDE(SUM(Value),
    SUM(SUM(Value)) OVER(PARTITION BY Year, Month,Week, UF, Area, RE_Market, Category)), 0)      AS SOM_Sales,
	
	MAX(ND) AS ND, 
    MAX(WD) AS WD, 

    (SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
     WHERE Value > 0)AS MaxDateRef

	--(SELECT MAX(RefDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
    -- WHERE EndDate <= MaxDate  AND RefDate >= MaxDate) AS MaxDateRef
	
	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
	WHERE Area <>'NC' AND Year >= EXTRACT(YEAR FROM MAX_DATE)-3 AND EndDate <= MAX_DATE 
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
	GROUP BY 
		Category,
		Short_Category,
		PPG,
		Segment,
		Area,		
		RE_Market,
		UF,
		country,
		EndDate,
		manufacturer,
		brand,
		subbrand,
		EAN,
		Market,
		RCD_Segment,
	    local_segment,
		Quarter,
		Year,
		Month,
		Week,
        promo_indicator
		
		;	

-- ====================================================================================================================================================================================================
-- BASE AGRUPADA POR PERÍODOS: MENSAL, TRIMESTRAL E YTD ===============================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE MODELADA PARA O PRICE TRACKING ================================================================================================================================================================
-- ====================================================================================================================================================================================================
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking`

AS

WITH 
-- Dados da última data por mês.
BASE_CALENDAR AS (
SELECT MAX(EndDateBQ) AS MaxMonthDate, Year, Month 
FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar`

GROUP BY Year, Month
ORDER BY Year desc
)
-- PREÇO MÉDIO
SELECT 	Date_Type 			        AS Date_Type,
		Category           	        AS Category,
		Short_Category				AS Short_Category,
		BASE.PPG					AS PPG,
		Segment				        AS Segment,
		Area				        AS Area,		
		Base.RE					    AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN				    AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		EndDate				        AS EndDate,
		Quarter			       	    AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,		
		Base.Value		    	    AS Value,
		Units				        AS Units,
		Price 				        AS Price,
		Volume				        AS Volume,
		Price_Volume		        AS Price_Volume,
		'AVERAGE'			        AS Price_Type,
		MAX_DATE			    	AS MaxDate,
		BC.MaxMonthDate		        AS MaxMonthDate,
        promo_indicator,
		SOM_Sales,	
		ND, 
        WD, 
	    MaxDateRef
			
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
		--WHERE  UF = 'BR'
		
UNION ALL

-- PREÇO TPR
SELECT 	Date_Type 			        AS Date_Type,
		Category           	        AS Category,
		Short_Category				AS Short_Category,
		BASE.PPG					AS PPG,
		Segment				        AS Segment,
		Area				        AS Area,		
		Base.RE					    AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN					AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		EndDate				        AS EndDate,
		Quarter				        AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,	
		TPR_Value			        AS Value,
		TPR_Units			        AS Units,
		TPR_Price 			        AS Price,
		TPR_Volume			        AS Volume,
		TPR_Price_Volume	        AS Price_Volume,
		'TPR'			        	AS Price_Type,
		MAX_DATE				    AS MaxDate,
		BC.MaxMonthDate	  	        AS MaxMonthDate,
        promo_indicator,SOM_Sales,
		ND, 
        WD, 
	    MaxDateRef
				
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp`	Base
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
--WHERE  UF = 'BR'

UNION ALL
-- PREÇO BASE
SELECT 	Date_Type 			        AS Date_Type,
		Category         	        AS Category,
		Short_Category				AS Short_Category,
		BASE.PPG					AS PPG,
		Segment				        AS Segment,
		Area				        AS Area,		
		Base.RE					    AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN					AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		EndDate				        AS EndDate,
		Quarter				        AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,			
		Base_Value			        AS Value,
		Base_Units			        AS Units,
	    Base_Price 			        AS Price,
		Base_Volume			        AS Volume,
		Base_Price_Volume	        AS Price_Volume,
		'BASE'			       	    AS Price_Type,
		MAX_DATE				    AS MaxDate,
		BC.MaxMonthDate		        AS MaxMonthDate,
        promo_indicator,
		SOM_Sales,
		ND, 
        WD, 
	    MaxDateRef
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
--WHERE  UF = 'BR'
;
-- ====================================================================================================================================================================================================
-- BASE MODELADA PARA O PRICE TRACKING ================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- INSERE EM PRICE TRACKING TOTAL =====================================================================================================================================================================
-- ====================================================================================================================================================================================================
INSERT INTO `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking` 
(Date_Type,
		Category,
		Short_Category,
		PPG,
		Segment,
		Area,		
		RE,
		UF,
		Country,
		Manufacturer,
		Brand,
		Subbrand,
		EAN,
		Market,
		RCD_Segment,
	    local_segment,
		EndDate,
		Quarter,
		Month,
		Year,
		Week,
		Value,
		Units,
		Volume,
		Price_Type,
		MaxDate,
		MaxMonthDate,
        promo_indicator,
		SOM_Sales,
		ND, 
        WD, 
	    MaxDateRef)

SELECT Date_Type 			      AS Date_Type,
		Category         	      AS Category,
		Short_Category			  AS Short_Category,
		'#TOTAL'		    	  AS PPG,
		'#TOTAL'		    	  AS Segment,
		Area				      AS Area,		
		RE				      	  AS RE,
		UF,
		Country			    	  AS country,
		'#TOTAL'		          AS manufacturer,
		'#TOTAL'			      AS brand,
		'#TOTAL'			      AS subbrand,
		'#TOTAL'			      AS EAN,
		Market				      AS Market,
		RCD_Segment,
	    local_segment,
		EndDate				      AS EndDate,
		Quarter				      AS Quarter,
		Month			          AS Month,
		Year			          AS Year,
		Week				      AS Week,
		SUM(Value)			      AS Value,
		SUM(Units)			      AS Units,
		SUM(Volume)			      AS Volume,
		Price_Type			      AS Price_Type,
		MAX(MaxDate)		      AS MaxDate,
		MAX(MaxMonthDate)	      AS MaxMonthDate,
        promo_indicator,
		SUM(SOM_Sales)            AS SOM_Sales,
		MAX(ND) AS ND, 
        MAX(WD) AS WD, 
	    MaxDateRef

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking`

GROUP BY Date_Type,
		Category,
        Short_Category,
		Area,		
		RE,
		UF,
		Country,
		Market,
		RCD_Segment,
	    local_segment,
	    EndDate,
		Quarter,
		Month,
		Year,
		Week,
        Price_Type,
        promo_indicator,
		MaxDateRef;

-- ====================================================================================================================================================================================================
-- INSERE EM PRICE TRACKING TOTAL =====================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- TABELA FINAL PARTICIONADA DE PRICE TRACKING PARA CONEXÃO COM O DOMO =====================================================================================================================================================================
-- ====================================================================================================================================================================================================

	CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_PnP_Price_Tracking_Table`	
	PARTITION BY EndDate cluster by Year, Category, RE, Area
	AS

	SELECT 	Date_Type 			AS Date_Type,
			Short_Category      AS Category,
			Category         	AS Category_Desc,
			PPG					AS PPG,
			Segment				AS Segment,
			Area				AS Area,		
			RE					AS RE,
			UF,
			Country				AS country,
			Manufacturer		AS manufacturer,
			Brand				AS brand,
			Subbrand			AS subbrand,
			EAN					AS EAN,
			Market				AS Market,
			EndDate				AS EndDate,
			Quarter				AS Quarter,
			Month				AS Month,
			Year				AS Year,
			Week				AS Week,
			Volume				AS Volume,
			Value				AS Value,
			Units				AS Units,
			Price	 			AS Price,
			Price_Volume		AS Price_Volume,
			Price_Type			AS Price_Type,
			MaxDate				AS MaxDate,
			MaxMonthDate		AS MaxMonthDate,
            promo_indicator,
			SOM_Sales,
			ND  AS ND, 
            WD  AS WD, 
	        MaxDateRef
			
	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking`
;
-- ====================================================================================================================================================================================================
-- TABELA FINAL PARTICIONADA DE PRICE TRACKING PARA CONEXÃO COM O DOMO =====================================================================================================================================================================
-- ====================================================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- BASE MODELADA PARA A TABELA SPI ================================================================================================================================================================
-- ====================================================================================================================================================================================================


CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking_SPI`

AS

WITH SPI_GROUP 
AS(
	SELECT 	re as Retail_Enviroment, 
			ppg as PnP_PPG, 
			spi_year as year, 
			MIN(spi_month) as FirstMonth, 
			MAX(spi_month) AS LastMonth, 
			ppg_concorrencia,
			ean_concorencia, 
			strategy_index

	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI`
	     
	GROUP BY re, ppg, spi_year,ppg_concorrencia,ean_concorencia,strategy_index
),

-- Dados da última data por mês.
BASE_CALENDAR AS (
SELECT MAX(EndDateBQ) AS MaxMonthDate, Year, Month 
FROM `cp-saa-prod-ext-data-ingst.LatAm_Catalogs.BR_Nielsen_Scan_Calendar`

GROUP BY Year, Month
ORDER BY Year desc
),

BASE_PPG AS (
-- PREÇO MÉDIO
SELECT 	Date_Type 			        AS Date_Type,
		Category           	        AS Category,
		Short_Category				AS Short_Category,
		Base.PPG					AS PPG,
		Segment				        AS Segment,
		ROW_NUMBER() OVER (PARTITION BY Category, EndDate 
		ORDER BY Base.EAN ASC) 		AS Category_Rank,
		Area				        AS Area,		
		Base.RE					        AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN					        AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		
		EndDate				        AS EndDate,
		Quarter			       	    AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,
				
		Base.Value		    	    AS Value,
		Units				        AS Units,
		Price 				        AS Price,
		Volume				        AS Volume,
		Price_Volume		        AS Price_Volume,
		
		'AVERAGE'			        AS Price_Type,
		SAFE_CAST(
			SPI.spi_rate
				AS FLOAT64)	        AS SPI,
		MAX_DATE			    	AS MaxDate,
		SG.FirstMonth		        AS SPI_FirstMonth,
		SG.LastMonth		        AS SPI_LastMonth,
		BC.MaxMonthDate		        AS MaxMonthDate,
		0					        AS RECO,
        promo_indicator, 
		SPI.ppg_concorrencia,
				SPI.ean_concorencia,
		0		    	            AS Value_C,
		0				            AS Units_C,
		0 				            AS Price_C,
		0				            AS Volume_C,
		0		                    AS Price_Volume_C, 
		SOM_Sales,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                      
		MaxDateRef
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	LEFT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI --============================Verificar
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg 
		--and Base.EAN = 	CAST(SPI.ean AS STRING)
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
),

BASE_CONCORRENCIA AS (

		SELECT 	Date_Type 			        AS Date_Type,
		Category         	                AS Category,

	    Area				                AS Area,		
		Base.RE					            AS RE,
        UF,		
		EndDate				                AS EndDate,
		Quarter			       	            AS Quarter,
		Base.Month			                AS Month,
		Base.Year			                AS Year,
		Week				                AS Week,

		MAX_DATE			    	        AS MaxDate,

		spi.ppg_concorrencia                as ppg_concorrencia,
		spi.ean_concorencia                 as ean_concorencia,
		Value		    	                AS Value_C,
		Units				                AS Units_C,
		Price 				                AS Price_C,
		Volume				                AS Volume_C,
		Price_Volume		                AS Price_Volume_C,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                      
		MaxDateRef,
		SAFE_CAST(
	    SPI.spi_rate_concorrencia
		AS FLOAT64)	                AS SPI_concorrencia
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	RIGHT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI --============================Verificar
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg_concorrencia
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month

), 
BASE_AVERAGE AS (

SELECT distinct  A.Date_Type 			AS Date_Type,
		A.Category           	        AS Category,
		A.Short_Category				AS Short_Category,
		A.PPG					        AS PPG,
		A.Segment				        AS Segment,
		A.Category_Rank,
		A.Area				            AS Area,		
		A.RE					        AS RE,
		A.UF,
		A.Country				        AS country,
		A.Manufacturer		            AS manufacturer,
		A.Brand				            AS brand,
		A.Subbrand			            AS subbrand,
		A.EAN					        AS EAN,
		A.Market				        AS Market,
		A.RCD_Segment,
	    A.local_segment,
		
		A.EndDate				        AS EndDate,
		A.Quarter			       	    AS Quarter,
		A.Month			                AS Month,
		A.Year			                AS Year,
		A.Week				            AS Week,
				
		A.Value		    	            AS Value,
		A.Units				            AS Units,
		A.Price 				        AS Price,
		A.Volume				        AS Volume,
		A.Price_Volume		            AS Price_Volume,
		
		A.Price_Type,
		A.SPI,
		A.MaxDate,
		A.SPI_FirstMonth		        AS SPI_FirstMonth,
		A.SPI_LastMonth		            AS SPI_LastMonth,
		A.MaxMonthDate		            AS MaxMonthDate,
		A.RECO,
        A.promo_indicator, 
		A.ppg_concorrencia,
		A.ean_concorencia,

		B.Value_C,
		B.Units_C,
		B.Price_C,
		B.Volume_C,
		B.Price_Volume_C,
		SOM_Sales,
		A.strategy_index,                      
		A.MaxDateRef,
		B.SPI_concorrencia

FROM BASE_ppg A left join Base_concorrencia B on A.ppg_concorrencia = B.ppg_concorrencia 
--AND A.strategy_index = B.strategy_index
AND A.RE = B.RE AND A.AREa = b. Area and a.Category = b.Category and A.MOnth = b.Month and a.Year = B.year and a.week = b.Week and a.Quarter = b.Quarter and A.Date_Type = b.Date_Type
and A.EndDate = b.EndDate AND A.UF = B.UF
),


 BASE_PPG_TPR AS (
-- PREÇO MÉDIO
SELECT 	Date_Type 			        AS Date_Type,
		Category           	        AS Category,
		Short_Category				AS Short_Category,
		Base.PPG					AS PPG,
		Segment				        AS Segment,
		ROW_NUMBER() OVER (PARTITION BY Category, EndDate 
		ORDER BY Base.EAN ASC) 		AS Category_Rank,
		Area				        AS Area,		
		Base.RE					        AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN					        AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		
		EndDate				        AS EndDate,
		Quarter			       	    AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,
				
		BASE.TPR_Value			        AS Value,
		TPR_Units			        AS Units,
		TPR_Price 			        AS Price,
		TPR_Volume			        AS Volume,
		TPR_Price_Volume	        AS Price_Volume,
		
		'TPR'			        	AS Price_Type,
		SAFE_CAST(
			SPI.spi_rate
				AS FLOAT64)	        AS SPI,
		MAX_DATE			    	AS MaxDate,
		SG.FirstMonth		        AS SPI_FirstMonth,
		SG.LastMonth		        AS SPI_LastMonth,
		BC.MaxMonthDate		        AS MaxMonthDate,
		0					           AS RECO,
        promo_indicator, SPI.ppg_concorrencia,
				SPI.ean_concorencia,
		0		    	            AS Value_C,
		0				            AS Units_C,
		0 				            AS Price_C,
		0				            AS Volume_C,
		0		                    AS Price_Volume_C,
		SOM_Sales,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                      
		MaxDateRef
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	LEFT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI 
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg 
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
),

BASE_CONCORRENCIA_TPR AS (

		SELECT 	Date_Type 			        AS Date_Type,
		Category         	                AS Category,

	    Area				                AS Area,		
		Base.RE					            AS RE,
        UF,		
		EndDate				                AS EndDate,
		Quarter			       	            AS Quarter,
		Base.Month			                AS Month,
		Base.Year			                AS Year,
		Week				                AS Week,

		MAX_DATE			    	        AS MaxDate,

		spi.ppg_concorrencia                as ppg_concorrencia,
		spi.ean_concorencia                 as ean_concorencia,
		TPR_Value		    	                AS Value_C,
		TPR_Units				                AS Units_C,
		TPR_Price 				                AS Price_C,
		TPR_Volume				                AS Volume_C,
		TPR_Price_Volume		                AS Price_Volume_C,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                        
		MaxDateRef,
		SAFE_CAST(
	    SPI.spi_rate_concorrencia
		AS FLOAT64)	                AS SPI_concorrencia
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	RIGHT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI 
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg_concorrencia 
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month

),

BASE_TPR AS (

SELECT distinct  A.Date_Type 			AS Date_Type,
		A.Category           	        AS Category,
		A.Short_Category				AS Short_Category,
		A.PPG					        AS PPG,
		A.Segment				        AS Segment,
		A.Category_Rank,
		A.Area				            AS Area,		
		A.RE					        AS RE,
		A.UF,
		A.Country				        AS country,
		A.Manufacturer		            AS manufacturer,
		A.Brand				            AS brand,
		A.Subbrand			            AS subbrand,
		A.EAN					        AS EAN,
		A.Market				        AS Market,
		A.RCD_Segment,
	    A.local_segment,
		
		A.EndDate				        AS EndDate,
		A.Quarter			       	    AS Quarter,
		A.Month			                AS Month,
		A.Year			                AS Year,
		A.Week				            AS Week,
				
		A.Value		    	            AS Value,
		A.Units				            AS Units,
		A.Price 				        AS Price,
		A.Volume				        AS Volume,
		A.Price_Volume		            AS Price_Volume,
		
		A.Price_Type,
		A.SPI,
		A.MaxDate,
		A.SPI_FirstMonth		        AS SPI_FirstMonth,
		A.SPI_LastMonth		            AS SPI_LastMonth,
		A.MaxMonthDate		            AS MaxMonthDate,
		A.RECO,
        A.promo_indicator, 
		A.ppg_concorrencia,
		A.ean_concorencia,

		B.Value_C,
		B.Units_C,
		B.Price_C,
		B.Volume_C,
		B.Price_Volume_C,
		SOM_Sales,
		A.strategy_index,                      
		A.MaxDateRef,
		B.SPI_concorrencia

FROM BASE_PPG_TPR A left join BASE_CONCORRENCIA_TPR B on A.ppg_concorrencia = B.ppg_concorrencia 
AND A.strategy_index = B.strategy_index AND A.RE = B.RE AND A.AREa = b. Area and a.Category = b.Category and A.MOnth = b.Month and a.Year = B.year and a.week = b.Week and a.Quarter = b.Quarter and A.Date_Type = b.Date_Type
and A.EndDate = b.EndDate AND A.UF = B.UF

),

 BASE_PPG_BASE AS (
-- PREÇO MÉDIO
SELECT 	Date_Type 			        AS Date_Type,
		Category           	        AS Category,
		Short_Category				AS Short_Category,
		Base.PPG					AS PPG,
		Segment				        AS Segment,
		ROW_NUMBER() OVER (PARTITION BY Category, EndDate 
		ORDER BY Base.EAN ASC) 		AS Category_Rank,
		Area				        AS Area,		
		Base.RE					        AS RE,
		UF,
		Country				        AS country,
		Manufacturer		        AS manufacturer,
		Brand				        AS brand,
		Subbrand			        AS subbrand,
		Base.EAN					        AS EAN,
		Market				        AS Market,
		RCD_Segment,
	    local_segment,
		
		EndDate				        AS EndDate,
		Quarter			       	    AS Quarter,
		Base.Month			        AS Month,
		Base.Year			        AS Year,
		Week				        AS Week,
				
		BASE.Base_Value			        AS Value,
		Base_Units			        AS Units,
	    Base_Price 			        AS Price,
		Base_Volume			        AS Volume,
		Base_Price_Volume	        AS Price_Volume,
		
		'BASE'			       	    AS Price_Type,
		SAFE_CAST(
			SPI.spi_rate
				AS FLOAT64)	        AS SPI,
		MAX_DATE			    	AS MaxDate,
		SG.FirstMonth		        AS SPI_FirstMonth,
		SG.LastMonth		        AS SPI_LastMonth,
		BC.MaxMonthDate		        AS MaxMonthDate,
		0					           AS RECO,
        promo_indicator, SPI.ppg_concorrencia,
				SPI.ean_concorencia,
		0		    	            AS Value_C,
		0				            AS Units_C,
		0 				            AS Price_C,
		0				            AS Volume_C,
		0		                    AS Price_Volume_C,
		SOM_Sales,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                      
		MaxDateRef	
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	LEFT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI --============================Verificar
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg 
		--and Base.EAN = 	CAST(SPI.ean AS STRING)
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month
),

BASE_CONCORRENCIA_BASE AS (

		SELECT 	Date_Type 			        AS Date_Type,
		Category         	                AS Category,

	    Area				                AS Area,		
		Base.RE					            AS RE,
        UF,		
		EndDate				                AS EndDate,
		Quarter			       	            AS Quarter,
		Base.Month			                AS Month,
		Base.Year			                AS Year,
		Week				                AS Week,

		MAX_DATE			    	        AS MaxDate,

		spi.ppg_concorrencia                as ppg_concorrencia,
		spi.ean_concorencia                 as ean_concorencia,
		Base_Value		    	                AS Value_C,
		Base_Units				                AS Units_C,
		Base_Price 				                AS Price_C,
		Base_Volume				                AS Volume_C,
		Base_Price_Volume		                AS Price_Volume_C,
		CASE WHEN SPI.strategy_index IS NULL THEN 0 else SPI.strategy_index END AS strategy_index,                       
		MaxDateRef,
		SAFE_CAST(
	    SPI.spi_rate_concorrencia
		AS FLOAT64)	                AS SPI_concorrencia
		
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp` Base
	RIGHT JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_SPI` SPI --============================Verificar
		ON Base.RE = UPPER(SPI.re) AND Base.Year = SPI.spi_year  AND Base.PPG = SPI.ppg_concorrencia 
		--and Base.EAN = 	CAST(SPI.ean_concorencia AS STRING)
	LEFT JOIN SPI_GROUP SG 
		ON Base.RE = SG.Retail_Enviroment AND Base.Year = SG.Year AND Base.PPG = SG.PnP_PPG
	LEFT JOIN BASE_CALENDAR BC
		ON Base.Year = BC.Year AND Base.Month = BC.Month

),

BASE_BASE AS (

SELECT distinct  A.Date_Type 			AS Date_Type,
		A.Category           	        AS Category,
		A.Short_Category				AS Short_Category,
		A.PPG					        AS PPG,
		A.Segment				        AS Segment,
		A.Category_Rank,
		A.Area				            AS Area,		
		A.RE					        AS RE,
		A.UF,
		A.Country				        AS country,
		A.Manufacturer		            AS manufacturer,
		A.Brand				            AS brand,
		A.Subbrand			            AS subbrand,
		A.EAN					        AS EAN,
		A.Market				        AS Market,
		A.RCD_Segment,
	    A.local_segment,
		
		A.EndDate				        AS EndDate,
		A.Quarter			       	    AS Quarter,
		A.Month			                AS Month,
		A.Year			                AS Year,
		A.Week				            AS Week,	
				
		A.Value		    	            AS Value,
		A.Units				            AS Units,
		A.Price 				        AS Price,
		A.Volume				        AS Volume,
		A.Price_Volume		            AS Price_Volume,
		
		A.Price_Type,
		A.SPI,
		A.MaxDate,
		A.SPI_FirstMonth		        AS SPI_FirstMonth,
		A.SPI_LastMonth		            AS SPI_LastMonth,
		A.MaxMonthDate		            AS MaxMonthDate,
		A.RECO,
        A.promo_indicator, 
		A.ppg_concorrencia,
		A.ean_concorencia,

		B.Value_C,
		B.Units_C,
		B.Price_C,
		B.Volume_C,
		B.Price_Volume_C,
		SOM_Sales,
		A.strategy_index,                      
		A.MaxDateRef,
		B.SPI_concorrencia

FROM BASE_PPG_BASE A left join BASE_CONCORRENCIA_BASE B on A.ppg_concorrencia = B.ppg_concorrencia --AND A.ean_concorencia = B.ean_concorencia
AND A.strategy_index = B.strategy_index AND A.RE = B.RE AND A.AREa = b. Area and a.Category = b.Category and A.MOnth = b.Month and a.Year = B.year and a.week = b.Week and a.Quarter = b.Quarter and A.Date_Type = b.Date_Type
and A.EndDate = b.EndDate AND A.UF = B.UF

)

SELECT * FROM BASE_BASE
UNION ALL
SELECT * FROM BASE_TPR
UNION ALL
SELECT * FROM BASE_AVERAGE
;

-- ========================================================================================================================================
-- FIM TABELA SPI 
--=========================================================================================================================================
-- ========================================================================================================================================
-- TABELA SPI PARA CONEXÃO NO DOMO
-- ========================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_PnP_Price_Tracking_Table_SPI`
	PARTITION BY EndDate cluster by Year, Category, RE, Area
	AS

	SELECT 	Date_Type 			AS Date_Type,
			Short_Category      AS Category,
			Category         	AS Category_Desc,
			PPG					AS PPG,
			Segment				AS Segment,
			Area				AS Area,		
			RE					AS RE,
			UF,
			Country				AS country,
			Manufacturer		AS manufacturer,
			Brand				AS brand,
			Subbrand			AS subbrand,
			EAN					AS EAN,
			Market				AS Market,
			EndDate				AS EndDate,
			Quarter				AS Quarter,
			Month				AS Month,
			Year				AS Year,
			Week				AS Week,
			Volume				AS Volume,
			Value				AS Value,
			Units				AS Units,
			Price	 			AS Price,
			Price_Volume		AS Price_Volume,
			Price_Type			AS Price_Type,
			SPI					AS SPI,
			Category_Rank       AS Category_Rank,
			MaxDate				AS MaxDate,
			MaxMonthDate		AS MaxMonthDate,
			SPI_FirstMonth		AS SPI_FirstMonth,
			SPI_LastMonth		AS SPI_LastMonth,
			RECO				AS RECO,
            promo_indicator,ppg_concorrencia,ean_concorencia,
			Value_C,
		    Units_C,
		    Price_C,
		    Volume_C,
		    Price_Volume_C,
			SOM_Sales,
			strategy_index,                      
		    MaxDateRef,
			CASE WHEN SPI_concorrencia IS NULL THEN 0 
			ELSE SPI_concorrencia END AS SPI_concorrencia
			
	FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking_SPI`
;
-- ===================================================================================================================================
-- FIM TABELA SPI PARA CONEXÃO NO DOMO
-- ===================================================================================================================================

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- #############################################################  BASE PARA COMPARAÇÕES DE PPGS  ######################################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_Comparison`
AS

SELECT 
	A.Date_Type 		      	      AS Date_Type,       
	A.Price_Type          	          AS Price_Type,      
    A.Area					          AS Area,	        	
	A.RE					          AS RE,              
	A.Market				          AS Market, 
	A.RCD_Segment,
	A.local_segment,
    A.Country				          AS Country,
	A.EndDate				          AS EndDate,         
	A.Quarter				          AS Quarter,        
	A.Month			    	          AS Month,           
	A.Year			    	          AS Year,            
	A.Week					          AS Week,    
	A.Manufacturer			          AS Manufacturer,
	A.Brand					          AS Brand,
	A.Subbrand				          AS Subbrand,
	A.Category         		          AS Category,
	A.Short_Category				  AS Short_Category,
	A.PPG					          AS PPG,
	A.Segment				          AS Segment,
	A.Value     				      AS Value,
	A.Units     				      AS Units,
	Price                             AS Price,
	A.Volume					      AS Volume,
	Price_Volume				      AS Price_Volume,
	--A.SPI				              AS SPI,
	A.MaxDate			              AS MaxDate,
	A.MaxMonthDate			          AS MaxMonthDate,
	B.Strategic_Index		          AS Index, 
	B.Comparison			          AS Comparison,
	1						          AS Ordem,
	B.Categoria				          AS Category_Comparison,
	B.Ordem					          AS Ordem_Comparison,
    A.promo_indicator

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking` A
INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Comparison` B ON A.PPG = B.PnP_PPG1
WHERE B.Active=1 AND A.Manufacturer <> '#TOTAL' AND  A.UF = 'BR'

UNION ALL

SELECT 
	A.Date_Type 		      	      AS Date_Type,       
	A.Price_Type          	          AS Price_Type,      
    A.Area				      	      AS Area,	        	
	A.RE					          AS RE,              
	A.Market				          AS Market, 
	A.RCD_Segment,
	A.local_segment,	
    A.Country				          AS Country,
	A.EndDate				          AS EndDate,         
	A.Quarter				          AS Quarter,        
	A.Month			    	          AS Month,           
	A.Year			    	          AS Year,            
	A.Week					          AS Week,    
	A.Manufacturer			          AS Manufacturer,
	A.Brand					          AS Brand,
	A.Subbrand				          AS Subbrand,
	A.Category         		          AS Category,
	A.Short_Category				  AS Short_Category,
	A.PPG					          AS PPG,
	A.Segment				          AS Segment,
	A.Value     				      AS Value,
	A.Units     				      AS Units,
	Price                             AS Price,
	A.Volume					      AS Volume,
	Price_Volume				      AS Price_Volume,
	--A.SPI				              AS SPI,
	A.MaxDate			              AS MaxDate,
	A.MaxMonthDate			          AS MaxMonthDate,
	B.Strategic_Index		          AS Index, 
	B.Comparison			          AS Comparison,
	2						          AS Ordem,
	B.Categoria				          AS Category_Comparison,
	B.Ordem					          AS Ordem_Comparison,
    A.promo_indicator

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Price_Tracking` A
INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Comparison` B ON A.PPG = B.PnP_PPG2
WHERE B.Active=1 AND  A.UF = 'BR';

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- #############################################################  BASE PARA COMPARAÇÕES DE PPGS  ######################################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ====================================================================================================================================================================================================
-- TABELA FINAL PARTICIONADA DE PRICE TRACKING COMPARISON PARA CONEXÃO COM O DOMO =====================================================================================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_PnP_Price_Tracking_Comparison_Table`
PARTITION BY EndDate cluster by Manufacturer, Category, RE, Area
AS

SELECT 
	Date_Type 			AS Date_Type,       
	Price_Type          AS Price_Type,      
    Area				AS Area,	        	
	RE					AS RE,              
	Market				AS Market, 
    Country				AS Country,
	EndDate				AS EndDate,         
	Quarter				AS Quarter,        
	Month			    AS Month,           
	Year			    AS Year,            
	Week				AS Week,    
	Manufacturer		AS Manufacturer,
	Brand				AS Brand,
	Subbrand			AS Subbrand,
    Short_Category      AS Category,
	Category         	AS Category_Desc,
	PPG					AS PPG,
	Segment				AS Segment,
	Value     			AS Value,
	Units     			AS Units,
	Price      			AS Price,
	Price_Volume		AS Volume,
	Price_Volume  		AS Price_Volume,
	--SPI				    AS SPI,
	MaxDate			    AS MaxDate,
	MaxMonthDate		AS MaxMonthDate,
	Index				AS Index, 
	Comparison			AS Comparison,
	Ordem				AS Ordem,
	Category_Comparison AS Category_Comparison,
	Ordem_Comparison	AS Ordem_Comparison,
    promo_indicator

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_Comparison`
;
-- ====================================================================================================================================================================================================
-- TABELA FINAL PARTICIONADA DE PRICE TRACKING COMPARISON PARA CONEXÃO COM O DOMO =====================================================================================================================================================================

-- ====================================================================================================================================================================================================
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BASE TPR @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_TPR`
--OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)) 
AS

-- =============================================================================================================================================================
-- DADOS SUMARIZADOS DE DESCONTO ===============================================================================================================================
-- =============================================================================================================================================================

WITH TOTAL AS(
SELECT 
Category, 
Short_Category,
year, 
RE,
RE_Market, 
Area, 
SUM(Units)   AS Unidades, 
SUM(Value)   AS Valor
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
WHERE RE !='NC' AND Area!='NC' AND year >=EXTRACT(YEAR FROM MAX_DATE)-2 AND EndDate <= MAX_DATE
AND UF = 'BR'
GROUP BY 
Category, Short_Category, year, RE, RE_Market, Area
),

BASE1 AS(
SELECT
Category, 
Short_Category, 
Country, 
Market, 
Manufacturer, 
Year, 
PPG, 
RE,
RE_Market, 
EndDate,
Area, 
SUM(Units)                        AS Units, 
SUM(Value)                        AS Value, 
SAFE_DIVIDE(SUM(Value),
			SUM(Units))			  AS Price,
SUM(TPR_Units)                    AS TPR_Units, 
SUM(TPR_Value)                    AS TPR_Value, 
SAFE_DIVIDE(SUM(TPR_Value),
			SUM(TPR_Units)) 	  AS TPR_Price, 
SUM(Base_Units)                   AS Base_Units, 
SUM(Base_Value)                   AS Base_Value,
SAFE_DIVIDE(SUM(Base_Value),
			SUM(Base_Units))   	  AS Base_Price

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` 
WHERE RE !='NC' AND Area!='NC' AND year >=EXTRACT(YEAR FROM MAX_DATE)-2 AND EndDate <= MAX_DATE
AND UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
GROUP BY
Category, 
Short_Category,
Country, 
Market, 
Manufacturer, 
Year, 
PPG, 
RE,
RE_Market, 
Area,
EndDate),

BASE2 AS(

SELECT Category, 
Short_Category,
Country, 
Market, 
Manufacturer, 
Year, 
PPG, 
RE,
RE_Market, 
Area,
Value,
Units,
TPR_Value,
TPR_Units,
Base_Value,
Base_Units,
Base_Price, 
(CASE
		WHEN ((SAFE_DIVIDE(TPR_Value, TPR_Units)) IS NULL OR (SAFE_DIVIDE(TPR_Value, TPR_Units)) = 0) OR ((SAFE_DIVIDE(TPR_Value, TPR_Units)) > SAFE_DIVIDE(Value, Units)) THEN SAFE_DIVIDE(Value,Units)
		ELSE (SAFE_DIVIDE(TPR_Value, TPR_Units))
	END)									AS TPR_Price_Calc
FROM BASE1
),

TPR AS(
SELECT *,
ROUND((CASE
			WHEN (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1 > 0.05) Then 0
			ELSE (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1)
		   END), 2) 		AS Discount,

	(CASE
		WHEN ((CASE WHEN (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1 > 0.05) Then 0 ELSE (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1) END) < -0.20) THEN 4
		WHEN ((CASE WHEN (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1 > 0.05) Then 0 ELSE (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1) END) < -0.15) THEN 3
		WHEN ((CASE WHEN (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1 > 0.05) Then 0 ELSE (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1) END) < -0.10) THEN 2
		WHEN ((CASE WHEN (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1 > 0.05) Then 0 ELSE (ABS(SAFE_DIVIDE(TPR_Price_Calc, Base_Price)) -1) END) < -0.05) THEN 1
		ELSE 0
	 END) 					AS Discount_Range
FROM BASE2)


SELECT 
B.Category, 
B.Short_Category,
B.Country, 
B.Market, 
B.Manufacturer, 
B.Year, 
B.PPG, 
B.RE, 
B.RE_Market, 
B.Area,
B.Units, 
B.Value, 
B.Price,
B.TPR_Units, 
B.TPR_Value, 
B.TPR_Price, 
B.Base_Units, 
B.Base_Value,
B.Base_Price, 
B.Discount, 
B.Discount_Range,
B.Ratio_Value,
B.Ratio_Volume,
B.ASP,
B.Discount_Calc,
B.Data_Type,
S.Valor AS Valor, 
SAFE_DIVIDE((CASE WHEN Discount_Range = 0 THEN SUM(SUM(Base_Value)) OVER(PARTITION BY B.Category, 
B.Manufacturer, B.year, B.RE, B.Area, B.PPG) ELSE  TPR_Value END),
 S.Valor) AS SOM

FROM (
  SELECT
A.Category, 
A.Short_Category,
A.Country, 
A.Market, 
A.Manufacturer, 
A.Year, 
A.PPG, 
A.RE,
A.RE_Market, 
A.Area, 
SUM(Units)                        AS Units, 
SUM(Value)                        AS Value, 
SAFE_DIVIDE(SUM(Value),
			SUM(Units))			  AS Price,
SUM(TPR_Units)                    AS TPR_Units, 
SUM(TPR_Value)                    AS TPR_Value, 
SAFE_DIVIDE(SUM(TPR_Value),
			SUM(TPR_Units)) 	  AS TPR_Price, 
SUM(Base_Units)                   AS Base_Units, 
SUM(Base_Value)                   AS Base_Value,
SAFE_DIVIDE(SUM(Base_Value),
			SUM(Base_Units))   	  AS Base_Price, 
(CASE
	WHEN ((SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) IS NULL OR (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) = 0) 
    OR (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) > (SAFE_DIVIDE(SUM(Value), SUM(Units))) 
    THEN (SAFE_DIVIDE(SUM(Value), SUM(Units))) 
		ELSE (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units)))
	END)									          AS TPR_Price_Calc,
AVG(Discount)                     AS Discount, 
Discount_Range,
(CASE 
	WHEN Discount_Range = 0 OR
   SUM(`Value`) = 0 OR SUM(`Units`)=0 OR SUM(`TPR_Value`)=0 OR SUM(`TPR_Units`)=0
		THEN 0	ELSE
 SAFE_DIVIDE((SAFE_DIVIDE(SUM(`TPR_Value`),SUM(`Value`))),
  (SAFE_DIVIDE(((SAFE_DIVIDE(SUM(`TPR_Value`),SUM(`TPR_Units`)))-(SAFE_DIVIDE(SUM(`Value`),SUM(`Units`)))),
(SAFE_DIVIDE(SUM(`Value`),SUM(`Units`)))))) * (-1)
 END) 
 *100							AS Ratio_Value,
 
 (CASE 
 WHEN `Discount_Range` = 0 
 THEN 0
 WHEN SUM(`Value`) = 0 OR SUM(`Units`)=0 OR SUM(`TPR_Value`)=0 OR SUM(`TPR_Units`)=0
 THEN 0
 ELSE
 SAFE_DIVIDE((SAFE_DIVIDE(SUM(`TPR_Units`),SUM(`Units`))),
 (SAFE_DIVIDE(((SAFE_DIVIDE(SUM(`TPR_Value`),SUM(`TPR_Units`)))-(SAFE_DIVIDE(SUM(`Value`),SUM(`Units`)))),
 (SAFE_DIVIDE(SUM(`Value`),SUM(`Units`)))))) * (-1)
 END)*100						AS Ratio_Volume,
  
(CASE WHEN SUM(TPR_Units) =0 
	THEN 0
	ELSE
	SAFE_DIVIDE(SUM(TPR_Value),
	SUM(TPR_Units)) 
	END)						AS ASP,

(CASE WHEN SUM(`Value`) = 0 OR SUM(`Units`)=0 OR SUM(`TPR_Value`)=0 OR SUM(`TPR_Units`)=0
 THEN 0
 ELSE
((SAFE_DIVIDE(SUM(`TPR_Value`),SUM(`TPR_Units`)))-(SAFE_DIVIDE(SUM(`Value`),SUM(`Units`))))
/(SAFE_DIVIDE(SUM(`Value`),SUM(`Units`))) * (-1)
 END)							AS Discount_Calc,
 'Regular'						AS Data_Type,


FROM TPR A 
LEFT JOIN TOTAL S 
ON A.Category=S.Category
 AND A.Area=S.Area
 AND A.RE=S.RE
 AND A.Year=S.Year
 -- WHERE A.RE !='NC' AND A.Area!='NC' AND NOT A.Manufacturer IN('#TOTAL','#ELASTICITY') AND NOT A.PPG IN('#TOTAL','#ELASTICITY')
 GROUP BY 
Category,Short_Category, Country, Market, Manufacturer, year, PPG, RE, RE_Market, Area, Discount_Range) B

LEFT JOIN TOTAL S 
ON B.Category=S.Category
 AND B.Area=S.Area
 AND B.RE=S.RE
 AND B.Year=S.Year

 GROUP BY
B.Category, 
B.Short_Category,
B.Country, 
B.Market, 
B.Manufacturer, 
B.Year, 
B.PPG, 
B.RE, 
B.RE_Market, 
B.Area,
B.Units, 
B.Value, 
B.Price,
B.TPR_Units, 
B.TPR_Value, 
B.TPR_Price, 
B.Base_Units, 
B.Base_Value,
B.Base_Price, 
B.Discount, 
B.Discount_Range,
B.Ratio_Value,
B.Ratio_Volume,
B.ASP,
B.Discount_Calc,
B.Data_Type,
S.Valor

-- =============================================================================================================================================================
-- DADOS SUMARIZADOS DE DESCONTO ===============================================================================================================================
-- =============================================================================================================================================================

-- =============================================================================================================================================================
-- DADOS SUMARIZADOS INSERIDOS PARA FAIXA QUE NÃO EXISTE DE DESCONTO ===========================================================================================
-- =============================================================================================================================================================
UNION ALL

SELECT 
C.Category, 
C.Short_Category,
C.Country, 
C.Market, 
C.Manufacturer, 
C.year, 
C.PPG, 
C.RE,
C.RE_Market,  
C.Area,
C.Units, 
C.Value, 
C.Price,
C.TPR_Units, 
C.TPR_Value, 
C.TPR_Price, 
C.Base_Units, 
C.Base_Value,
C.Base_Price, 
C.Discount, 
C.Discount_Range,
C.Ratio_Value,
C.Ratio_Volume,
C.ASP,
C.Discount_Calc,
C.Data_Type,
S.Valor AS Valor, 
SAFE_DIVIDE((CASE WHEN Discount_Range = 0 THEN Base_Value ELSE 0 END),
 S.Valor) AS SOM

FROM (

SELECT 
B.Category, 
B.Short_Category,
B.Country, 
B.Market, 
B.Manufacturer, 
B.year, 
B.PPG, 
B.RE,
B.RE_Market,  
B.Area,
B.Units, 
B.Value, 
B.Price,
B.TPR_Units, 
B.TPR_Value, 
B.TPR_Price, 
B.Base_Units, 
B.Base_Value,
B.Base_Price, 
B.Discount, 
B.Discount_Range,
B.Ratio_Value,
B.Ratio_Volume,
B.ASP,
B.Discount_Calc,
B.Data_Type

FROM (SELECT 
		Category, 
		Short_Category,
		year, 
		PPG, 
		RE,
		RE_Market,  
		Area, 
		Discount_Range 
	FROM TPR
	-- WHERE RE !='NC' AND Area!='NC' AND NOT Manufacturer IN('#TOTAL','#ELASTICITY') AND NOT PPG IN('#TOTAL','#ELASTICITY')
	GROUP BY Category, Short_Category, year, PPG, RE, RE_Market, Area, Discount_Range) A

RIGHT JOIN (
		SELECT 
		A.Category, 
		A.Short_Category,
		A.Country, 
		A.Market, 
		A.Manufacturer, 
		A.year, 
		A.PPG, 
		A.RE,
		A.RE_Market, 
		A.Area, 		
		(CASE WHEN B.Discount_Range=0
			THEN SUM(Units) ELSE 0 END)	  AS Units, 
		(CASE WHEN B.Discount_Range=0
			THEN SUM(Value) ELSE 0 END)	  AS Value, 
		SAFE_DIVIDE(
			(CASE WHEN B.Discount_Range=0
			THEN SUM(Value) ELSE 0 END),
			(CASE WHEN B.Discount_Range=0
			THEN SUM(Units) ELSE 0 END))  AS Price,
		SUM(TPR_Units)				 	  AS TPR_Units, 
		SUM(TPR_Value)					  AS TPR_Value, 
		SAFE_DIVIDE(SUM(TPR_Value),
					SUM(TPR_Units))    	  AS TPR_Price,  
		SUM(Base_Units)                   AS Base_Units, 
		SUM(Base_Value)                   AS Base_Value,
		SAFE_DIVIDE(SUM(Base_Value),
					SUM(Base_Units))   	  AS Base_Price, 
		(CASE
		WHEN ((SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) IS NULL OR (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) = 0) 
		OR (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units))) > (SAFE_DIVIDE(SUM(Value), SUM(Units))) 
		THEN (SAFE_DIVIDE(SUM(Value), SUM(Units))) 
		ELSE (SAFE_DIVIDE(SUM(TPR_Value), SUM(TPR_Units)))
		END)							  AS TPR_Price_Calc,
		AVG(Discount)                     AS Discount, 
		B.Discount_Range, 
		0								  AS Ratio_Value,
		0								  AS Ratio_Volume,	
		(CASE WHEN SUM((CASE WHEN B.Discount_Range= 0 THEN Units ELSE 0 END)) =0 
			THEN 0
			ELSE
			SAFE_DIVIDE(SUM((CASE WHEN B.Discount_Range = 0 THEN Value ELSE 0 END)),
			SUM((CASE WHEN B.Discount_Range= 0 THEN Units ELSE 0 END))) 
		END)							AS ASP,
		0								AS Discount_Calc,
    	'TPR Table'						AS Data_Type
		FROM TPR A

		CROSS JOIN (SELECT 0 as Discount_Range
					UNION ALL 
					SELECT 1 as Discount_Range
					UNION ALL 
					SELECT 2 as Discount_Range
					UNION ALL 
					SELECT 3 as Discount_Range
					UNION ALL  
					SELECT 4 as Discount_Range) B
 
-- WHERE A.RE !='NC' AND A.Area!='NC' AND NOT A.Manufacturer IN('#TOTAL','#ELASTICITY') AND NOT A.PPG IN('#TOTAL','#ELASTICITY')
GROUP BY Category, Short_Category, Country, Market, Manufacturer, year, PPG, RE, Re_Market, Area, Discount_Range) B
 ON A.Category=B.Category
 AND A.Area=B.Area
 AND A.RE=B.RE
 AND A.Year=B.Year
 AND A.PPG=B.PPG
 AND A.Discount_Range = B.Discount_Range
  WHERE A.PPG IS NULL) C
 
LEFT JOIN TOTAL S 
ON C.Category=S.Category
 AND C.Area=S.Area
 AND C.RE=S.RE
 AND C.Year=S.Year
 ;
  
-- =============================================================================================================================================================
-- DADOS SUMARIZADOS INSERIDOS PARA FAIXA QUE NÃO EXISTE DE DESCONTO ===========================================================================================
-- =============================================================================================================================================================


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BASE TPR @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BASE INDEX @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- BASE TEMPORÁRIA PARA O INDEX
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp1`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 2 DAY)) AS

WITH GRUPO AS (
  
SELECT A.index_group,
RANK() over( order by A.index_group) AS RANK

FROM
(
select distinct index_group 
 from cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_INDEX
 ORDER BY index_group
 ) A

 ORDER BY RANK
)

SELECT 
 
    A.Area,
    A.RE,
    A.RE_Market, 
    A.Manufacturer,
    A.Brand,
    ''  AS SubBrand,
    A.Category, 
    A.Short_Category,
    A.PPG,
    B.index_group,
    C.RANK,             
    A.EndDate,  
    SUM(A.Value)/1000                 AS Value,   
    SUM(A.Units)/1000                 AS Units,
    SAFE_DIVIDE(SUM(A.Value),
			SUM(A.Units))			  AS Price,     
    SUM(A.TPR_Value)/1000             AS TPR_Value, 
    SUM(A.TPR_Units)/1000             AS TPR_Units, 
    SAFE_DIVIDE(SUM(A.TPR_Value),
			SUM(A.TPR_Units)) 	      AS TPR_Price, 
    SUM(A.Base_Units)/1000            AS Base_Units,    			
    SUM(A.Base_Value)/1000            AS Base_Value,  
    SAFE_DIVIDE(SUM(A.Base_Value),
			SUM(A.Base_Units))        AS Base_Price,
            MAX(WD) AS WD,
            MAX(ND) AS ND,
            MaxDate			
 
    FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` A
    INNER JOIN cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_INDEX B
    ON A.PPG = B.PPG
    INNER JOIN GRUPO C
    ON B.index_group = c.index_group
		WHERE A.EndDate <= MaxDate
   		AND AREA NOT IN ('AREA II + III', 'AREA IV + V') AND RE IN ('TOTAL RE', 'C&C', 'DRUGS', 'H&S')
        AND A.CATEGORY <> 'TOTAL SOAPS' AND UF = 'BR'
    GROUP BY Area,
    RE,
    RE_Market, 
    Manufacturer,
    Brand,
    Category, 
    Short_Category,
    PPG,             
    EndDate,
    B.index_group,
    C.RANK,
	MaxDate;


-- BASE TEMPORÁRIA PARA O SOM
CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp2`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 2 DAY)) AS
    SELECT 
	    Category  	            AS Category,
	    EndDate				    AS EndDate,
  		RE					    AS RE,
        Area as Area,
	    SUM(Value)	/1000	  	    AS Value,
	    SUM(Base_Value) /1000	    AS Base_Value,
	    SUM(TPR_Value)	/1000 	    AS Promo
    FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`
		WHERE EndDate <= MaxDate
		AND AREA NOT IN ('AREA II + III', 'AREA IV + V') AND RE IN ('TOTAL RE', 'C&C', 'DRUGS', 'H&S')
 AND CATEGORY <> 'TOTAL SOAPS' AND UF = 'BR'

	GROUP BY
        EndDate, 
	    Category,
	    RE, 
        Area;


-- APAGA REGISTROS DA TABELA DE INDEX
DELETE FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_PnP_Index` WHERE Area IS NOT NULL;


SET Rank_Size = (SELECT COUNT(DISTINCT index_group) FROM cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_INDEX);

-- LAÇO PARA CADA CATEGORIA DE PRODUTO
WHILE  Rank_id <= Rank_Size DO

SET Rank_id = Rank_id + 1;

-- INSERE DADOS POR GRUPO DE PRODUTO
INSERT INTO  `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_PnP_Index`

(Area,	RE,	EndDate1,	RE_Market1,	Manufacturer1,	Brand1,	SubBrand1,	Category1,	Short_Category1,	PPG1,	index_group1, Value1, Units1,	Price1,	TPR_Value1,	TPR_Units1,	TPR_Price1,	Base_Units1,	Base_Value1,	Base_Price1,	EndDate2,	RE_Market2,	Manufacturer2,	Brand2,	SubBrand2,	Category2,	Short_Category2,	PPG2,	index_group2, Value2, Units2,	Price2,	TPR_Value2,	TPR_Units2,	TPR_Price2,	Base_Units2,	Base_Value2,	Base_Price2,	RANK
, Promo, Category, EndDate, Value, Base_Value, IdxAvg, IdxPromo, IdxBase, AvgSom1, AvgSom2, PromoSom1, PromoSom2, BaseSom1, BaseSom2,
            WD1,
            ND1,
            WD2,
            ND2,MaxDate  )

SELECT 
    A.Area,
    A.RE_Market      as RE,
    A.EndDate        AS EndDate1,
    A.RE_Market      AS RE_Market1, 
    A.Manufacturer   AS Manufacturer1,
    A.Brand          AS Brand1,
    A.SubBrand       AS SubBrand1,
    A.Category       AS Category1, 
    A.Short_Category AS Short_Category1,
    A.PPG            AS PPG1,
    A.index_group    AS index_group1, 
    A.Value          AS Value1,               
    A.Units          as Units1,
    A.Price          AS Price1,     
    A.TPR_Value      AS TPR_Value1, 
    A.TPR_Units      AS TPR_Units1, 
    A.TPR_Price      AS TPR_Price1, 
    A.Base_Units     AS Base_Units1,    			
    A.Base_Value     AS Base_Value1,  
    A.Base_Price     AS Base_Price1,
     
    B.EndDate        AS EndDate2,  
    B.RE_Market      AS RE_Market2, 
    B.Manufacturer   AS Manufacturer2,
    B.Brand          AS Brand2,
    B.SubBrand       AS SubBrand2,
    B.Category       AS Category2, 
    B.Short_Category AS Short_Category2,
    B.PPG            AS PPG2,
    B.index_group    AS index_group2, 
    B.Value          as Value2,
    B.Units          as Units2,            
    B.Price          AS Price2,     
    B.TPR_Value      AS TPR_Value2, 
    B.TPR_Units      AS TPR_Units2, 
    B.TPR_Price      AS TPR_Price2, 
    B.Base_Units     AS Base_Units2,    			
    B.Base_Value     AS Base_Value2,  
    B.Base_Price     AS Base_Price2,
    A.RANK,
    C.Promo	AS Promo,
   
   --Adicionar na Tabela
    C.Category	    AS Category,
	C.EndDate	    AS EndDate,
	C.Value	        AS Value,
	C.Base_Value    AS Base_Value,
	
    IF(B.Price = 0,0,(A.Price / B.Price)) * 100                 			      AS IdxAvg,
	IF(B.TPR_Price=0,0,(A.TPR_Price / B.TPR_Price)) * 100       			      AS IdxPromo,
	IF(B.Base_Price=0,0,(A.Base_Price / B.Base_Price)) * 100    			      AS IdxBase,
	IF(C.Value = 0,0,(A.Value / C.Value)) * 100       			                  AS AvgSom1,
	IF(C.Value = 0,0,(B.Value / C.Value)) * 100       			                  AS AvgSom2,
    IF(C.Promo = 0,0,(A.TPR_Value / C.Promo)) * 100   			                  AS PromoSom1,
	IF(C.Promo = 0,0,(B.TPR_Value / C.Promo)) * 100   			                  AS PromoSom2,
	IF(C.Base_Value = 0,0,(A.Base_Value / C.Base_Value)) * 100	                  AS BaseSom1,
	IF(C.Base_Value = 0,0,(B.Base_Value / C.Base_Value)) * 100 	                  AS BaseSom2,
    A.WD AS WD1,
    A.ND AS ND1,
    B.WD AS WD2,
    B.ND AS ND2,
    A.MaxDate	

FROM       `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp1` A

CROSS JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp1` B

INNER JOIN `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp2` C

  ON A.EndDate      = C.EndDate 
 AND A.Category     = C.Category
 AND A.RE           = C.RE
 AND A.Area         = C.Area

WHERE A.Area        = B.Area 
AND   A.RE          = B.RE 
AND   A.EndDate     = B.EndDate 
AND   A.PPG        <> B.PPG 
AND   A.index_group = B.index_group
AND   A.RANK        = Rank_id;

END WHILE; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ FIM BASE INDEX @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE INDEX PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_PnP_Index_Table` 
PARTITION BY EndDate1 cluster by Manufacturer1, Category1, RE, Area
AS

WITH AVG_RY AS (
  
  
SELECT PPG1, 
       Manufacturer1,  
	   CATEGORY1, 
	   RE, 
	   Area,
	   PPG2, 
	   Category2, 
	   Brand1, 
	   Brand2,
	   Manufacturer2, 
MIN(CASE WHEN DATE(EXTRACT(YEAR FROM enddate), EXTRACT(MONTH FROM enddate), EXTRACT(day FROM enddate)) >= DATE_SUB(DATE(EXTRACT(YEAR FROM maxdate), EXTRACT(MONTH FROM maxdate), 1), INTERVAL 12 month) THEN enddate END)  AS enddate ,


AVG(CASE WHEN DATE(EXTRACT(YEAR FROM enddate), EXTRACT(MONTH FROM enddate), EXTRACT(day FROM enddate)) >= DATE_SUB(DATE(EXTRACT(YEAR FROM maxdate), EXTRACT(MONTH FROM maxdate), 1), INTERVAL 12 month) THEN VALUE1 END) AS AVG_VALUE_RY1,
AVG(CASE WHEN DATE(EXTRACT(YEAR FROM enddate), EXTRACT(MONTH FROM enddate), EXTRACT(day FROM enddate)) >= DATE_SUB(DATE(EXTRACT(YEAR FROM maxdate), EXTRACT(MONTH FROM maxdate), 1), INTERVAL 12 month) THEN VALUE2 END) AS AVG_VALUE_RY2,
AVG(CASE WHEN DATE(EXTRACT(YEAR FROM enddate), EXTRACT(MONTH FROM enddate), EXTRACT(day FROM enddate)) >= DATE_SUB(DATE(EXTRACT(YEAR FROM maxdate), EXTRACT(MONTH FROM maxdate), 1), INTERVAL 12 month) THEN UNITS1 END) AS AVG_UNITS_RY1,
AVG(CASE WHEN DATE(EXTRACT(YEAR FROM enddate), EXTRACT(MONTH FROM enddate), EXTRACT(day FROM enddate)) >= DATE_SUB(DATE(EXTRACT(YEAR FROM maxdate), EXTRACT(MONTH FROM maxdate), 1), INTERVAL 12 month) THEN UNITS2 END) AS AVG_UNITS_RY2


FROM  `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_PnP_Index`


GROUP BY  PPG1, 
          Manufacturer1, 
          CATEGORY1, 
          RE, 
          Area,
          PPG2, 
          Category2, 
          Brand1, 
          Brand2, 
          Manufacturer2
)
,

BASE AS (

SELECT 
	Area,
	RE,
	Category1, 
	PPG1, 
	Manufacturer1, 
	Brand1, 
	SubBrand1, 
	Value1, 
	Units1, 
	Price1,
	TPR_Units1, 
	TPR_Value1, 
	TPR_Price1, 
	Base_Units1, 
	Base_Value1, 
	Base_Price1, 
	EndDate1, 
	Category2, 
	PPG2, 
	Manufacturer2, 
	Brand2 ,
	SubBrand2, 
	Value2, 
	Units2,
	Price2, 
	TPR_Units2, 
	TPR_Value2, 
	TPR_Price2, 
	Base_Units2, 
	Base_Value2,
	Base_Price2, 
	EndDate2, 
	IdxAvg, 
	IdxPromo, 
	IdxBase, 
	AvgSom1, 
	AvgSom2, 
	PromoSom1,
	PromoSom2, 
	BaseSom1, 
	BaseSom2, 
	Category, 
	EndDate, 
	Value, 
	Base_Value, 
	Promo,
	WD1,
	ND1,
	WD2,
	ND2,
	MaxDate
 FROM  `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_PnP_Index`

 )
SELECT A.*, B.enddate AS DATE_RY,  
       B.AVG_VALUE_RY1, B.AVG_VALUE_RY2,
CASE   WHEN  B.AVG_VALUE_RY1 >=0 THEN B.AVG_VALUE_RY1 - A.VALUE1 ELSE 0 END AS DIFERENCA_VALUE_RY1,
CASE   WHEN  B.AVG_VALUE_RY2 >=0 THEN B.AVG_VALUE_RY2 - A.VALUE2 ELSE 0 END AS DIFERENCA_VALUE_RY2,
CASE   WHEN  B.AVG_VALUE_RY1 <=0 THEN 0 
       WHEN  B.AVG_VALUE_RY1 > A.VALUE1 THEN 1 ELSE 0 END AS RY1_VALUE_MENOR,
CASE   WHEN  B.AVG_VALUE_RY1 <=0 THEN 0 
       WHEN  B.AVG_VALUE_RY2 > A.VALUE2 THEN 1 ELSE 0 END AS RY2_VALUE_MENOR,
CASE   WHEN  B.AVG_VALUE_RY1 <=0 THEN 0 
       WHEN  B.AVG_VALUE_RY1 < A.VALUE1 THEN 1 ELSE 0 END AS RY1_VALUE_MAIOR,
CASE   WHEN  B.AVG_VALUE_RY1 <=0 THEN 0 
       WHEN  B.AVG_VALUE_RY2 < A.VALUE2 THEN 1 ELSE 0 END AS RY2_VALUE_MAIOR,
	   
B.AVG_UNITS_RY1, B.AVG_UNITS_RY2,
CASE   WHEN  B.AVG_UNITS_RY1 >=0 THEN B.AVG_UNITS_RY1 - A.UNITS1 ELSE 0 END AS DIFERENCA_UNITS_RY1,
CASE   WHEN  B.AVG_UNITS_RY2 >=0 THEN B.AVG_UNITS_RY2 - A.UNITS2 ELSE 0 END AS DIFERENCA_UNITS_RY2,
CASE   WHEN  B.AVG_UNITS_RY1 <=0 THEN 0 
       WHEN  B.AVG_UNITS_RY1 > A.UNITS1 THEN 1 ELSE 0 END AS RY1_UNITS_MENOR,
CASE   WHEN  B.AVG_UNITS_RY1 <=0 THEN 0 
       WHEN  B.AVG_UNITS_RY2 > A.UNITS2 THEN 1 ELSE 0 END AS RY2_UNITS_MENOR,
CASE   WHEN  B.AVG_UNITS_RY1 <=0 THEN 0 
       WHEN  B.AVG_UNITS_RY1 < A.UNITS1 THEN 1 ELSE 0 END AS RY1_UNITS_MAIOR,
CASE   WHEN  B.AVG_UNITS_RY1 <=0 THEN 0 
       WHEN  B.AVG_UNITS_RY2 < A.UNITS2 THEN 1 ELSE 0 END AS RY2_UNITS_MAIOR	   
	   
	   
	   

 FROM BASE A  LEFT JOIN AVG_RY B 
 ON A.CATEGORY1      = B.CATEGORY1 
 AND A.Manufacturer1 = B.Manufacturer1 
 AND A.PPG1          = B.PPG1 
 AND A.RE            = B.RE 
 AND A.AREA          = B.AREA 
 AND A.ENDDATE      >= B.ENDDATE 
 AND A.PPG2          = B.PPG2 
 AND A.Category2     = B.Category2 
 AND A.Brand1        = B.Brand1 
 AND A.Brand2        = B.Brand2 
 AND A.manufacturer2 = B.manufacturer2
 
;
-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE INDEX PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BASE CRESCIMENTO @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- ====================================================================================================================================================================================================
-- DEFINIÇÃO DE VARIÁVEIS PARA RANGE DE PREÇOS POR CATEGORIA ==========================================================================================================================================
-- ====================================================================================================================================================================================================
  
    SET TP_RNG_IN  = 3; SET TB_RNG_IN  = 3; SET MW_RNG_IN  = 3; SET BS_RNG_IN  = 3; SET LA_RNG_IN  = 3; SET LK_RNG_IN  = 3; SET SH_RNG_IN  = 3; SET LH_RNG_IN  = 3; 
	SET TP_RNG_IN4 = 4; SET TB_RNG_IN4 = 4; SET MW_RNG_IN4 = 4; SET BS_RNG_IN4 = 4; SET LA_RNG_IN4 = 4; SET LK_RNG_IN4 = 4; SET SH_RNG_IN4 = 4; SET LH_RNG_IN4 = 4; 
	SET TP_RNG_IN5 = 5; SET TB_RNG_IN5 = 5; SET MW_RNG_IN5 = 5; SET BS_RNG_IN5 = 5; SET LA_RNG_IN5 = 5; SET LK_RNG_IN5 = 5; SET SH_RNG_IN5 = 5; SET LH_RNG_IN5 = 5; 
	SET TP_RNG_IN6 = 6; SET TB_RNG_IN6 = 6; SET MW_RNG_IN6 = 6; SET BS_RNG_IN6 = 6; SET LA_RNG_IN6 = 6; SET LK_RNG_IN6 = 6; SET SH_RNG_IN6 = 6; SET LH_RNG_IN6 = 6;
    SET TP_RNG_IN2 = 2; SET TB_RNG_IN2 = 2; SET MW_RNG_IN2 = 2; SET BS_RNG_IN2 = 2; SET LA_RNG_IN2 = 2; SET LK_RNG_IN2 = 2; SET SH_RNG_IN2 = 2; SET LH_RNG_IN2 = 2;
	SET TP_RNG_IN1 = 1; SET TB_RNG_IN1 = 1; SET MW_RNG_IN1 = 1; SET BS_RNG_IN1 = 1; SET LA_RNG_IN1 = 1; SET LK_RNG_IN1 = 1; SET SH_RNG_IN1 = 1; SET LH_RNG_IN1 = 1;
	SET TP_RNG_IN05 = 0.5; SET TB_RNG_IN05 = 0.5; SET MW_RNG_IN05 = 0.5; SET BS_RNG_IN05 = 0.5; SET LA_RNG_IN05 = 0.5; SET LK_RNG_IN05 = 0.5; SET SH_RNG_IN05 = 0.5; SET LH_RNG_IN05 = 0.5;

SET MAX_DATE = (SELECT MAX(MaxDate) FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base`);

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp`
OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)) 
AS

SELECT
	brand,
	Subbrand,
	Manufacturer,
	EndDate,
	month,
	Year,
	week_ajusted as WEEK,
	Area,
	RE,
	RE_Market,
	Category,
	PPG,
    Short_Category,
	SUM(Units)/1000    					  	AS Units, 
	SUM(Value)/1000				    	    AS Value,
	SUM(TPR_Units)/1000   					AS TPR_Units,
	SUM(TPR_Value)/1000				    	AS TPR_Value,
	(CASE
		WHEN (SAFE_DIVIDE(SUM(Value),	SUM(Units)) IS NULL) THEN 0
		ELSE SAFE_DIVIDE(SUM(Value),	SUM(Units))
	END) 									AS Preco_Medio,
	 MaxDate

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` 
WHERE  UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
GROUP BY 
	brand,
	Subbrand,
	Manufacturer,
	EndDate,
	month,
	Year,
	week_ajusted,
	Area,
	RE,
	Category,
    Short_Category,
	RE_Market,
	PPG,
	MaxDate
-- PARA MANUFACTURER, BRAND E SUBBRAND AGRUPADO	
UNION ALL

SELECT
	'#TOTAL' AS brand,
	'#TOTAL' AS Subbrand,
	'#TOTAL' AS Manufacturer,
	EndDate,
	month,
	Year,
	WEEK,
	Area,
	RE,
	RE_Market,
	Category,
	PPG,
    Short_Category,
	SUM(Units)/1000    					  	AS Units, 
	SUM(Value)/1000				    	    AS Value,
	SUM(TPR_Units)/1000   					AS TPR_Units,
	SUM(TPR_Value)/1000				    	AS TPR_Value,
	(CASE
		WHEN (SAFE_DIVIDE(SUM(Value),	SUM(Units)) IS NULL) THEN 0
		ELSE SAFE_DIVIDE(SUM(Value),	SUM(Units))
	END) 									           AS Preco_Medio,
	 MaxDate

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base` 
WHERE  UF = 'BR'
-- ==============================================================================	
-- COLOCAR A CONDIÇÃO PARA NÃO TRAZER OU TRAZER O NOVO MARKET: TOTAL ECOMMERCE/BR
-- AND market <> 'TOTAL ECOMMERCE/BR'	
-- ============================================================================== 
GROUP BY 
	EndDate,
	month,
	Year,
	WEEK,
	Area,
	RE,
	Category,
    Short_Category,
	RE_Market,
	PPG,
	MaxDate;

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growth`
-- OPTIONS(expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 60 DAY)) 
AS

-- TABELA TEMPORÁRIA COM DEFINIÇÃO DE RANGE DE PREÇOS
WITH
 RNG AS(

SELECT 'TP' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------

UNION ALL
SELECT 'TB' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
UNION ALL
SELECT 'MW' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
UNION ALL
SELECT 'BS' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
		
UNION ALL
SELECT 'SG ADULT' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
UNION ALL
SELECT 'SG KIDS' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
UNION ALL
SELECT 'SG TOTAL' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------
		
UNION ALL
SELECT 'LHS' AS Category, 
        --00
        0 AS R1, TP_RNG_IN AS R2, TP_RNG_IN * 2 AS R3,TP_RNG_IN * 3 AS R4, TP_RNG_IN * 4 AS R5, TP_RNG_IN * 5 AS R6,
        TP_RNG_IN * 6 AS R7,TP_RNG_IN * 7 AS R8, TP_RNG_IN * 8 AS R9, TP_RNG_IN * 9 AS R10, TP_RNG_IN * 10 AS R11,
		-------------------------------------------
		TP_RNG_IN * 11 AS R12, TP_RNG_IN *12 AS R13, TP_RNG_IN *13 AS R14, TP_RNG_IN *14 AS R15, TP_RNG_IN *15 AS R16,
		TP_RNG_IN *16  AS R17, TP_RNG_IN *17 AS R18, TP_RNG_IN *18 AS R19, TP_RNG_IN *19 AS R20, TP_RNG_IN *20 AS R21,
		-------------------------------------------
		--04
		TP_RNG_IN4 AS R22, TP_RNG_IN4 * 2 AS R23,TP_RNG_IN4 * 3 AS R24, TP_RNG_IN4 * 4 AS R25, TP_RNG_IN4 * 5 AS R26,
        TP_RNG_IN4 * 6 AS R27,TP_RNG_IN4 * 7 AS R28, TP_RNG_IN4 * 8 AS R29, TP_RNG_IN4 * 9 AS R30, TP_RNG_IN4 * 10 AS R31,
		
		------------------------------------------
		TP_RNG_IN4 * 11 AS R32, TP_RNG_IN4 * 12 AS R33,TP_RNG_IN4 * 13 AS R34, TP_RNG_IN4 * 14 AS R35, TP_RNG_IN4 * 15 AS R36,
        TP_RNG_IN4 * 16 AS R37, TP_RNG_IN4 * 17 AS R38, TP_RNG_IN4 * 18 AS R39, TP_RNG_IN4 * 19 AS R40, TP_RNG_IN4 * 20 AS R41,
		------------------------------------------
		--05
		TP_RNG_IN5 AS R42, TP_RNG_IN5 * 2 AS R43,TP_RNG_IN5 * 3 AS R44, TP_RNG_IN5 * 4 AS R45, TP_RNG_IN5 * 5 AS R46,
        TP_RNG_IN5 * 6 AS R47,TP_RNG_IN5 * 7 AS R48, TP_RNG_IN5 * 8 AS R49, TP_RNG_IN5 * 9 AS R50, TP_RNG_IN5 * 10 AS R51,
		
		------------------------------------------
		TP_RNG_IN5 * 11 AS R52, TP_RNG_IN5 * 12 AS R53,TP_RNG_IN5 * 13 AS R54, TP_RNG_IN5 * 14 AS R55, TP_RNG_IN5 * 15 AS R56,
        TP_RNG_IN5 * 16 AS R57,TP_RNG_IN5 * 17 AS R58, TP_RNG_IN5 * 18 AS R59, TP_RNG_IN5 * 19 AS R60, TP_RNG_IN5 * 20 AS R61,
		------------------------------------------
		--06
		TP_RNG_IN6 AS R62, TP_RNG_IN6 * 2 AS R63,TP_RNG_IN6 * 3 AS R64, TP_RNG_IN6 * 4 AS R65, TP_RNG_IN6 * 5 AS R66,
        TP_RNG_IN6 * 6 AS R67,TP_RNG_IN6 * 7 AS R68, TP_RNG_IN6 * 8 AS R69, TP_RNG_IN6 * 9 AS R70, TP_RNG_IN6 * 10 AS R71,
		
		------------------------------------------
		TP_RNG_IN6 * 11 AS R72, TP_RNG_IN6 * 12 AS R73,TP_RNG_IN6 * 13 AS R74, TP_RNG_IN6 * 14 AS R75, TP_RNG_IN6 * 15 AS R76,
        TP_RNG_IN6 * 16 AS R77,TP_RNG_IN6 * 17 AS R78, TP_RNG_IN6 * 18 AS R79, TP_RNG_IN6 * 19 AS R80, TP_RNG_IN6 * 20 AS R81,
		------------------------------------------
		
        --02
        TP_RNG_IN2 AS R82, TP_RNG_IN2 * 2 AS R83,TP_RNG_IN2 * 3 AS R84, TP_RNG_IN2 * 4 AS R85, TP_RNG_IN2 * 5 AS R86,
        TP_RNG_IN2 * 6 AS R87,TP_RNG_IN2 * 7 AS R88, TP_RNG_IN2 * 8 AS R89, TP_RNG_IN2 * 9 AS R90, TP_RNG_IN2 * 10 AS R91,
		------------------------------------------
		TP_RNG_IN2 *11 AS R92, TP_RNG_IN2 * 12 AS R93,TP_RNG_IN2 * 13 AS R94, TP_RNG_IN2 * 14 AS R95, TP_RNG_IN2 * 15 AS R96,
        TP_RNG_IN2 * 16 AS R97,TP_RNG_IN2 * 17 AS R98, TP_RNG_IN2 * 18 AS R99, TP_RNG_IN2 * 19 AS R100, TP_RNG_IN2 * 20 AS R101,
		------------------------------------------
		
		--01
		TP_RNG_IN1 AS R102, TP_RNG_IN1 * 2 AS R103,TP_RNG_IN1 * 3 AS R104, TP_RNG_IN1 * 4 AS R105, TP_RNG_IN1 * 5 AS R106,
        TP_RNG_IN1 * 6 AS R107,TP_RNG_IN1 * 7 AS R108, TP_RNG_IN1 * 8 AS R109, TP_RNG_IN1 * 9 AS R110, TP_RNG_IN1 * 10 AS R111,
		
		-------------------------------------------
		TP_RNG_IN1 * 11 AS R112, TP_RNG_IN1 * 12 AS R113,TP_RNG_IN1 * 13 AS R114, TP_RNG_IN1 * 14 AS R115, TP_RNG_IN1 * 15 AS R116,
        TP_RNG_IN1 * 16 AS R117,TP_RNG_IN1 * 17 AS R118, TP_RNG_IN1 * 18 AS R119, TP_RNG_IN1 * 19 AS R120, TP_RNG_IN1 * 20 AS R121,
		----------------------------------------------------------------
		--05
		TP_RNG_IN05 AS R122, TP_RNG_IN05 * 2 AS R123,TP_RNG_IN05 * 3 AS R124, TP_RNG_IN05 * 4 AS R125, TP_RNG_IN05 * 5 AS R126,
        TP_RNG_IN05 * 6 AS R127,TP_RNG_IN05 * 7 AS R128, TP_RNG_IN05 * 8 AS R129, TP_RNG_IN05 * 9 AS R130, TP_RNG_IN05 * 10 AS R131,
        ------------------------------------
		TP_RNG_IN05 *11 AS R132, TP_RNG_IN05 * 12 AS R133,TP_RNG_IN05 * 13 AS R134, TP_RNG_IN05 * 14 AS R135, TP_RNG_IN05 * 15 AS R136,
        TP_RNG_IN05 * 16 AS R137,TP_RNG_IN05 * 17 AS R138, TP_RNG_IN05 * 18 AS R139, TP_RNG_IN05 * 19 AS R140, TP_RNG_IN05 * 20 AS R141
		------------------------------------

) ,
BASE_PRICE AS (
SELECT A.*,(CASE WHEN Preco_Medio <= R.R2 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R2))
      WHEN Preco_Medio <= R.R3            THEN CONCAT('$',FORMAT('%02d',R2),'-$',FORMAT('%02d',R3))
      WHEN Preco_Medio <= R.R4            THEN CONCAT('$',FORMAT('%02d',R3),'-$',FORMAT('%02d',R4))
      WHEN Preco_Medio <= R.R5            THEN CONCAT('$',FORMAT('%02d',R4),'-$',FORMAT('%02d',R5))
      WHEN Preco_Medio <= R.R6            THEN CONCAT('$',FORMAT('%02d',R5),'-$',FORMAT('%02d',R6))
      WHEN Preco_Medio <= R.R7            THEN CONCAT('$',FORMAT('%02d',R6),'-$',FORMAT('%02d',R7))
      WHEN Preco_Medio <= R.R8            THEN CONCAT('$',FORMAT('%02d',R7),'-$',FORMAT('%02d',R8))
      WHEN Preco_Medio <= R.R9            THEN CONCAT('$',FORMAT('%02d',R8),'-$',FORMAT('%02d',R9))
      WHEN Preco_Medio <= R.R10           THEN CONCAT('$',FORMAT('%02d',R9),'-$',FORMAT('%02d',R10))
	  WHEN Preco_Medio <= R.R11           THEN CONCAT('$',FORMAT('%02d',R10),'-$',FORMAT('%02d',R11))
	  WHEN Preco_Medio <= R.R12           THEN CONCAT('$',FORMAT('%02d',R11),'-$',FORMAT('%02d',R12))
	  WHEN Preco_Medio <= R.R13           THEN CONCAT('$',FORMAT('%02d',R12),'-$',FORMAT('%02d',R13))
	  WHEN Preco_Medio <= R.R14           THEN CONCAT('$',FORMAT('%02d',R13),'-$',FORMAT('%02d',R14))
	  WHEN Preco_Medio <= R.R15           THEN CONCAT('$',FORMAT('%02d',R14),'-$',FORMAT('%02d',R15))
	  WHEN Preco_Medio <= R.R16           THEN CONCAT('$',FORMAT('%02d',R15),'-$',FORMAT('%02d',R16))
	  WHEN Preco_Medio <= R.R16           THEN CONCAT('$',FORMAT('%02d',R16),'-$',FORMAT('%02d',R17))
	  WHEN Preco_Medio <= R.R18           THEN CONCAT('$',FORMAT('%02d',R17),'-$',FORMAT('%02d',R18))
	  WHEN Preco_Medio <= R.R19           THEN CONCAT('$',FORMAT('%02d',R18),'-$',FORMAT('%02d',R19))
	  WHEN Preco_Medio <= R.R20           THEN CONCAT('$',FORMAT('%02d',R19),'-$',FORMAT('%02d',R20))
  ELSE CONCAT('Greater $', R.R20) END)    AS Price_Range, 3 as Price_Range_Size

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R22 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R22))
      WHEN Preco_Medio <= R.R23            THEN CONCAT('$',FORMAT('%02d',R22),'-$',FORMAT('%02d',R23))
      WHEN Preco_Medio <= R.R24            THEN CONCAT('$',FORMAT('%02d',R23),'-$',FORMAT('%02d',R24))
      WHEN Preco_Medio <= R.R25            THEN CONCAT('$',FORMAT('%02d',R24),'-$',FORMAT('%02d',R25))
      WHEN Preco_Medio <= R.R26            THEN CONCAT('$',FORMAT('%02d',R25),'-$',FORMAT('%02d',R26))
      WHEN Preco_Medio <= R.R27            THEN CONCAT('$',FORMAT('%02d',R26),'-$',FORMAT('%02d',R27))
      WHEN Preco_Medio <= R.R28            THEN CONCAT('$',FORMAT('%02d',R27),'-$',FORMAT('%02d',R28))
      WHEN Preco_Medio <= R.R29            THEN CONCAT('$',FORMAT('%02d',R28),'-$',FORMAT('%02d',R29))
      WHEN Preco_Medio <= R.R30            THEN CONCAT('$',FORMAT('%02d',R29),'-$',FORMAT('%02d',R30))
	  WHEN Preco_Medio <= R.R31            THEN CONCAT('$',FORMAT('%02d',R30),'-$',FORMAT('%02d',R31))
	  WHEN Preco_Medio <= R.R32            THEN CONCAT('$',FORMAT('%02d',R31),'-$',FORMAT('%02d',R32))
	  WHEN Preco_Medio <= R.R33            THEN CONCAT('$',FORMAT('%02d',R32),'-$',FORMAT('%02d',R33))
	  WHEN Preco_Medio <= R.R34            THEN CONCAT('$',FORMAT('%02d',R33),'-$',FORMAT('%02d',R34))
	  WHEN Preco_Medio <= R.R35            THEN CONCAT('$',FORMAT('%02d',R34),'-$',FORMAT('%02d',R35))
	  WHEN Preco_Medio <= R.R36            THEN CONCAT('$',FORMAT('%02d',R35),'-$',FORMAT('%02d',R36))
	  WHEN Preco_Medio <= R.R37            THEN CONCAT('$',FORMAT('%02d',R36),'-$',FORMAT('%02d',R37))
	  WHEN Preco_Medio <= R.R38            THEN CONCAT('$',FORMAT('%02d',R37),'-$',FORMAT('%02d',R38))
	  WHEN Preco_Medio <= R.R39            THEN CONCAT('$',FORMAT('%02d',R38),'-$',FORMAT('%02d',R39))
	  WHEN Preco_Medio <= R.R40            THEN CONCAT('$',FORMAT('%02d',R39),'-$',FORMAT('%02d',R40))
  ELSE CONCAT('Greater $', R.R40) END)    AS Price_Range, 4 as Price_Range_Size
 
 FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R42 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R42))
      WHEN Preco_Medio <= R.R43            THEN CONCAT('$',FORMAT('%02d',R42),'-$',FORMAT('%02d',R43))
      WHEN Preco_Medio <= R.R44            THEN CONCAT('$',FORMAT('%02d',R43),'-$',FORMAT('%02d',R44))
      WHEN Preco_Medio <= R.R45            THEN CONCAT('$',FORMAT('%02d',R44),'-$',FORMAT('%02d',R45))
      WHEN Preco_Medio <= R.R46            THEN CONCAT('$',FORMAT('%02d',R45),'-$',FORMAT('%02d',R46))
      WHEN Preco_Medio <= R.R47            THEN CONCAT('$',FORMAT('%02d',R46),'-$',FORMAT('%02d',R47))
      WHEN Preco_Medio <= R.R48            THEN CONCAT('$',FORMAT('%02d',R47),'-$',FORMAT('%02d',R48))
      WHEN Preco_Medio <= R.R49            THEN CONCAT('$',FORMAT('%02d',R48),'-$',FORMAT('%02d',R49))
      WHEN Preco_Medio <= R.R50            THEN CONCAT('$',FORMAT('%02d',R49),'-$',FORMAT('%02d',R50))
	  WHEN Preco_Medio <= R.R51            THEN CONCAT('$',FORMAT('%02d',R50),'-$',FORMAT('%02d',R51))
	  WHEN Preco_Medio <= R.R52            THEN CONCAT('$',FORMAT('%02d',R51),'-$',FORMAT('%02d',R52))
	  WHEN Preco_Medio <= R.R53            THEN CONCAT('$',FORMAT('%02d',R52),'-$',FORMAT('%02d',R53))
	  WHEN Preco_Medio <= R.R54            THEN CONCAT('$',FORMAT('%02d',R53),'-$',FORMAT('%02d',R54))
	  WHEN Preco_Medio <= R.R55            THEN CONCAT('$',FORMAT('%02d',R54),'-$',FORMAT('%02d',R55))
	  WHEN Preco_Medio <= R.R56            THEN CONCAT('$',FORMAT('%02d',R55),'-$',FORMAT('%02d',R56))
	  WHEN Preco_Medio <= R.R57            THEN CONCAT('$',FORMAT('%02d',R56),'-$',FORMAT('%02d',R57))
	  WHEN Preco_Medio <= R.R58            THEN CONCAT('$',FORMAT('%02d',R57),'-$',FORMAT('%02d',R58))
	  WHEN Preco_Medio <= R.R59            THEN CONCAT('$',FORMAT('%02d',R58),'-$',FORMAT('%02d',R59))
	  WHEN Preco_Medio <= R.R60            THEN CONCAT('$',FORMAT('%02d',R59),'-$',FORMAT('%02d',R60))
  ELSE CONCAT('Greater $', R.R60) END)    AS Price_Range, 5 as Price_Range_Size  

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R62 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R62))
      WHEN Preco_Medio <= R.R63            THEN CONCAT('$',FORMAT('%02d',R62),'-$',FORMAT('%02d',R63))
      WHEN Preco_Medio <= R.R64            THEN CONCAT('$',FORMAT('%02d',R63),'-$',FORMAT('%02d',R64))
      WHEN Preco_Medio <= R.R65            THEN CONCAT('$',FORMAT('%02d',R64),'-$',FORMAT('%02d',R65))
      WHEN Preco_Medio <= R.R66            THEN CONCAT('$',FORMAT('%02d',R65),'-$',FORMAT('%02d',R66))
      WHEN Preco_Medio <= R.R67            THEN CONCAT('$',FORMAT('%02d',R66),'-$',FORMAT('%02d',R67))
      WHEN Preco_Medio <= R.R68            THEN CONCAT('$',FORMAT('%02d',R67),'-$',FORMAT('%02d',R68))
      WHEN Preco_Medio <= R.R69            THEN CONCAT('$',FORMAT('%02d',R68),'-$',FORMAT('%02d',R69))
      WHEN Preco_Medio <= R.R70            THEN CONCAT('$',FORMAT('%02d',R69),'-$',FORMAT('%02d',R70))
	  WHEN Preco_Medio <= R.R71            THEN CONCAT('$',FORMAT('%02d',R70),'-$',FORMAT('%02d',R71))
	  WHEN Preco_Medio <= R.R72            THEN CONCAT('$',FORMAT('%02d',R71),'-$',FORMAT('%02d',R72))
	  WHEN Preco_Medio <= R.R73            THEN CONCAT('$',FORMAT('%02d',R72),'-$',FORMAT('%02d',R73))
	  WHEN Preco_Medio <= R.R74            THEN CONCAT('$',FORMAT('%02d',R73),'-$',FORMAT('%02d',R74))
	  WHEN Preco_Medio <= R.R75            THEN CONCAT('$',FORMAT('%02d',R74),'-$',FORMAT('%02d',R75))
	  WHEN Preco_Medio <= R.R76            THEN CONCAT('$',FORMAT('%02d',R75),'-$',FORMAT('%02d',R76))
	  WHEN Preco_Medio <= R.R77            THEN CONCAT('$',FORMAT('%02d',R76),'-$',FORMAT('%02d',R77))
	  WHEN Preco_Medio <= R.R78            THEN CONCAT('$',FORMAT('%02d',R77),'-$',FORMAT('%02d',R78))
	  WHEN Preco_Medio <= R.R79            THEN CONCAT('$',FORMAT('%02d',R78),'-$',FORMAT('%02d',R79))
	  WHEN Preco_Medio <= R.R80            THEN CONCAT('$',FORMAT('%02d',R79),'-$',FORMAT('%02d',R80))
  ELSE CONCAT('Greater $', R.R80) END)    AS Price_Range, 6 as Price_Range_Size 

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R82 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R82))
      WHEN Preco_Medio <= R.R83            THEN CONCAT('$',FORMAT('%02d',R82),'-$',FORMAT('%02d',R83))
      WHEN Preco_Medio <= R.R84            THEN CONCAT('$',FORMAT('%02d',R83),'-$',FORMAT('%02d',R84))
      WHEN Preco_Medio <= R.R85            THEN CONCAT('$',FORMAT('%02d',R84),'-$',FORMAT('%02d',R85))
      WHEN Preco_Medio <= R.R86            THEN CONCAT('$',FORMAT('%02d',R85),'-$',FORMAT('%02d',R86))
      WHEN Preco_Medio <= R.R87            THEN CONCAT('$',FORMAT('%02d',R86),'-$',FORMAT('%02d',R87))
      WHEN Preco_Medio <= R.R88            THEN CONCAT('$',FORMAT('%02d',R87),'-$',FORMAT('%02d',R88))
      WHEN Preco_Medio <= R.R89            THEN CONCAT('$',FORMAT('%02d',R88),'-$',FORMAT('%02d',R89))
      WHEN Preco_Medio <= R.R90            THEN CONCAT('$',FORMAT('%02d',R89),'-$',FORMAT('%02d',R90))
	  WHEN Preco_Medio <= R.R91            THEN CONCAT('$',FORMAT('%02d',R90),'-$',FORMAT('%02d',R91))
	  WHEN Preco_Medio <= R.R92            THEN CONCAT('$',FORMAT('%02d',R91),'-$',FORMAT('%02d',R92))
	  WHEN Preco_Medio <= R.R93            THEN CONCAT('$',FORMAT('%02d',R92),'-$',FORMAT('%02d',R93))
	  WHEN Preco_Medio <= R.R94            THEN CONCAT('$',FORMAT('%02d',R93),'-$',FORMAT('%02d',R94))
	  WHEN Preco_Medio <= R.R95            THEN CONCAT('$',FORMAT('%02d',R94),'-$',FORMAT('%02d',R95))
	  WHEN Preco_Medio <= R.R96            THEN CONCAT('$',FORMAT('%02d',R95),'-$',FORMAT('%02d',R96))
	  WHEN Preco_Medio <= R.R97            THEN CONCAT('$',FORMAT('%02d',R96),'-$',FORMAT('%02d',R97))
	  WHEN Preco_Medio <= R.R98            THEN CONCAT('$',FORMAT('%02d',R97),'-$',FORMAT('%02d',R98))
	  WHEN Preco_Medio <= R.R99            THEN CONCAT('$',FORMAT('%02d',R98),'-$',FORMAT('%02d',R99))
	  WHEN Preco_Medio <= R.R100            THEN CONCAT('$',FORMAT('%02d',R99),'-$',FORMAT('%02d',R100))
  ELSE CONCAT('Greater $', R.R100) END)    AS Price_Range, 2 as Price_Range_Size 

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R102 THEN CONCAT('$',FORMAT('%02d',R1),'-$',FORMAT('%02d',R102))
      WHEN Preco_Medio <= R.R103            THEN CONCAT('$',FORMAT('%02d',R102),'-$',FORMAT('%02d',R103))
      WHEN Preco_Medio <= R.R104            THEN CONCAT('$',FORMAT('%02d',R103),'-$',FORMAT('%02d',R104))
      WHEN Preco_Medio <= R.R105            THEN CONCAT('$',FORMAT('%02d',R104),'-$',FORMAT('%02d',R105))
      WHEN Preco_Medio <= R.R106            THEN CONCAT('$',FORMAT('%02d',R105),'-$',FORMAT('%02d',R106))
      WHEN Preco_Medio <= R.R107            THEN CONCAT('$',FORMAT('%02d',R106),'-$',FORMAT('%02d',R107))
      WHEN Preco_Medio <= R.R108            THEN CONCAT('$',FORMAT('%02d',R107),'-$',FORMAT('%02d',R108))
      WHEN Preco_Medio <= R.R109            THEN CONCAT('$',FORMAT('%02d',R108),'-$',FORMAT('%02d',R109))
      WHEN Preco_Medio <= R.R110            THEN CONCAT('$',FORMAT('%02d',R109),'-$',FORMAT('%02d',R110))
	  WHEN Preco_Medio <= R.R111            THEN CONCAT('$',FORMAT('%02d',R110),'-$',FORMAT('%02d',R111))
	  WHEN Preco_Medio <= R.R112            THEN CONCAT('$',FORMAT('%02d',R111),'-$',FORMAT('%02d',R112))
	  WHEN Preco_Medio <= R.R113            THEN CONCAT('$',FORMAT('%02d',R112),'-$',FORMAT('%02d',R113))
	  WHEN Preco_Medio <= R.R114            THEN CONCAT('$',FORMAT('%02d',R113),'-$',FORMAT('%02d',R114))
	  WHEN Preco_Medio <= R.R115            THEN CONCAT('$',FORMAT('%02d',R114),'-$',FORMAT('%02d',R115))
	  WHEN Preco_Medio <= R.R116            THEN CONCAT('$',FORMAT('%02d',R115),'-$',FORMAT('%02d',R116))
	  WHEN Preco_Medio <= R.R117            THEN CONCAT('$',FORMAT('%02d',R116),'-$',FORMAT('%02d',R117))
	  WHEN Preco_Medio <= R.R118            THEN CONCAT('$',FORMAT('%02d',R117),'-$',FORMAT('%02d',R118))
	  WHEN Preco_Medio <= R.R119            THEN CONCAT('$',FORMAT('%02d',R118),'-$',FORMAT('%02d',R119))
	  WHEN Preco_Medio <= R.R120            THEN CONCAT('$',FORMAT('%02d',R119),'-$',FORMAT('%02d',R120))
  ELSE CONCAT('Greater $', R.R120) END)    AS Price_Range, 1 as Price_Range_Size 
  
  FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 
  
UNION ALL 

SELECT A.*,(CASE WHEN Preco_Medio <= R.R122 THEN CONCAT('$',R1,'-$',R122)
      WHEN Preco_Medio <= R.R123            THEN CONCAT('$',R122,'-$',R123)
      WHEN Preco_Medio <= R.R124            THEN CONCAT('$',R123,'-$',R124)
      WHEN Preco_Medio <= R.R125            THEN CONCAT('$',R124,'-$',R125)
      WHEN Preco_Medio <= R.R126            THEN CONCAT('$',R125,'-$',R126)
      WHEN Preco_Medio <= R.R127            THEN CONCAT('$',R126,'-$',R127)
      WHEN Preco_Medio <= R.R128            THEN CONCAT('$',R127,'-$',R128)
      WHEN Preco_Medio <= R.R129            THEN CONCAT('$',R128,'-$',R129)
      WHEN Preco_Medio <= R.R130            THEN CONCAT('$',R129,'-$',R130)
	  WHEN Preco_Medio <= R.R131            THEN CONCAT('$',R130,'-$',R131)
	  WHEN Preco_Medio <= R.R132            THEN CONCAT('$',R131,'-$',R132)
	  WHEN Preco_Medio <= R.R133            THEN CONCAT('$',R132,'-$',R133)
	  WHEN Preco_Medio <= R.R134            THEN CONCAT('$',R133,'-$',R134)
	  WHEN Preco_Medio <= R.R135            THEN CONCAT('$',R134,'-$',R135)
	  WHEN Preco_Medio <= R.R136            THEN CONCAT('$',R135,'-$',R136)
	  WHEN Preco_Medio <= R.R137            THEN CONCAT('$',R136,'-$',R137)
	  WHEN Preco_Medio <= R.R138            THEN CONCAT('$',R137,'-$',R138)
	  WHEN Preco_Medio <= R.R139            THEN CONCAT('$',R138,'-$',R139)
	  WHEN Preco_Medio <= R.R140            THEN CONCAT('$',R139,'-$',R140)
  ELSE CONCAT('Greater $', R.R140) END)    AS Price_Range, 0.5 as Price_Range_Size 

FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp` A
LEFT JOIN RNG R ON A.Short_Category = R.Category 

),

 BASE AS (
SELECT      Price_Range,Price_Range_Size,
		    Manufacturer, 
		    Brand, 
		    SubBrand, 
		    Area, 
		    RE, 
		    Category, 
        EXTRACT(YEAR FROM MAX_DATE) AS YearNumber,
	        Short_Category,
	        RE_Market,
			MaxDate
	
FROM BASE_PRICE 
    
WHERE Year >=EXTRACT(YEAR FROM MAX_DATE)-2 
AND Area !='NC' AND RE !='NC' AND NOT EndDate IS NULL 
	   
GROUP BY     Price_Range, Price_Range_Size,
		     Manufacturer, 
		     Brand, 
		     SubBrand,
		     Area, 
		     RE, 
		     Category,
			 Short_Category,
	         RE_Market,
			MaxDate

UNION ALL 
SELECT      Price_Range,Price_Range_Size,
		    Manufacturer, 
		    Brand, 
		    SubBrand, 
		    Area, 
		    RE, 
		    A.Category, 
		    EXTRACT(YEAR FROM MAX_DATE)-1 AS YearNumber,
	        Short_Category,
	        RE_Market,
			MaxDate

FROM BASE_PRICE AS A
    LEFT JOIN RNG R ON A.Short_Category = R.Category

WHERE Year >=EXTRACT(YEAR FROM MAX_DATE)-2 
AND Area !='NC' AND RE !='NC' AND NOT EndDate IS NULL 

GROUP BY Price_Range, Price_Range_Size,
         Manufacturer, 
         Brand, 
         SubBrand,
         Area, 
         RE, 
         Category,
         Short_Category,
	     RE_Market,
		 MaxDate

UNION ALL

SELECT      Price_Range,Price_Range_Size,
    	    Manufacturer, 
		    Brand, 
		    SubBrand, 
		    Area, 
		    RE, 
		    A.Category, 
		    EXTRACT(YEAR FROM MAX_DATE)-2 AS YearNumber,
            Short_Category,
	        RE_Market,
			MaxDate
FROM BASE_PRICE AS A
    LEFT JOIN RNG R ON A.Short_Category = R.Category

WHERE Year >=EXTRACT(YEAR FROM MAX_DATE)-2 
AND Area !='NC' AND RE !='NC' AND NOT EndDate IS NULL 
	
GROUP BY Price_Range, Price_Range_Size,
		     Manufacturer, 
		     Brand, 
		     SubBrand,
		     Area, 
		     RE, 
		     Category,
		     Short_Category,
	         RE_Market,
			MaxDate
),

-- Base com os valores do ano correspondente à maior data
ANO_ATUAL AS (
SELECT      Price_Range,Price_Range_Size,
		    Manufacturer, 
		    Brand, 
			SubBrand, 
		    Area, 
		    RE, 
		    A.Category, 
		SUM(Value) AS Value, 
		SUM(Units) AS Units,
	    	Year   AS YearNumber,
            Short_Category,
	        RE_Market,
			MaxDate

FROM BASE_PRICE AS A
    LEFT JOIN RNG R ON A.Short_Category = R.Category

WHERE
 Area !='NC' AND RE !='NC' AND NOT EndDate IS NULL 

GROUP BY     Price_Range, Price_Range_Size,
	         Manufacturer, 
		     Brand, 
		     SubBrand,
		     Area, 
		     RE, 
		     Category, 
		     YearNumber,
		     Short_Category,
	         RE_Market,
			 MaxDate
),

-- Base com os valores do ano anterior correspondente à maior data.
ANO_ANTERIOR AS (
SELECT      Price_Range,	Price_Range_Size,
            Manufacturer, 
	    	Brand, 
		    SubBrand, 
		    Area, 
		    RE, 
		    A.Category, 
		
		SUM((CASE WHEN Month <= EXTRACT(MONTH FROM MAX_DATE) AND Week <= MaxWeek THEN Value
          WHEN Year < EXTRACT(YEAR FROM MAX_DATE)-1
		  THEN Value 
		ELSE 0 END)) AS Value,
		SUM((CASE WHEN Year < EXTRACT(YEAR FROM MAX_DATE)-1 THEN Units
          WHEN   Month <= EXTRACT(MONTH FROM MAX_DATE) AND Week<= MaxWeek
		  THEN Units 
		ELSE 0 END)) AS Units,
		
		Year + 1 AS YearNumber,
       Short_Category,
	   RE_Market,
	   MaxDate

FROM BASE_PRICE AS A
    LEFT JOIN RNG R ON A.Short_Category = R.Category
  
	WHERE
 Area !='NC' AND RE !='NC' AND NOT EndDate IS NULL 
	
GROUP BY     Price_Range, Price_Range_Size,
		     Manufacturer, 
	         Brand, 
		     SubBrand,
		     Area, 
		     RE, 
		     Category,
		     YearNumber,
		     Short_Category,
	         RE_Market,
			 MaxDate

)

SELECT A.*, 
       B.Value,   
	   B.Units, 
	   C.Value AS Value_LY, 
	   C.Units AS Units_LY, 
 CAST(A.YearNumber AS STRING) AS Year 
    
    FROM BASE A 
        LEFT JOIN ANO_ATUAL B ON 
        A.YearNumber   = B.YearNumber
    AND A.Price_Range  = B.Price_Range
    AND A.Manufacturer = B.Manufacturer
    AND A.Brand        = B.Brand
    AND A.SubBrand     = B.SubBrand
    AND A.Area         = B.Area
    AND A.RE           = B.RE
    AND A.Category     = B.Category
	AND a.Price_Range_Size = B.Price_Range_Size

    LEFT JOIN ANO_ANTERIOR C ON 
        A.YearNumber   = C.YearNumber
    AND A.Price_Range  = C.Price_Range
    AND A.Manufacturer = C.Manufacturer
    AND A.Brand        = C.Brand
    AND A.SubBrand     = C.SubBrand
    AND A.Area         = C.Area
    AND A.RE           = C.RE
    AND A.Category     = C.Category
	AND a.Price_Range_Size = C.Price_Range_Size
    
WHERE A.YearNumber >= EXTRACT(YEAR FROM MAX_DATE)-3;	

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ FIM BASE CRESCIMENTO @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE CRESCIMENTO PARA CONEXÃO COM O DOMO ============================================================================================================
-- ====================================================================================================================================================================================================

CREATE OR REPLACE TABLE `cp-saa-prod-ext-data-ingst.LatAm_Queries.BR_PnP_Growth_Table`
AS 
SELECT Price_Range, 
	Manufacturer, 
	Brand, 
	SubBrand, 
	Area, 	
	RE,
	RE_Market, 
	Category, 
	Short_Category,
	YearNumber,
	Year,
	Value,
	Value_LY,
	Units,
	Units_LY,
	Price_Range_Size,
	MaxDate
	
FROM `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growth`
;

-- ====================================================================================================================================================================================================
--  TABELA FINAL PARTICIONADA DE CRESCIMENTO PARA CONEXÃO COM O DOMO ============================================================================================================

-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################
-- ################################################################################### EXCLUSÃO DE BASES TEMPORÁRIAS ##################################################################################
-- ####################################################################################################################################################################################################
-- ####################################################################################################################################################################################################

-- BASE
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp1`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_Nielsen_Scan_Base_temp2`;

-- PRICE TRACKING
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Consolidadatemp`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PcTrck_tb_Base_Periodostemp`; 

-- INDEX
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp1`;
DROP TABLE IF EXISTS `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_temp2`;

-- CRESCIMENTO
DROP TABLE IF EXISTS  `cp-saa-prod-ext-data-ingst.LatAm_PnP.BR_PnP_Growthpricetemp`;

 -- END IF;
-- END;	
