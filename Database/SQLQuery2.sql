SELECT *
FROM CVS.EligibilityFinalMasterHeader EFM
--WHERE 

SELECT Carrier FROM CVS.CVSSqeletonLayout 
GROUP BY Carrier 
HAVING COUNT(*) > 0             -- No Platino = 0  
  AND SUBSTRING(Carrier,1,1) = '8'      -- only primary  


SELECT Carrier,  COUNT(DISTINCT R.Det_ln) AS DETALLE
FROM CVS.EligibilityFinalDetailedRecord R
WHERE Carrier  IN( 8553     
,8554     
,8557     
,8559     
)
GROUP BY Carrier
;



SELECT *
FROM CVS.EligibilityFinalHeader--Platino




SELECT Carrier FROM CVS.CVSSqeletonLayout 
--WHERE IsPlatino = 1 
GROUP BY Carrier 
HAVING COUNT(*) > 0             -- Platino = 1 
  AND SUBSTRING(Carrier,1,1) = '3'      -- only secondary 


SELECT Carrier,  COUNT(DISTINCT R.Det_ln) AS DETALLE
FROM CVS.EligibilityFinalDetailedRecord R
WHERE Carrier  IN( 3215     
,3294     
,3295     
,3296     
,3297   
)
GROUP BY Carrier
;

