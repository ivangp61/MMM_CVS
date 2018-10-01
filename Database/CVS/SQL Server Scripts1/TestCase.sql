SELECT  PKG.MemberRecId
, PKG.IndValue
, Pkg.IndEffectiveDate
, PKG.IndEndDate
, C.ClaimRefID
, C.ServiceDateFrom
, C.ServiceDateTo
FROM EnterpriseHub.dbo.MemberIndicator Pkg
	INNER JOIN EnterpriseHub.MRef.Company comp 
	ON comp.CompanyMRefId = Pkg.CompanyMRefId
	INNER JOIN ENTERPRISEHUB.DBO.CLAIM C
	ON PKG.MemberRecId = C.SUBSCRIBERMEMBERMREFID
WHERE 1=1 
	AND Pkg.IndMRefId = 24	
	AND Pkg.MemberRecId IN(573689)
	AND C.ClaimRefID = 73739834
	AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,Pkg.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PKG.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
;

SELECT CONVERT(DATE,GETDATE())



SELECT TOP 100 C.ClaimRefID
, C.ServiceDateFrom
, C.ServiceDateTo
FROM ENTERPRISEHUB.DBO.CLAIM C
WHERE C.ClaimRefID = 73739834
;


SELECT  PKG.MemberRecId
, PKG.IndValue
, Pkg.IndEffectiveDate
, PKG.IndEndDate
FROM EnterpriseHub.dbo.MemberIndicator Pkg
	INNER JOIN EnterpriseHub.MRef.Company comp 
	ON comp.CompanyMRefId = Pkg.CompanyMRefId
WHERE 1=1 
	AND Pkg.IndMRefId = 24	
	AND Pkg.MemberRecId IN(573689)
;


SELECT *
FROM EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
;


