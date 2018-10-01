SELECT MAX(MC.JobLoadDate)
FROM EnterpriseHub.dbo.MemberCompany MC
WHERE MC.JobLoadDate = 


with CVSCAG as 
(
      SELECT [BenefitPkgXRefId]
              ,[Carrier]
              ,[Account]
              ,[GroupNumber]
              ,[GroupName]
              ,[Bin]
              ,[RxPCN]
              ,[RxGroup]
              ,[MatchOn]
              ,[SentFile]
        FROM [EnterpriseHub].[CVS].[Cag]
        WHERE [Carrier] IS NOT NULL
          AND [Carrier] LIKE '8%'   		  
        
      UNION
  
      SELECT C.BenefitPkgXRefId
              ,SecCarrier AS [Carrier] 
              ,SecAccount AS [Account]  
              ,SecGroupNumber AS [GroupNumber]
              ,SecGroupName AS [GroupName]
              ,[Bin]
              ,[RxPCN]
              ,[RxGroup]
              ,[MatchOn]
              ,[SentFile]
        FROM [EnterpriseHub].[CVS].[Cag] C
        WHERE SecCarrier IS NOT NULL
          AND SecCarrier LIKE '3%'
)

SELECT *
FROM CVSCag CAG 
WHERE CAG.[BenefitPkgXRefId] IN(410,408)
;


select	mi.*
from EnterpriseHub.dbo.MemberIndicator MI
inner join EnterpriseHub.dbo.MemberCompany MC
	on MI.MemberRecId = MC.MemberRecId
	and MI.IndMRefId = 24 
	and (ISNULL(MI.IndEndDate,GETDATE()) >= '01/01/2014')	
	INNER JOIN EnterpriseHub.XRef.BenefitPackage BP ON BP.SORId = MI.IndValue 												
	--INNER JOIN CVSCag CAG ON CAG.[BenefitPkgXRefId] = BP.[BenefitPkgXRefId]
where 1=1	
	and mc.MemberRecId = 502751
;



SELECT  XBP.*
FROM MRef.BenefitPackage MBP
	INNER JOIN Xref.BenefitPackage XBP
	ON MBP.BenefitPkgMRefId = XBP.BenefitPkgMRefId
WHERE XBP.ExternalValue IN('P00310749499', 'P00310749643')


select	mi.*
from EnterpriseHub.dbo.MemberIndicator MI
inner join EnterpriseHub.dbo.MemberCompany MC
	on MI.MemberRecId = MC.MemberRecId
	and MI.IndMRefId = 24 
	and (ISNULL(MI.IndEndDate,GETDATE()) >= '01/01/2014')	
	INNER JOIN EnterpriseHub.XRef.BenefitPackage BP ON BP.SORId = MI.IndValue 												
	INNER JOIN CVSCag CAG ON CAG.[BenefitPkgXRefId] = BP.[BenefitPkgXRefId]
where 1=1
	and mc.MemberRecId = 42730
;










--=================MEMBER_KEYS==========
SELECT *
FROM EnterpriseHub.mref.ExternalType ET
;

SELECT TOP 100 M.MemberRecId, M.FirstName, M.JobLoadDate, xm.ExternalValue, ET.Code, ET.[Desc]
FROM EnterpriseHub.dbo.MemberCompany M
	INNER JOIN EnterpriseHub.Xref.Member XM
	ON M.MemberRecId = XM.MemberRecId AND M.CompanyMRefId = XM.CompanyMRefId
	INNER JOIN EnterpriseHub.mref.ExternalType ET
	ON XM.ExternalTypeMRefId = ET.ExternalTypeMRefId --AND ET.Code = 'MP' 	
WHERE XM.ExternalValue = '010054917'--'010596746'--'N00255066648'
M.MemberRecId IN(112334)--112334)--10029)--)--301559)
;
--=================MEMBER_KEYS==========



SELECT *
FROM ENTERPRISEINTERFACES.CVS.PREGNANCYCOVEREDPLAN P
--WHERE P.


SELECT CS.AvetaID, CS.MemberID, CS.[Group], CS.ST_Group, CS.FirstName, CS.LastName, CS.IndValue
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout CS
WHERE 1 = 1
	AND avetaid = '010585502'--'010623740'--'030075420'
	AND INDVALUE IN('P00310749643','P00310749499')
	--AND PREGNANCYCODE = 'Y'
;

SELECT DISTINCT CS.AvetaID, CS.MemberID, CS.[Group], CS.ST_Group, CS.FirstName, CS.LastName, CS.IndValue, C.ClaimRefID
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout CS
	INNER JOIN ENTERPRISEINTERFACES.CVS.PREGNANCYCOVEREDPLAN AS PREG
	ON CS.INDVALUE = PREG.BENEFITPACKAGEID
    INNER JOIN ENTERPRISEHUB.DBO.CLAIM AS C
    ON CS.MEMBERID = C.SubscriberMemberMRefID
WHERE 1 = 1
	AND avetaid = '010054917'--'010623740'--'030075420'
	AND INDVALUE IN('P00310749643','P00310749499')
	AND C.ServiceDateFrom >= dateadd(month,-9, GETDATE()) --Claims in the last 9 months
	AND C.ClaimStatusCodeMRefID not in (5,13)
	--AND PREGNANCYCODE = 'Y'
;

SELECT *
FROM EnterpriseInterfaces.CVS.PregnancyAndNewBornCodes p
WHERE P.ISNEWBORNCODE <> 1
;


SELECT TOP 100 *
FROM ENTERPRISEHUB.DBO.CLAIM C
WHERE C.ClaimRefID = 6262256
;



SELECT DISTINCT CS.AvetaID, CS.MemberID, CS.[Group], CS.ST_Group, CS.FirstName, CS.LastName, CS.IndValue, C.ClaimRefID, C.ServiceDateFrom, C.ServiceDateTo, CD.DiagnosisCodeMRefId, CODE.DiagnosisCode
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout CS
	INNER JOIN ENTERPRISEINTERFACES.CVS.PREGNANCYCOVEREDPLAN AS PREG
	ON CS.INDVALUE = PREG.BENEFITPACKAGEID
    INNER JOIN ENTERPRISEHUB.DBO.CLAIM AS C
    ON CS.MEMBERID = C.SUBSCRIBERMEMBERMREFID
	LEFT JOIN EnterpriseHub.dbo.ClaimDiagnosis CD 
	ON CD.ClaimRefID = C.ClaimRefID 
	LEFT JOIN EnterpriseHub.MRef.DiagnosisCode CODE 
	ON CODE.DiagnosisCodeMrefId = CD.DiagnosisCodeMRefId
    INNER JOIN ENTERPRISEINTERFACES.CVS.PREGNANCYANDNEWBORNCODES AS P
	ON P.CODE = CODE.DIAGNOSISCODE
WHERE 1 = 1
	AND avetaid = '010054917 '--'010585502'
	AND INDVALUE IN('P00310749643','P00310749499')
	AND CODE.DiagnosisCode IS NOT NULL
	AND C.ServiceDateFrom >= dateadd(month,-9, GETDATE()) --Claims in the last 9 months
	AND C.ClaimStatusCodeMRefID not in (5,13)
	--AND P.ISNEWBORNCODE <> 1
	--AND PREGNANCYCODE = 'Y'

	AND C.ClaimRefID = 73739834
	AND CD.DiagnosisCodeMRefId = 99685
;




--=======================================TEST_CASES============================
update EnterpriseHub.dbo.MemberCompany
set birthdate = '1957-09-27 00:00:00.000'
WHERE MemberRecId = 112334
;

SELECT *
FROM ENTERPRISEHUB.DBO.CLAIM C
WHERE C.ClaimRefID = 73739834
;

--UPDATE ENTERPRISEHUB.DBO.CLAIM
SET ServiceDateFrom = '2017-04-21', --'2016-09-21'--
ServiceDateTo = '2017-04-21'
WHERE 
--SubscriberMemberMRefID = 301559
	--AND 
	ClaimRefID = 73957863
;




SELECT *
FROM EnterpriseHub.dbo.ClaimDiagnosis D
WHERE D.ClaimRefID = 73739834
	AND D.DiagnosisCodeMRefId = 99685
;

--UPDATE EnterpriseHub.dbo.ClaimDiagnosis
SET DiagnosisCodeMRefId = 7545
WHERE ClaimRefID = 73957863
	AND DiagnosisCodeMRefId = 28697
;
--=======================================TEST_CASES============================


--=======================================TEST_CASES============================
SELECT *
FROM ENTERPRISEHUB.DBO.CLAIM C
WHERE C.ClaimRefID = 73331710
;

--UPDATE ENTERPRISEHUB.DBO.CLAIM
SET ServiceDateFrom = '2017-04-21', --'2016-09-21'--
ServiceDateTo = '2017-04-21'
WHERE 
--SubscriberMemberMRefID = 301559
	--AND 
	ClaimRefID = 73739834
;


SELECT *
FROM EnterpriseHub.dbo.ClaimDiagnosis D
WHERE D.ClaimRefID = 73331710
	AND D.DiagnosisCodeMRefId = 32162
;

--UPDATE EnterpriseHub.dbo.ClaimDiagnosis
SET DiagnosisCodeMRefId = 8961
WHERE ClaimRefID = 76258002
	AND DiagnosisCodeMRefId = 25163
;
--=======================================TEST_CASES============================





SELECT TOP 100 *
FROM EnterpriseHub.MRef.DiagnosisCode D
WHERE DIAGNOSISCODE = '676.94'--'633.10'

SELECT DISTINCT TOP 100 C.ClaimRefID, c.ServiceDateFrom, C.ServiceDateTo
FROM ENTERPRISEHUB.DBO.CLAIM c
WHERE C.ClaimRefID in(73957863), 73739834)

SELECT DISTINCT TOP 100 C.ClaimRefID, c.ServiceDateFrom, C.ServiceDateTo
FROM ENTERPRISEHUB.DBO.CLAIM AS C
WHERE C.ClaimRefID in(73331710, 73739834)
--CRefId: 73739834
--Diag:99685
--ServDate:2016-04-21 00:00:00.000
--:633.10:
--2017-04-21 00:00:00.000


--73331710:32162:2016-03-22 00:00:00.000:676.94

SELECT C.ClaimRefID, C.BenefitPkgRecId, C.SubscriberMemberMRefID, CODE.DiagnosisCodeMRefID, CODE.DiagnosisCode
FROM    ENTERPRISEHUB.DBO.CLAIM AS C        
        LEFT OUTER JOIN
        ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS AS CD
        ON CD.CLAIMREFID = C.CLAIMREFID
        LEFT OUTER JOIN
        ENTERPRISEHUB.MREF.DIAGNOSISCODE AS CODE
        ON CODE.DIAGNOSISCODEMREFID = CD.DIAGNOSISCODEMREFID
WHERE   C.CLAIMREFID = 73957863
        AND C.CLAIMSTATUSCODEMREFID NOT IN (5, 13)
;



SELECT *
FROM ENTERPRISEHUB.Xref.BenefitPackage XBP

SELECT  XBP.*
FROM ENTERPRISEHUB.MRef.BenefitPackage MBP
	INNER JOIN ENTERPRISEHUB.Xref.BenefitPackage XBP
	ON MBP.BenefitPkgMRefId = XBP.BenefitPkgMRefId
WHERE XBP.ExternalValue IN('P00310749499', 'P00310749643')

SELECT TOP 100 CV.[Group], CV.[ST_Group], CV.PregnancyCode
FROM   ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CV
WHERE 
PREGNANCYCODE = 'Y'
	--AND 
	CV.AvetaID = '010054917'
;

SELECT TOP 100 
CV.AvetaID
, CV.MemberID
, CV.FechaEligibilidad
, CV.FechaTerminacion
, CV.[Group]
, CV.[ST_Group]
, CV.PregnancyCode
, CV.LanguageCode
, CV.IndValue
FROM   ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CV
WHERE 1 = 1
--	AND IndValue = 'P00310749499'	
--PREGNANCYCODE = 'Y'
	AND CV.AvetaID = '010054917'--'010585502'
;

SELECT TOP 100 
CV.Account
, CV.[Group]
, CV.PregnancyCode
, CV.MemberID
, CV.FechaEligibilidad
, CV.FechaTerminacion
, CV.IndValue
FROM   ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CV
WHERE 1 = 1
--	AND IndValue = 'P00310749499'	
--PREGNANCYCODE = 'Y'
	AND CV.AvetaID = '010054917'
;


SELECT TOP 100 *
FROM   ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CV
WHERE 1 = 1
--	AND IndValue = 'P00310749499'	
--PREGNANCYCODE = 'Y'
	AND CV.AvetaID = '010585502'
;
